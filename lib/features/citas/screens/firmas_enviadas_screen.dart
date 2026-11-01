import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/responsive.dart';
import '../../../data/database/app_database.dart';
import '../domain/cita_estado.dart';

class FirmasEnviadasScreen extends ConsumerStatefulWidget {
  const FirmasEnviadasScreen({super.key});

  @override
  ConsumerState<FirmasEnviadasScreen> createState() =>
      _FirmasEnviadasScreenState();
}

class _FirmasEnviadasScreenState extends ConsumerState<FirmasEnviadasScreen> {
  int? _sortColumnIndex;
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    final stream = (db.select(db.citas)
          ..where((t) =>
              (t.estado.equals(CitaEstado.contratoEnviado.dbValue) |
                  t.estado.equals(CitaEstado.cerrada.dbValue)) &
              t.isDelete.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.fechaHoraFirma, mode: OrderingMode.desc)
          ]))
        .watch();

    return Scaffold(
      appBar: AppBar(title: const Text('Firmas enviadas')),
      body: ListView(
        children: [
          const AppPageHeader(
            title: 'Firmas enviadas',
            subtitle: 'Citas con contrato enviado o cerradas',
          ),
          StreamBuilder<List<Cita>>(
            stream: stream,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(AppSizes.xl),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final rows = snap.data!;
              if (rows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(AppSizes.xl),
                  child: Center(child: Text('No hay firmas enviadas.')),
                );
              }
              final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
              final isMobile = Responsive.isMobile(context);

              final table = DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                showCheckboxColumn: false,
                columns: [
                  DataColumn(
                    label: const Text('Nombre'),
                    onSort: (i, asc) => setState(() {
                      _sortColumnIndex = i;
                      _sortAscending = asc;
                    }),
                  ),
                  const DataColumn(label: Text('Correo')),
                  const DataColumn(label: Text('DPI')),
                  const DataColumn(label: Text('Fecha firma')),
                  const DataColumn(label: Text('Estado')),
                ],
                rows: rows.map((c) {
                  final e = CitaEstado.fromDb(c.estado);
                  return DataRow(
                    onSelectChanged: (_) => _verDetalle(context, c),
                    cells: [
                      DataCell(Text(c.personaNombre)),
                      DataCell(Text(c.personaCorreo)),
                      DataCell(Text(c.personaDpi ?? '—')),
                      DataCell(Text(dateFmt.format(
                          DateTime.fromMillisecondsSinceEpoch(
                              c.fechaHoraFirma)))),
                      DataCell(_Badge(estado: e)),
                    ],
                  );
                }).toList(),
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePadding),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection:
                        isMobile ? Axis.horizontal : Axis.vertical,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 900),
                      child: table,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _verDetalle(BuildContext context, Cita c) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(c.personaNombre),
        content: Text('Detalle — ${CitaEstado.fromDb(c.estado).label}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final CitaEstado estado;
  const _Badge({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: estado.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: estado.color),
      ),
      child: Text(estado.label,
          style: TextStyle(
              color: estado.color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
