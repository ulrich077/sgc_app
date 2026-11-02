import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';

class NetworkConfig {
  final bool esServidor;
  final String servidorIp;
  final int puerto;

  const NetworkConfig({
    required this.esServidor,
    required this.servidorIp,
    this.puerto = 8080,
  });

  String get baseHttp => 'http://$servidorIp:$puerto';
  String get baseWs => 'ws://$servidorIp:$puerto/api/ws';
  bool get configurado => esServidor || servidorIp.trim().isNotEmpty;
}

final networkConfigProvider = FutureProvider<NetworkConfig>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.select(db.configuracion).get();
  final map = {for (final r in rows) r.clave: r.valor};
  final esServidor = (map['es_servidor'] ?? 'false') == 'true';
  
  // Forzamos la IP local si está vacía o es nula
  String ip = map['servidor_ip'] ?? '';
  if (ip.trim().isEmpty) {
    ip = '127.0.0.1';
  }
  
  final puerto = int.tryParse(map['servidor_puerto'] ?? '') ?? 8080;
  
  return NetworkConfig(
    esServidor: esServidor,
    servidorIp: ip,
    puerto: puerto,
  );
});
