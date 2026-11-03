import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';

class NetworkConfig {
  final bool esServidor;
  final String servidorIp;
  final int puerto;

  const NetworkConfig({
    required this.esServidor,
    required this.servidorIp,
    this.puerto = 8443,
  });

  String get baseHttp => 'https://$servidorIp:$puerto';
  String get baseWs => 'wss://$servidorIp:$puerto/api/ws';
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
  
  final puerto = int.tryParse(map['servidor_puerto'] ?? '') ?? 8443;
  
  return NetworkConfig(
    esServidor: esServidor,
    servidorIp: ip,
    puerto: puerto,
  );
});
