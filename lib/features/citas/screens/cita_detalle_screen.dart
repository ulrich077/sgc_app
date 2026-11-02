import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../data/eventos_repository.dart';
import '../domain/cita_estado.dart';
import '../widgets/acciones_tab.dart';
import '../widgets/datos_tab.dart';
import '../widgets/documentos_tab.dart';

final citaPorIdProvider = StreamProvider.family<Cita?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.citas)..where((t) => t.id.equals(id))).watchSingleOrNull();
});

class CitaDetalleScreen extends ConsumerWidget {
  final int citaId;
  const CitaDetalleScreen({super.key, required this.citaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citaAsync = ref.watch(citaPorIdProvider(citaId));

    return citaAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (cita) {
        if (cita == null) return const Scaffold(body: Center(child: Text('Cita no encontrada')));
        final estado = CitaEstado.fromDb(cita.estado);

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text(cita.personaNombre),
              bottom: TabBar(
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline), text: 'Datos'),
                  Tab(icon: Icon(Icons.playlist_add_check), text: 'Acciones'), // <-- Movido
                  Tab(icon: Icon(Icons.folder_outlined), text: 'Documentos'), // <-- Movido
                  Tab(icon: Icon(Icons.history), text: 'Historial'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                DatosTab(cita: cita, estado: estado),
                AccionesTab(cita: cita), // <-- Movido
                DocumentosTab(citaId: cita.id), // <-- Movido
                _HistorialTab(citaId: cita.id),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistorialTab extends ConsumerWidget {
  final int citaId;
  const _HistorialTab({required this.citaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(eventosRepositoryProvider);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return StreamBuilder<List<EventosCitaData>>(
      stream: repo.watchPorCita(citaId),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final eventos = snap.data!;
        
        if (eventos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay historial registrado aún.', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.xl),
          itemCount: eventos.length,
          itemBuilder: (context, i) {
            final e = eventos[i];
            // REGLA VI: Multiplicamos por 1000 para Flutter
            final fecha = DateTime.fromMillisecondsSinceEpoch(e.createdAt * 1000);
            
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Mostrar los detalles si existen
                  if (e.detalleJson != null && e.detalleJson!.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(e.tipoEvento.replaceAll('_', ' ').toUpperCase()),
                        content: SingleChildScrollView(
                          child: Text(
                            e.detalleJson!,
                            style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
                        ],
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.tipoEvento.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFmt.format(fecha),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            if (e.detalleJson != null && e.detalleJson!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Toca para ver detalles', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
