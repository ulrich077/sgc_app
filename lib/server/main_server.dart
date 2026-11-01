import 'dart:io';
import '../data/database/app_database.dart';
import 'sgc_server.dart';

Future<void> main() async {
  final db = AppDatabase();
  final server = SgcServer(db);
  await server.start(host: '0.0.0.0', port: 8080);
  stderr.writeln('Servidor SGC corriendo. Ctrl+C para detener.');
}
