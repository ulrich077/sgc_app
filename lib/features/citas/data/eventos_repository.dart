import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';

class EventosRepository {
  final AppDatabase _db;
  EventosRepository(this._db);

  Future<void> registrar({
    required int citaId,
    required String tipoEvento,
    Map<String, dynamic>? detalle,
    int? userId,
  }) async {
    await _db.into(_db.eventosCita).insert(EventosCitaCompanion.insert(
          citaId: citaId,
          tipoEvento: tipoEvento,
          detalleJson: Value(detalle == null ? null : jsonEncode(detalle)),
          createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          createdBy: Value(userId),
        ));
  }

  Stream<List<EventosCitaData>> watchPorCita(int citaId) {
    return (_db.select(_db.eventosCita)
          ..where((t) => t.citaId.equals(citaId))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }
}

final eventosRepositoryProvider = Provider<EventosRepository>((ref) {
  return EventosRepository(ref.watch(databaseProvider));
});
