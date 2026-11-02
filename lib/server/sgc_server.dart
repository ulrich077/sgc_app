import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/database/app_database.dart';
import '../features/documentos/services/file_storage_service.dart';
import '../features/documentos/services/pdf_service.dart';
import '../features/correos/data/correos_repository.dart';
import '../features/correos/domain/correo_tipo.dart';
import 'drift_change_notifier.dart';
import 'ws_channel_hub.dart';

class SgcServer {
  final AppDatabase db;
  final WsChannelHub hub = WsChannelHub();
  late final DriftChangeNotifier _notifier;
  HttpServer? _server;

  SgcServer(this.db) {
    _notifier = DriftChangeNotifier(db, hub);
  }

  Future<void> start({String host = '0.0.0.0', int port = 8080}) async {
    _notifier.start();

    final router = Router();

    router.get('/api/health', (Request req) {
      return Response.ok(jsonEncode({
        'status': 'ok',
        'clients': hub.count,
        'ts': DateTime.now().toIso8601String(),
      }), headers: {'content-type': 'application/json'});
    });

    // WebSocket
    final wsHandler = webSocketHandler((WebSocketChannel ws, String? protocol) {
      hub.add(ws);
      ws.sink.add(jsonEncode({'event': 'hello', 'clients': hub.count}));
    });
    router.get('/api/ws', wsHandler);

    // GET /api/citas
    router.get('/api/citas', (Request req) async {
      final rows = await (db.select(db.citas)
            ..where((t) => t.isDelete.equals(false))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.fechaHoraFirma, mode: OrderingMode.desc)
            ]))
          .get();
      return _json(rows.map(_citaToJson).toList());
    });

    // POST /api/citas
    router.post('/api/citas', (Request req) async {
      try {
        final body =
            jsonDecode(await req.readAsString()) as Map<String, dynamic>;
        final uuid =
            '${DateTime.now().microsecondsSinceEpoch}-${body.hashCode}';
        final id = await db.into(db.citas).insert(CitasCompanion.insert(
              uuidPublico: uuid,
              personaNombre: body['personaNombre'] as String,
              personaCorreo: body['personaCorreo'] as String,
              fechaHoraFirma: body['fechaHoraFirma'] as int,
              personaDpi: Value(body['personaDpi'] as String?),
              personaTelefono: Value(body['personaTelefono'] as String?),
              notas: Value(body['notas'] as String?),
              creadaPor: (body['creadaPor'] as int?) ?? 1,
              dateCreation:
                  Value(DateTime.now().millisecondsSinceEpoch),
              userCreation: Value((body['creadaPor'] as int?) ?? 1),
            ));
        return _json({'id': id});
      } catch (e) {
        return Response(400,
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'});
      }
    });

    // PATCH /api/citas/:id
    router.patch('/api/citas/<id>', (Request req, String idStr) async {
      try {
        final id = int.parse(idStr);
        final body =
            jsonDecode(await req.readAsString()) as Map<String, dynamic>;
        final companion = CitasCompanion(
          estado: body.containsKey('estado')
              ? Value(body['estado'] as String)
              : const Value.absent(),
          notas: body.containsKey('notas')
              ? Value(body['notas'] as String?)
              : const Value.absent(),
          postMortemPresentado: body.containsKey('postMortemPresentado')
              ? Value(body['postMortemPresentado'] as bool)
              : const Value.absent(),
          contraloriaPresentada: body.containsKey('contraloriaPresentada')
              ? Value(body['contraloriaPresentada'] as bool)
              : const Value.absent(),
          dateUpdated: Value(DateTime.now().millisecondsSinceEpoch),
        );
        await (db.update(db.citas)..where((t) => t.id.equals(id)))
            .write(companion);
        return _json({'ok': true});
      } catch (e) {
        return Response(400,
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'});
      }
    });

    // GET /api/config
    router.get('/api/config', (Request req) async {
      final rows = await db.select(db.configuracion).get();
      return _json({for (final r in rows) r.clave: r.valor});
    });

    // GET /api/documentos/<citaId>
    router.get('/api/documentos/<citaId>', (Request req, String citaIdStr) async {
      final citaId = int.parse(citaIdStr);
      final rows = await (db.select(db.documentos)
            ..where((t) =>
                t.citaId.equals(citaId) & t.isDelete.equals(false))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.subidoAt, mode: OrderingMode.desc)
            ]))
          .get();
      return _json(rows.map(_docToJson).toList());
    });

    // POST /api/documentos/upload (multipart) — shelf_multipart 2.x
    router.post('/api/documentos/upload', (Request req) async {
      try {
        final form = req.formData();
        if (form == null) {
          return Response(400, body: 'Se esperaba multipart/form-data');
        }

        int? citaId;
        String? tipo;
        int? userId;
        String? nombreArchivo;
        List<int>? bytes;

        await for (final formData in form.formData) {
          if (formData.name == 'meta') {
            final metaStr = await formData.part.readString();
            final meta = jsonDecode(metaStr) as Map<String, dynamic>;
            citaId = meta['citaId'] as int?;
            tipo = meta['tipo'] as String?;
            userId = meta['userId'] as int?;
          } else if (formData.name == 'file') {
            nombreArchivo = formData.filename ?? 'archivo';
            bytes = await formData.part.readBytes();
          }
        }

        if (citaId == null || tipo == null || userId == null || bytes == null) {
          return Response(400,
              body: jsonEncode({'error': 'Faltan campos requeridos'}),
              headers: {'content-type': 'application/json'});
        }

        final stored = await FileStorageService().guardarBytes(
          bytes: bytes,
          citaId: citaId,
          nombre: nombreArchivo ?? 'archivo',
        );

        final docId = await db.into(db.documentos).insert(
              DocumentosCompanion.insert(
                citaId: citaId,
                tipo: tipo,
                nombre: stored.nombre,
                rutaArchivo: stored.rutaAbsoluta,
                hashSha256: Value(stored.hashSha256),
                mimeType: Value(stored.mimeType),
                tamanoBytes: Value(stored.tamanoBytes),
                subidoPor: userId,
                subidoAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );

        return _json({
          'id': docId,
          'nombre': stored.nombre,
          'hash': stored.hashSha256,
        });
      } catch (e) {
        return Response(500,
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'});
      }
    });

    // GET /api/documentos/<id>/download
    router.get('/api/documentos/<id>/download',
        (Request req, String idStr) async {
      final id = int.parse(idStr);
      final doc = await (db.select(db.documentos)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (doc == null) return Response.notFound('Documento no encontrado');
      final file = File(doc.rutaArchivo);
      if (!await file.exists()) return Response.notFound('Archivo no existe');
      return Response.ok(
        file.openRead(),
        headers: {
          'content-type': doc.mimeType ?? 'application/octet-stream',
          'content-disposition':
              'attachment; filename="${doc.nombre}"',
        },
      );
    });

    // POST /api/citas/<id>/pdf — genera Documento de Responsabilidad
    router.post('/api/citas/<id>/pdf', (Request req, String idStr) async {
      try {
        final id = int.parse(idStr);
        final cita = await (db.select(db.citas)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (cita == null) return Response.notFound('Cita no encontrada');



        final result = await PdfService.generarDocumentoResponsabilidad(cita);

        return Response.ok(
          result.bytes,
          headers: {
            'content-type': 'application/pdf',
            'content-disposition':
                'attachment; filename="${result.nombreArchivo}"',
          },
        );
      } catch (e) {
        return Response(500,
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'});
      }
    });

    // POST /api/correos/encolar
    router.post('/api/correos/encolar', (Request req) async {
      try {
        final body =
            jsonDecode(await req.readAsString()) as Map<String, dynamic>;
        final repo = CorreosRepository(db);
        final id = await repo.encolar(
          citaId: body['citaId'] as int?,
          tipo: CorreoTipo.fromDb(body['tipo'] as String),
          destinatario: body['destinatario'] as String,
          cc: body['cc'] as String?,
          asunto: body['asunto'] as String,
          cuerpoHtml: body['cuerpoHtml'] as String,
          adjuntos: (body['adjuntos'] as List?)?.cast<String>(),
        );
        return _json({'id': id});
      } catch (e) {
        return Response(400,
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'});
      }
    });

    // GET /api/correos
    router.get('/api/correos', (Request req) async {
      final rows = await (db.select(db.correosLog)
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.programadoAt, mode: OrderingMode.desc)
            ]))
          .get();
      return _json(rows
          .map((c) => {
                'id': c.id,
                'citaId': c.citaId,
                'tipo': c.tipo,
                'destinatario': c.destinatario,
                'cc': c.cc,
                'asunto': c.asunto,
                'estado': c.estado,
                'intentos': c.intentos,
                'errorMensaje': c.errorMensaje,
                'programadoAt': c.programadoAt,
                'enviadoAt': c.enviadoAt,
              })
          .toList());
    });

    // GET /api/confirmar/<token> — el firmante abre el enlace del correo
    router.get('/api/confirmar/<token>', (Request req, String token) async {
      final cita = await (db.select(db.citas)
            ..where((t) => t.tokenConfirmacion.equals(token)))
          .getSingleOrNull();
      if (cita == null) {
        return Response.notFound('Enlace inválido o expirado.');
      }
      final expira = cita.tokenExpira;
      if (expira != null && DateTime.now().millisecondsSinceEpoch > expira) {
        return Response(410, body: 'El enlace ha expirado.');
      }
      await (db.update(db.citas)..where((t) => t.id.equals(cita.id))).write(
        CitasCompanion(
          confirmadoRecibidoAt: Value(DateTime.now().millisecondsSinceEpoch),
          estado: const Value('CORREO_CONFIRMADO'),
        ),
      );
      return Response.ok(
        '<html><body><h2>Correo confirmado</h2>'
        '<p>Gracias, ${cita.personaNombre}. Hemos registrado la confirmación.</p>'
        '</body></html>',
        headers: {'content-type': 'text/html; charset=utf-8'},
      );
    });

    final handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

    _server = await io.serve(handler, host, port);
    stderr.writeln('SGC server en http://$host:${_server!.port}');
  }

  Response _json(Object payload) => Response.ok(
        jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );

  Future<void> stop() async {
    await _notifier.dispose();
    hub.closeAll();
    await _server?.close(force: true);
  }

  Map<String, dynamic> _citaToJson(Cita c) => {
        'id': c.id,
        'uuidPublico': c.uuidPublico,
        'personaNombre': c.personaNombre,
        'personaDpi': c.personaDpi,
        'personaCorreo': c.personaCorreo,
        'personaTelefono': c.personaTelefono,
        'fechaHoraFirma': c.fechaHoraFirma,
        'estado': c.estado,
        'creadaPor': c.creadaPor,
        'dateCreation': c.dateCreation,
        'dateUpdated': c.dateUpdated,
      };

  Map<String, dynamic> _docToJson(Documento d) => {
        'id': d.id,
        'citaId': d.citaId,
        'tipo': d.tipo,
        'nombre': d.nombre,
        'hashSha256': d.hashSha256,
        'mimeType': d.mimeType,
        'tamanoBytes': d.tamanoBytes,
        'subidoAt': d.subidoAt,
      };
}
