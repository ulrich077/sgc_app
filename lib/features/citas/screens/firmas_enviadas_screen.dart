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

class FirmasEnviadasScreen extends ConsumerWidget {
  const FirmasEnviadasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              stream: repo.watchFirmasEnviadas(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final citas = snapshot.data!;
                if (citas.isEmpty) {
                  return const Center(child: Text('No hay firmas enviadas.'));
                }

                return _FirmasTable(citas: citas);
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
  const _FirmasTable({required this.citas});

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
            final tableWidth = constraints.maxWidth;
            return ConstrainedBox(
              constraints: BoxConstraints(minWidth: tableWidth, maxHeight: 600),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showCheckboxColumn: false,
                    headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.05)),
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('DPI')),
                      DataColumn(label: Text('Correo')),
                      DataColumn(label: Text('Fecha firma')),
                      DataColumn(label: Text('Estado')),
                    ],
                    rows: citas.map((cita) {
                      final estado = CitaEstado.fromDb(cita.estado);
                      final fecha = DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma * 1000);
                      return DataRow(
                        onSelectChanged: (_) => CitaDetalleModal.show(context, cita.id),
                        cells: [
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
            );
          },
        ),
      ),
    );
  }
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
