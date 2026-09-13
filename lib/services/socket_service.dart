import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:nerimobile/stores/auth/auth_store.dart';
import 'package:nerimobile/services/socket_events.dart';
import 'package:nerimobile/stores/connection/connection_store.dart';

const _maxBackoff = Duration(seconds: 30);
const _defaultSilence = Duration(seconds: 45);
const _attemptsBeforeError = 3;
const _unreachable = "Couldn't connect"; //TODO: add l10n

class SocketService {
  SocketService(this._ref, {required this.token, required this.onState});

  final Ref _ref;
  final String token;
  final void Function(ConnectionState state) onState;

  WebSocketChannel? _channel;
  Timer? _retry;
  Timer? _silence;
  Duration _silenceLimit = _defaultSilence;
  int _attempts = 0;
  bool _dropped = false;
  bool _hasConnected = false;
  bool _hasAuthenticated = false;
  bool _closed = false;

  void connect() {
    if (_closed) return;

    _retry?.cancel();
    _dropped = false;
    onState(
      Connecting(
        retrying: _hasConnected,
        error: _attempts >= _attemptsBeforeError ? _unreachable : null,
      ),
    );

    final channel = WebSocketChannel.connect(
      Uri.parse('wss://nerimity.com/socket.io/?EIO=4&transport=websocket'),
    );

    _channel = channel;
    _silenceLimit = _defaultSilence;
    _heard();

    //handshake failured dont reach the stream
    channel.ready.catchError((Object _) => _onDisconnect());

    channel.stream.listen(
      _onEvent,
      onDone: _onDisconnect,
      onError: (Object _) => _onDisconnect(),
    );
  }

  void _onEvent(dynamic raw) {
    _heard();

    if (raw[0] == '0') {
      _silenceLimit = _silenceFrom(raw.substring(1));
      _channel?.sink.add("40");
      return;
    }

    if (raw[0] == '2') {
      _channel?.sink.add("3");
      return;
    }

    if (raw[0] == "4" && raw[1] == "0") {
      _hasConnected = true;
      _attempts = 0;
      onState(const Authenticating());
      send("user:authenticate", {"token": token});
    }

    if (raw[0] == "4" && raw[1] == "2") {
      final event = jsonDecode(raw.substring(2)) as List<dynamic>;
      _handle(event[0] as String, event[1]);
    }
  }

  void _heard() {
    _silence?.cancel();
    _silence = Timer(_silenceLimit, _onDisconnect);
  }

  Duration _silenceFrom(String handshake) {
    try {
      final data = jsonDecode(handshake) as Map<String, dynamic>;
      final interval = data['pingInterval'] as int;
      final timeout = data['pingTimeout'] as int;
      return Duration(milliseconds: interval + timeout);
    } catch (_) {
      return _defaultSilence;
    }
  }

  void _handle(String event, dynamic payload) {
    switch (event) {
      case 'user:authenticated':
        onState(Authenticated(reconnected: _hasAuthenticated));
        _hasAuthenticated = true;
      case 'user:auth_queue_position':
        onState(Authenticating(queuePosition: payload['pos'] as int?));
      case 'user:authenticate_error':
        _onAuthenticateError(payload);
        return;
    }
    handleSocketEvent(_ref, event, payload);
  }

  //rejected token requires rebuilding the connection
  void _onAuthenticateError(dynamic payload) {
    final message = payload is Map && payload['message'] is String
        ? payload['message'] as String
        : 'Authentication failed'; //TODO:add l10n

    onState(ConnectionFailed(message));
    _ref.read(authProvider.notifier).signOut();
  }

  void resume() {
    if (_closed || _channel != null) return;

    _attempts = 0;
    connect();
  }

  void send(String event, Map<String, dynamic> payload) {
    _channel?.sink.add("42${jsonEncode([event, payload])}");
  }

  void _onDisconnect() {
    if (_closed || _dropped) return;

    _dropped = true;
    _silence?.cancel();
    _channel?.sink.close();
    _channel = null;
    _attempts += 1;
    _retry = Timer(_backoff(), connect);
  }

  Duration _backoff() {
    final base = Duration(milliseconds: 500 * pow(2, _attempts).toInt());
    final capped = base > _maxBackoff ? _maxBackoff : base;
    final jitter = Random().nextInt(1 + capped.inMilliseconds ~/ 4);
    return Duration(milliseconds: capped.inMilliseconds + jitter);
  }

  void dispose() {
    _closed = true;
    _retry?.cancel();
    _silence?.cancel();
    _channel?.sink.close();
  }
}
