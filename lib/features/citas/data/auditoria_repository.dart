import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';

class AuditoriaRepository {
  final AppDatabase _db;
  AuditoriaRepository(this._db);

  Future<void> registrar({
    required int? userId,
    required String tabla,
    int? registroId,
    required String accion,
    Map<String, dynamic>? valorAntes,
    Map<String, dynamic>? valorDespues,
    String? motivo,
  }) async {
    await _db.into(_db.auditoria).insert(AuditoriaCompanion.insert(
          userId: Value(userId),
          tabla: tabla,
          registroId: Value(registroId),
          accion: accion,
          valorAntes: Value(valorAntes == null ? null : jsonEncode(valorAntes)),
          valorDespues:
              Value(valorDespues == null ? null : jsonEncode(valorDespues)),
          motivo: Value(motivo),
          fecha: DateTime.now().millisecondsSinceEpoch,
        ));
  }

  Stream<List<AuditoriaData>> watchTodos({int limit = 100}) {
    return (_db.select(_db.auditoria)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.fecha, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .watch();
  }

  Stream<List<AuditoriaData>> watchPorTabla(String tabla, {int limit = 100}) {
    return (_db.select(_db.auditoria)
          ..where((t) => t.tabla.equals(tabla))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.fecha, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .watch();
  }
}

final auditoriaRepositoryProvider = Provider<AuditoriaRepository>((ref) {
  return AuditoriaRepository(ref.watch(databaseProvider));
});
