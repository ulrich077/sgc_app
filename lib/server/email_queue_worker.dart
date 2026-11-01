import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import '../data/database/app_database.dart';
import 'email_service.dart';

class EmailQueueWorker {
  final AppDatabase db;
  Timer? _timer;
  bool _procesando = false;

  EmailQueueWorker(this.db);

  void start({Duration intervalo = const Duration(seconds: 30)}) {
    _timer?.cancel();
    _timer = Timer.periodic(intervalo, (_) => _tick());
    _tick();
  }

  Future<void> _tick() async {
    if (_procesando) return;
    _procesando = true;
    try {
      final ahora = DateTime.now().millisecondsSinceEpoch;
      final pendientes = await (db.select(db.correosLog)
            ..where((t) =>
                t.estado.equals('pendiente') &
                (t.proximoIntentoAt.isNull() |
                    t.proximoIntentoAt.isSmallerOrEqualValue(ahora)))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.programadoAt, mode: OrderingMode.asc)
            ])
            ..limit(10))
          .get();

      for (final c in pendientes) {
        await _procesar(c);
      }
    } catch (e) {
      stderr.writeln('EmailQueueWorker error: $e');
    } finally {
      _procesando = false;
    }
  }

  Future<void> _procesar(CorreosLogData c) async {
    try {
      final cfg = await _leerConfig();
      if (!cfg.configurado) {
        await _marcarFallido(c, 'SMTP no configurado', c.intentos + 1);
        return;
      }
      final adjuntos = <EmailAttachment>[];
      if (c.adjuntosJson != null && c.adjuntosJson!.isNotEmpty) {
        try {
          final lista = jsonDecode(c.adjuntosJson!) as List;
          for (final a in lista) {
            final path = a as String;
            final nombre = path.split('/').last;
            adjuntos.add(EmailAttachment(path: path, fileName: nombre));
          }
        } catch (_) {}
      }
      final service = EmailService(cfg);
      await service.enviar(
        destinatario: c.destinatario,
        cc: c.cc,
        asunto: c.asunto,
        cuerpoHtml: c.cuerpoHtml ?? '',
        adjuntos: adjuntos,
      );
      await (db.update(db.correosLog)..where((t) => t.id.equals(c.id)))
          .write(const CorreosLogCompanion(
        estado: Value('enviado'),
        enviadoAt: Value.absent(),
        errorMensaje: Value(null),
        intentos: Value(0),
      ).copyWith(
        enviadoAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
    } catch (e) {
      await _marcarFallido(c, e.toString(), c.intentos + 1);
    }
  }

  Future<void> _marcarFallido(
      CorreosLogData c, String error, int intentos) async {
    final backoff = _backoff(intentos);
    final agotado = intentos >= 6;
    await (db.update(db.correosLog)..where((t) => t.id.equals(c.id))).write(
      CorreosLogCompanion(
        estado: Value(agotado ? 'fallido' : 'pendiente'),
        errorMensaje: Value(error),
        intentos: Value(intentos),
        proximoIntentoAt: Value(
            DateTime.now().add(backoff).millisecondsSinceEpoch),
      ),
    );
  }

  Duration _backoff(int intentos) {
    switch (intentos) {
      case 1:
        return const Duration(minutes: 1);
      case 2:
        return const Duration(minutes: 5);
      case 3:
        return const Duration(minutes: 15);
      case 4:
        return const Duration(hours: 1);
      case 5:
        return const Duration(hours: 6);
      default:
        return const Duration(hours: 24);
    }
  }

  Future<EmailConfig> _leerConfig() async {
    final rows = await db.select(db.configuracion).get();
    final m = {for (final r in rows) r.clave: r.valor};
    return EmailConfig(
      host: m['smtp_host'] ?? '',
      port: int.tryParse(m['smtp_port'] ?? '') ?? 587,
      user: m['smtp_user'] ?? '',
      password: m['smtp_password'] ?? '',
      remitente: m['correo_remitente'] ?? '',
    );
  }

  void stop() {
    _timer?.cancel();
  }
}
