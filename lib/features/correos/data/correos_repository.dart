import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../domain/correo_tipo.dart';

class CorreosRepository {
  final AppDatabase _db;
  CorreosRepository(this._db);

  /// Encola un correo. Si no hay pendientes, lo marca para envío inmediato.
  Future<int> encolar({
    int? citaId,
    required CorreoTipo tipo,
    required String destinatario,
    String? cc,
    required String asunto,
    required String cuerpoHtml,
    List<String>? adjuntos,
  }) async {
    final pendientes = await (_db.select(_db.correosLog)
          ..where((t) => t.estado.equals('pendiente')))
        .get();
    final hayCola = pendientes.isNotEmpty;
    final ahora = DateTime.now().millisecondsSinceEpoch;

    return _db.into(_db.correosLog).insert(CorreosLogCompanion.insert(
          citaId: Value(citaId),
          tipo: tipo.dbValue,
          destinatario: destinatario,
          cc: Value(cc),
          asunto: asunto,
          cuerpoHtml: Value(cuerpoHtml),
          adjuntosJson:
              Value(adjuntos == null ? null : jsonEncode(adjuntos)),
          estado: const Value('pendiente'),
          programadoAt: ahora,
          proximoIntentoAt: Value(hayCola ? null : ahora),
        ));
  }

  Stream<List<CorreosLogData>> watchTodos() {
    return (_db.select(_db.correosLog)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.programadoAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Stream<List<CorreosLogData>> watchPendientes() {
    return (_db.select(_db.correosLog)
          ..where((t) => t.estado.equals('pendiente'))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.programadoAt, mode: OrderingMode.asc)
          ]))
        .watch();
  }

  Future<void> marcarEnviado(int id) async {
    await (_db.update(_db.correosLog)..where((t) => t.id.equals(id))).write(
      CorreosLogCompanion(
        estado: const Value('enviado'),
        enviadoAt: Value(DateTime.now().millisecondsSinceEpoch),
        intentos: const Value(0),
      ),
    );
  }

  Future<void> marcarFallido(int id, String error, int intentos) async {
    final backoff = _backoff(intentos);
    await (_db.update(_db.correosLog)..where((t) => t.id.equals(id))).write(
      CorreosLogCompanion(
        estado: Value(intentos >= 6 ? 'fallido' : 'pendiente'),
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
}

final correosRepositoryProvider = Provider<CorreosRepository>((ref) {
  return CorreosRepository(ref.watch(databaseProvider));
});
