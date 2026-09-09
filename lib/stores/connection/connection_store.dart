import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nerimobile/services/socket_service.dart';
import 'package:nerimobile/stores/auth/auth_store.dart';

sealed class ConnectionState {
  const ConnectionState();
}

final class Disconnected extends ConnectionState {
  const Disconnected();
}

final class Connecting extends ConnectionState {
  const Connecting({this.retrying = false, this.error});

  final bool retrying;
  final String? error;
}

final class Authenticating extends ConnectionState {
  const Authenticating({this.queuePosition});

  final int? queuePosition;
}

final class Authenticated extends ConnectionState {
  const Authenticated();
}

final class ConnectionFailed extends ConnectionState {
  const ConnectionFailed(this.message);

  final String message;
}

final connectionProvider =
    NotifierProvider<ConnectionNotifier, ConnectionState>(
      ConnectionNotifier.new,
    );

class ConnectionNotifier extends Notifier<ConnectionState> {
  SocketService? _socket;

  @override
  ConnectionState build() {
    final token = ref.watch(authProvider).value;
    _socket = null;
    if (token == null) return const Disconnected();

    final socket = SocketService(
      ref,
      token: token,
      onState: (next) => state = next,
    );
    _socket = socket;
    ref.onDispose(socket.dispose);
    socket.connect();

    return const Connecting();
  }

  void send(String event, Map<String, dynamic> payload) {
    if (state is! Authenticated) return;
    _socket?.send(event, payload);
  }
}
