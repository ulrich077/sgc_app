import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Mantiene la lista de clientes WebSocket conectados y hace broadcast.
class WsChannelHub {
  final Set<WebSocketChannel> _clients = {};

  int get count => _clients.length;

  void add(WebSocketChannel channel) {
    _clients.add(channel);
    channel.stream.listen(
      (_) {},
      onDone: () => _clients.remove(channel),
      onError: (_) => _clients.remove(channel),
      cancelOnError: true,
    );
  }

  void broadcast(Map<String, dynamic> payload) {
    final msg = jsonEncode(payload);
    // Copia para evitar ConcurrentModification si un onDone se dispara durante el loop.
    for (final c in List<WebSocketChannel>.from(_clients)) {
      try {
        c.sink.add(msg);
      } catch (_) {
        _clients.remove(c);
      }
    }
  }

  void closeAll() {
    for (final c in List<WebSocketChannel>.from(_clients)) {
      try {
        c.sink.close();
      } catch (_) {}
    }
    _clients.clear();
  }
}
