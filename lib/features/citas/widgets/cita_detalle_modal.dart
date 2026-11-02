import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../data/eventos_repository.dart';
import '../domain/cita_estado.dart';
import 'acciones_tab.dart';
import 'datos_tab.dart';
import 'documentos_tab.dart';

final citaPorIdModalProvider = StreamProvider.family<Cita?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.citas)..where((t) => t.id.equals(id))).watchSingleOrNull();
});

class CitaDetalleModal extends ConsumerWidget {
  final int citaId;
  const CitaDetalleModal({super.key, required this.citaId});

  static Future<void> show(BuildContext context, int citaId) {
    return showDialog(
      context: context,
      builder: (_) => CitaDetalleModal(citaId: citaId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citaAsync = ref.watch(citaPorIdModalProvider(citaId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 900,
        height: 700,
        color: Colors.white,
        child: citaAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (cita) {
            if (cita == null) return const Center(child: Text('Cita no encontrada'));
            final estado = CitaEstado.fromDb(cita.estado);

            return DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Text(cita.personaNombre[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cita.personaNombre, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(estado.label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  const TabBar(
                    labelColor: AppColors.primary,
                    indicatorColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: [
                      Tab(icon: Icon(Icons.info_outline), text: 'Datos'),
                      Tab(icon: Icon(Icons.playlist_add_check), text: 'Acciones'), // <-- Movido
                      Tab(icon: Icon(Icons.folder_outlined), text: 'Documentos'), // <-- Movido
                      Tab(icon: Icon(Icons.history), text: 'Historial'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        DatosTab(cita: cita, estado: estado),
                        AccionesTab(cita: cita), // <-- Movido
                        DocumentosTab(citaId: cita.id), // <-- Movido
                        _HistorialTab(citaId: cita.id),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HistorialTab extends ConsumerWidget {
  final int citaId;
  const _HistorialTab({required this.citaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = EventosRepository(ref.watch(databaseProvider));
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    return StreamBuilder<List<dynamic>>(
      stream: repo.watchPorCita(citaId),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final eventos = snap.data!;
        if (eventos.isEmpty) return const Center(child: Text('No hay historial.'));
        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.xl),
          itemCount: eventos.length,
          itemBuilder: (context, i) {
            final e = eventos[i];
            return ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.primary),
              title: Text(e.tipoEvento),
              subtitle: Text(dateFmt.format(DateTime.fromMillisecondsSinceEpoch(e.createdAt * 1000))),
            );
          },
        );
      },
    );
  }
}
