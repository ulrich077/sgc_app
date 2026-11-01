import 'dart:io';
import '../data/database/app_database.dart';
import 'email_queue_worker.dart';
import 'sgc_server.dart';

Future<void> main() async {
  final db = AppDatabase();
  final worker = EmailQueueWorker(db)..start();
  final server = SgcServer(db);
  await server.start(host: '0.0.0.0', port: 8080);

  ProcessSignal.sigint.watch().listen((_) async {
    stderr.writeln('Deteniendo servidor...');
    worker.stop();
    await server.stop();
    exit(0);
  });

  stderr.writeln('Servidor SGC corriendo. Ctrl+C para detener.');
}
