import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../data/database/app_database.dart';
import 'api_client.dart';
import 'network_config.dart';

/// Escucha /api/ws del servidor. Cuando llega {"event":"db_changed","tables":[...]},
/// hace pull REST de la tabla afectada y actualiza la DB local.
class WebSocketSyncService {
  final NetworkConfig config;
  final AppDatabase db;
  final ApiClient api;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  bool _disposed = false;
  bool get conectado => _channel != null;

  WebSocketSyncService({
    required this.config,
    required this.db,
    required this.api,
  });

  void start() {
    if (config.esServidor || !config.configurado) return;
    _connect();
  }

  void _connect() {
    if (_disposed) return;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(config.baseWs));
      _sub = _channel!.stream.listen(
        (msg) => _onMessage(msg),
        onDone: _onDisconnect,
        onError: (_) => _onDisconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final event = data['event'] as String?;
      if (event == 'db_changed') {
        final tables = (data['tables'] as List).cast<String>();
        _pullTables(tables);
      }
    } catch (_) {}
  }

  Future<void> _pullTables(List<String> tables) async {
    for (final t in tables) {
      try {
        switch (t) {
          case 'citas':
            await _syncCitas();
            break;
          case 'configuracion':
            // La configuración se refresca vía streams de la DB local cuando
            // se actualice. Se puede hacer un pull manual si se necesita.
            break;
          default:
            break;
        }
      } catch (_) {}
    }
  }

  Future<void> _syncCitas() async {
    final list = await api.listarCitas();
    final companions = <CitasCompanion>[];
    for (final item in list) {
      final m = item as Map<String, dynamic>;
      companions.add(CitasCompanion.insert(
        uuidPublico: m['uuidPublico'] as String,
        personaNombre: m['personaNombre'] as String,
        personaCorreo: m['personaCorreo'] as String,
        fechaHoraFirma: m['fechaHoraFirma'] as int,
        estado: drift.Value(m['estado'] as String),
        personaDpi: drift.Value(m['personaDpi'] as String?),
        personaTelefono: drift.Value(m['personaTelefono'] as String?),
        creadaPor: 1, // FIXME: viene del server; ajustar cuando auth remoto
        dateCreation: drift.Value(m['dateCreation'] as int?),
        userCreation: const drift.Value(1),
        id: drift.Value(m['id'] as int),
      ));
    }
    // Reemplazo total de citas locales (pull completo)
    await db.transaction(() async {
      await db.delete(db.citas).go();
      await db.batch((b) => b.insertAll(db.citas, companions));
    });
  }

  void _onDisconnect() {
    _sub?.cancel();
    _sub = null;
    _channel = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_disposed) _connect();
    });
  }

  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    await _sub?.cancel();
    await _channel?.sink.close();
  }
}
