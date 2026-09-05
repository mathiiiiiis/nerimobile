import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:nerimobile/services/socket_events.dart';

final socketServiceProvider = Provider<SocketService>(SocketService.new);

class SocketService {
  SocketService(this._ref);

  final Ref _ref;

  WebSocketChannel? _channel;
  String token = "";

  void connect(String token) {
    this.token = token;
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://nerimity.com/socket.io/?EIO=4&transport=websocket'),
    );
    _channel!.stream.listen(_onEvent, onDone: _onDisconnect);
  }

  void _onEvent(dynamic raw) {
    if (raw[0] == '0') {
      _channel?.sink.add("40");
      return;
    }

    if (raw[0] == '2') {
      _channel?.sink.add("3");
      return;
    }

    if (raw[0] == "4" && raw[1] == "0") {
      send("user:authenticate", {"token": token});
    }

    if (raw[0] == "4" && raw[1] == "2") {
      final decodedEvent = jsonDecode(raw.substring(2)) as List<dynamic>;
      handleSocketEvent(_ref, decodedEvent[0], decodedEvent[1]);
    }
  }

  void send(String event, Map<String, dynamic> payload) {
    _channel?.sink.add("42${jsonEncode([event, payload])}");
  }

  void _onDisconnect() {}

  void dispose() => _channel?.sink.close();
}
