import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/database/app_database.dart';
import '../data/citas_repository.dart';
import '../domain/cita_estado.dart';
import '../widgets/cita_detalle_modal.dart';

class FirmasEnviadasScreen extends ConsumerStatefulWidget {
  const FirmasEnviadasScreen({super.key});

  @override
  ConsumerState<FirmasEnviadasScreen> createState() =>
      _FirmasEnviadasScreenState();
}

class _FirmasEnviadasScreenState extends ConsumerState<FirmasEnviadasScreen> {
  static const _sortKeys = ['nombre', 'dpi', 'correo', 'fecha', 'estado'];
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(citasRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firmas Enviadas'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(
            title: 'Firmas Enviadas',
            subtitle: 'Citas con contrato enviado o cerradas.',
          ),
          Expanded(
            child: StreamBuilder<List<Cita>>(
              stream: repo.watchFirmasEnviadas(
                sortColumn: _sortKeys[_sortColumnIndex ?? 0],
                ascending: _sortAscending,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final citas = snapshot.data!;
                if (citas.isEmpty) {
                  return const Center(child: Text('No hay firmas enviadas.'));
                }

                return _FirmasTable(
                  citas: citas,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: _onSort,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FirmasTable extends StatelessWidget {
  final List<Cita> citas;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int, bool) onSort;
  const _FirmasTable({
    required this.citas,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.md),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth = constraints.maxWidth < AppSizes.tableMinWidth
                ? AppSizes.tableMinWidth
                : constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 600),
                    child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: sortAscending,
                    showCheckboxColumn: false,
                    headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.05)),
                    columns: [
                      const DataColumn(label: Text('#'), columnWidth: FixedColumnWidth(40)),
                      DataColumn(label: _headerWithSort('Nombre', 0, sortColumnIndex, sortAscending), columnWidth: const FlexColumnWidth(3), onSort: (i, asc) => onSort(0, !sortAscending)),
                      DataColumn(label: _headerWithSort('DPI', 1, sortColumnIndex, sortAscending), columnWidth: const FlexColumnWidth(2), onSort: (i, asc) => onSort(1, !sortAscending)),
                      DataColumn(label: _headerWithSort('Correo', 2, sortColumnIndex, sortAscending), columnWidth: const FlexColumnWidth(4), onSort: (i, asc) => onSort(2, !sortAscending)),
                      DataColumn(label: _headerWithSort('Fecha firma', 3, sortColumnIndex, sortAscending), columnWidth: const FlexColumnWidth(2), onSort: (i, asc) => onSort(3, !sortAscending)),
                      DataColumn(label: _headerWithSort('Estado', 4, sortColumnIndex, sortAscending), columnWidth: const FlexColumnWidth(1.5), onSort: (i, asc) => onSort(4, !sortAscending)),
                    ],
                    rows: citas.map((cita) {
                      final estado = CitaEstado.fromDb(cita.estado);
                      final fecha = DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma * 1000);
                      return DataRow(
                        onSelectChanged: (_) => CitaDetalleModal.show(context, cita.id),
                        cells: [
                          DataCell(Text('${citas.indexOf(cita) + 1}', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(cita.personaNombre, style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(Text(cita.personaDpi ?? '—')),
                          DataCell(Text(cita.personaCorreo)),
                          DataCell(Text(dateFmt.format(fecha))),
                          DataCell(_EstadoBadge(estado: estado)),
                        ],
                      );
                    }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _headerWithSort(String label, int index, int? activeIndex, bool ascending) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      const SizedBox(width: 4),
      Icon(
        activeIndex == index
            ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
            : Icons.unfold_more,
        size: 14,
        color: activeIndex == index ? AppColors.primary : Colors.grey.shade400,
      ),
    ],
  );
}

class _EstadoBadge extends StatelessWidget {
  final CitaEstado estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: estado.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.sm),
        border: Border.all(color: estado.color.withValues(alpha: 0.5)),
      ),
      child: Text(estado.label, style: TextStyle(color: estado.color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
