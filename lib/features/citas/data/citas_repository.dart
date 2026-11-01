import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../domain/cita_estado.dart';

class CitasPage {
  final List<Cita> rows;
  final int totalFiltered;
  const CitasPage({required this.rows, required this.totalFiltered});
}

/// Whitelist de columnas para ordenar. Devuelve un [OrderingTerm].
OrderingTerm _orderBy(String column, bool ascending, $CitasTable t) {
  final mode = ascending ? OrderingMode.asc : OrderingMode.desc;
  switch (column) {
    case 'nombre':
      return OrderingTerm(expression: t.personaNombre, mode: mode);
    case 'estado':
      return OrderingTerm(expression: t.estado, mode: mode);
    case 'creada':
      return OrderingTerm(expression: t.dateCreation, mode: mode);
    case 'fecha':
    default:
      return OrderingTerm(expression: t.fechaHoraFirma, mode: mode);
  }
}

class CitasRepository {
  final AppDatabase _db;
  CitasRepository(this._db);

  Stream<CitasPage> watchPage({
    required int page,
    required int pageSize,
    CitaEstado? estadoFiltro,
    String search = '',
    String sortColumn = 'fecha',
    bool ascending = false,
  }) {
    final query = _db.select(_db.citas)
      ..where((t) => t.isDelete.equals(false));

    if (estadoFiltro != null) {
      query.where((t) => t.estado.equals(estadoFiltro.dbValue));
    }

    if (search.trim().isNotEmpty) {
      final s = '%${search.trim()}%';
      query.where((t) =>
          t.personaNombre.like(s) |
          t.personaDpi.like(s) |
          t.personaCorreo.like(s) |
          t.personaTelefono.like(s));
    }

    query.orderBy([(t) => _orderBy(sortColumn, ascending, t)]);
    query.limit(pageSize, offset: page * pageSize);

    final countQuery = _db.selectOnly(_db.citas)
      ..addColumns([_db.citas.id.count()])
      ..where(_db.citas.isDelete.equals(false));
    if (estadoFiltro != null) {
      countQuery.where(_db.citas.estado.equals(estadoFiltro.dbValue));
    }
    if (search.trim().isNotEmpty) {
      final s = '%${search.trim()}%';
      countQuery.where(_db.citas.personaNombre.like(s) |
          _db.citas.personaDpi.like(s) |
          _db.citas.personaCorreo.like(s) |
          _db.citas.personaTelefono.like(s));
    }

    return query.watch().asyncMap((rows) async {
      final countRow = await countQuery.getSingle();
      final total = countRow.read(_db.citas.id.count()) ?? 0;
      return CitasPage(rows: rows, totalFiltered: total);
    });
  }

  Future<Cita?> porId(int id) =>
      (_db.select(_db.citas)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> crear({
    required String personaNombre,
    required String personaCorreo,
    required DateTime fechaHoraFirma,
    String? personaDpi,
    String? personaTelefono,
    String? notas,
    required int creadaPor,
  }) async {
    final uuid =
        '${DateTime.now().microsecondsSinceEpoch}-${_db.hashCode}';
    return _db.into(_db.citas).insert(CitasCompanion.insert(
          uuidPublico: uuid,
          personaNombre: personaNombre,
          personaCorreo: personaCorreo,
          fechaHoraFirma: fechaHoraFirma.millisecondsSinceEpoch,
          personaDpi: Value(personaDpi),
          personaTelefono: Value(personaTelefono),
          notas: Value(notas),
          creadaPor: creadaPor,
          dateCreation: Value(DateTime.now().millisecondsSinceEpoch),
          userCreation: Value(creadaPor),
        ));
  }

  Future<void> cambiarEstado({
    required int citaId,
    required CitaEstado nuevoEstado,
    required int userId,
  }) async {
    await (_db.update(_db.citas)..where((t) => t.id.equals(citaId))).write(
      CitasCompanion(
        estado: Value(nuevoEstado.dbValue),
        dateUpdated: Value(DateTime.now().millisecondsSinceEpoch),
        userUpdated: Value(userId),
      ),
    );
  }

  Stream<int> watchTotalPorEstado(CitaEstado estado) {
    return (_db.select(_db.citas)
          ..where((t) =>
              t.estado.equals(estado.dbValue) & t.isDelete.equals(false)))
        .watch()
        .map((r) => r.length);
  }

  Stream<List<Cita>> watchRecientes({int limit = 10}) {
    return (_db.select(_db.citas)
          ..where((t) => t.isDelete.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.dateCreation, mode: OrderingMode.desc)])
          ..limit(limit))
        .watch();
  }
}

final citasRepositoryProvider = Provider<CitasRepository>((ref) {
  return CitasRepository(ref.watch(databaseProvider));
});
