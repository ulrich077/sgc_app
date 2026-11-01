import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailConfig {
  final String host;
  final int port;
  final String user;
  final String password;
  final String remitente;
  const EmailConfig({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.remitente,
  });
  bool get configurado =>
      host.trim().isNotEmpty && remitente.trim().isNotEmpty;
}

class EmailAttachment {
  final String path;
  final String fileName;
  const EmailAttachment({required this.path, required this.fileName});
}

class EmailService {
  final EmailConfig config;
  EmailService(this.config);

  Future<void> enviar({
    required String destinatario,
    String? cc,
    required String asunto,
    required String cuerpoHtml,
    List<EmailAttachment> adjuntos = const [],
  }) async {
    if (!config.configurado) {
      throw StateError('SMTP no configurado en ajustes.');
    }
    final smtp = SmtpServer(
      config.host,
      port: config.port,
      username: config.user.isEmpty ? null : config.user,
      password: config.password.isEmpty ? null : config.password,
      ssl: config.port == 465,
      allowInsecure: config.port != 465,
    );

    final msg = Message()
      ..from = Address(config.remitente, 'SGC')
      ..recipients.add(destinatario)
      ..subject = asunto
      ..html = cuerpoHtml;

    if (cc != null && cc.trim().isNotEmpty) {
      msg.ccRecipients.add(cc.trim());
    }

    for (final a in adjuntos) {
      final file = File(a.path);
      if (await file.exists()) {
        msg.attachments.add(FileAttachment(file));
      }
    }

    await send(msg, smtp);
  }
}
