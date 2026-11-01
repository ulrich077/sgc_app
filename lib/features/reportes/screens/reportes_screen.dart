import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/responsive_kpis_row.dart';
import '../data/excel_service.dart';
import '../data/reportes_repository.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  DateTime? _desde;
  DateTime? _hasta;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(reportesRepositoryProvider);
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: ListView(
        children: [
          const AppPageHeader(
            title: 'Reportes',
            subtitle: 'Estadísticas y exportación de citas',
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_desde == null
                      ? 'Desde'
                      : dateFmt.format(_desde!)),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _desde ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => _desde = d);
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_hasta == null
                      ? 'Hasta'
                      : dateFmt.format(_hasta!)),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _hasta ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => _hasta = d);
                  },
                ),
                if (_desde != null || _hasta != null)
                  TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                    onPressed: () => setState(() {
                      _desde = null;
                      _hasta = null;
                    }),
                  ),
                FilledButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar Excel'),
                  onPressed: () => _exportar(repo),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: StreamBuilder<ReporteKpis>(
              stream: repo.watchKpis(desde: _desde, hasta: _hasta),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSizes.xl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final k = snap.data!;
                return ResponsiveKpisRow(
                  children: [
                    _KpiCard('Total', k.total, AppColors.primary),
                    _KpiCard('En proceso', k.creadas, AppColors.info),
                    _KpiCard(
                        'Pendiente envío', k.pendientesEnvio, AppColors.pendiente),
                    _KpiCard('Enviadas', k.enviadas, AppColors.enviada),
                    _KpiCard('Cerradas', k.cerradas, AppColors.success),
                    _KpiCard('Canceladas', k.canceladas, AppColors.danger),
                    _KpiCard('Reagendadas', k.reagendadas, AppColors.warning),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Future<void> _exportar(ReportesRepository repo) async {
    try {
      final citas = await repo.obtenerCitas(desde: _desde, hasta: _hasta);
      final dir = await getApplicationDocumentsDirectory();
      final nombre =
          'reporte_citas_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final ruta = p.join(dir.path, nombre);
      await ExcelService().generarCitas(citas: citas, rutaSalida: ruta);
      if (!mounted) return;
      final guardar = await AppDialogs.confirm(
        context,
        'Excel generado. ¿Deseas guardarlo en otra ubicación?',
        title: 'Exportación exitosa',
        confirmLabel: 'Elegir ubicación',
        cancelLabel: 'Solo cerrar',
      );
      if (guardar && mounted) {
        final destino = await FilePicker.getDirectoryPath();
        if (destino != null) {
          final nuevo = p.join(destino, nombre);
          await File(ruta).copy(nuevo);
          if (!mounted) return;
          await AppDialogs.success(context, 'Guardado en: $nuevo');
        }
      }
    } catch (e) {
      if (!mounted) return;
      await AppDialogs.error(context, 'Error al exportar: $e');
    }
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _KpiCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSizes.sm),
            Text('$value',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
