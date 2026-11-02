import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  return (db.select(db.citas)..where((t) => t.id.equals(id)))
      .watchSingleOrNull();
});

class CitaDetalleScreen extends ConsumerWidget {
  final int citaId;
  const CitaDetalleScreen({super.key, required this.citaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citaAsync = ref.watch(citaPorIdProvider(citaId));

    return citaAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Cita')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (cita) {
        if (cita == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cita')),
            body: const Center(child: Text('Cita no encontrada')),
          );
        }
        final estado = CitaEstado.fromDb(cita.estado);

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => context.pop(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cita.personaNombre),
                  Text(
                    estado.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: estado.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: AppColors.textPrimary,
              bottom: const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: [
                  Tab(icon: Icon(Icons.info_outline), text: 'Datos'),
                  Tab(icon: Icon(Icons.folder_outlined), text: 'Documentos'),
                  Tab(icon: Icon(Icons.checklist), text: 'Acciones'),
                  Tab(icon: Icon(Icons.history), text: 'Historial'),
                ],
              ),
            ),
            body: Container(
              color: AppColors.background,
              child: TabBarView(
                children: [
                  DatosTab(cita: cita, estado: estado),
                  DocumentosTab(citaId: cita.id),
                  AccionesTab(cita: cita),
                  _HistorialTab(citaId: cita.id),
                ],
              ),
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
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final eventos = snap.data!;
        
        if (eventos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: AppColors.primary.withValues(alpha: 0.2)),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Sin historial registrado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'Los cambios de estado y acciones de esta cita\naparecerán aquí automáticamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: eventos.map((e) => _TimelineCard(evento: e, dateFmt: dateFmt)).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final EventosCitaData evento;
  final DateFormat dateFmt;

  const _TimelineCard({required this.evento, required this.dateFmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.tipoEvento.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  evento.detalleJson ?? 'Sin detalles adicionales.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            dateFmt.format(DateTime.fromMillisecondsSinceEpoch(evento.createdAt)),
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
