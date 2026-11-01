import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../../citas/domain/cita_estado.dart';

class ReporteKpis {
  final int total;
  final int creadas;
  final int pendientesEnvio;
  final int enviadas;
  final int cerradas;
  final int canceladas;
  final int reagendadas;
  const ReporteKpis({
    required this.total,
    required this.creadas,
    required this.pendientesEnvio,
    required this.enviadas,
    required this.cerradas,
    required this.canceladas,
    required this.reagendadas,
  });
}

class ReportesRepository {
  final AppDatabase _db;
  ReportesRepository(this._db);

  Stream<ReporteKpis> watchKpis({
    DateTime? desde,
    DateTime? hasta,
  }) {
    final desdeMs = desde?.millisecondsSinceEpoch;
    final hastaMs = hasta?.millisecondsSinceEpoch;

    return _db.select(_db.citas).watch().map((rows) {
      final filtered = rows.where((c) {
        if (desdeMs != null && c.fechaHoraFirma < desdeMs) return false;
        if (hastaMs != null && c.fechaHoraFirma > hastaMs) return false;
        return !c.isDelete;
      }).toList();

      int count(CitaEstado e) =>
          filtered.where((c) => c.estado == e.dbValue).length;

      return ReporteKpis(
        total: filtered.length,
        creadas: count(CitaEstado.citaCreada) +
            count(CitaEstado.correoConfirmado) +
            count(CitaEstado.enEsperaFirma) +
            count(CitaEstado.firmado) +
            count(CitaEstado.documentoSubido),
        pendientesEnvio: count(CitaEstado.pendienteEnvioContrato),
        enviadas: count(CitaEstado.contratoEnviado),
        cerradas: count(CitaEstado.cerrada),
        canceladas: count(CitaEstado.cancelada) + count(CitaEstado.vencida),
        reagendadas: count(CitaEstado.reagendada) +
            count(CitaEstado.noSePresento),
      );
    });
  }

  Future<List<Cita>> obtenerCitas({
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final query = _db.select(_db.citas)
      ..where((t) => t.isDelete.equals(false));
    if (desde != null) {
      query.where((t) => t.fechaHoraFirma
          .isBiggerOrEqualValue(desde.millisecondsSinceEpoch));
    }
    if (hasta != null) {
      query.where((t) => t.fechaHoraFirma
          .isSmallerOrEqualValue(hasta.millisecondsSinceEpoch));
    }
    query.orderBy([
      (t) => OrderingTerm(
          expression: t.fechaHoraFirma, mode: OrderingMode.desc)
    ]);
    return query.get();
  }
}

final reportesRepositoryProvider = Provider<ReportesRepository>((ref) {
  return ReportesRepository(ref.watch(databaseProvider));
});
