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
import 'documentos_tab.dart';

// PROVIDER GLOBAL PARA EL MODAL (Así evitamos el error de anidación)
final citaPorIdModalProvider = StreamProvider.family<Cita?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.citas)..where((t) => t.id.equals(id))).watchSingleOrNull();
});

class CitaDetalleModal extends ConsumerWidget {
  final int citaId;
  const CitaDetalleModal({super.key, required this.citaId});

  static void show(BuildContext context, int citaId) {
    showDialog(
      context: context,
      builder: (_) => CitaDetalleModal(citaId: citaId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citaAsync = ref.watch(citaPorIdModalProvider(citaId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.lg)),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.lg),
        ),
        child: citaAsync.when(
          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SizedBox(height: 200, child: Center(child: Text('Error: $e'))),
          data: (cita) {
            if (cita == null) return const SizedBox(height: 200, child: Center(child: Text('Cita no encontrada')));
            final estado = CitaEstado.fromDb(cita.estado);

            return DefaultTabController(
              length: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER DEL MODAL
                  Container(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.lg)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Text(
                            cita.personaNombre.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cita.personaNombre, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(estado.label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // TABS
                  Container(
                    color: Colors.white,
                    child: const TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: [
                        Tab(icon: Icon(Icons.info_outline), text: 'Datos'),
                        Tab(icon: Icon(Icons.folder_outlined), text: 'Documentos'),
                        Tab(icon: Icon(Icons.checklist), text: 'Acciones'),
                        Tab(icon: Icon(Icons.history), text: 'Historial'),
                      ],
                    ),
                  ),
                  // CONTENIDO
                  Expanded(
                    child: Container(
                      color: AppColors.background,
                      child: TabBarView(
                        children: [
                          _DatosTab(cita: cita, estado: estado),
                          DocumentosTab(citaId: cita.id),
                          AccionesTab(cita: cita),
                          _HistorialTab(citaId: cita.id),
                        ],
                      ),
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

class _DatosTab extends StatelessWidget {
  final Cita cita;
  final CitaEstado estado;

  const _DatosTab({required this.cita, required this.estado});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoCard(
                title: 'Información Personal',
                icon: Icons.person_outline,
                children: [
                  _field('DPI', cita.personaDpi ?? '—'),
                  _field('Correo Electrónico', cita.personaCorreo),
                  _field('Teléfono', cita.personaTelefono ?? '—'),
                ],
              ),
              const SizedBox(height: AppSizes.lg),
              _InfoCard(
                title: 'Detalles de la Cita',
                icon: Icons.event_note,
                children: [
                  _field('Fecha programada', dateFmt.format(DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma))),
                  _field('Post Mortem', cita.postMortemPresentado ? 'Sí' : 'No'),
                  _field('Contraloría', cita.contraloriaPresentada ? 'Sí' : 'No'),
                  if (cita.reagendadaVeces > 0) _field('Reagendada', '${cita.reagendadaVeces} veces'),
                  if (cita.motivoUltimaReagenda != null) _field('Motivo reagenda', cita.motivoUltimaReagenda!),
                ],
              ),
              if (cita.notas != null && cita.notas!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.lg),
                _InfoCard(
                  title: 'Notas Adicionales',
                  icon: Icons.sticky_note_2_outlined,
                  children: [Text(cita.notas!, style: const TextStyle(fontSize: 14))],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 180, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.lg),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSizes.sm),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const Divider(height: AppSizes.xl),
            ...children,
          ],
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
    final repo = ref.watch(eventosRepositoryProvider);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    
    return StreamBuilder<List<EventosCitaData>>(
      stream: repo.watchPorCita(citaId),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final eventos = snap.data!;
        
        if (eventos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: AppColors.primary.withValues(alpha: 0.2)),
                const SizedBox(height: AppSizes.lg),
                Text('Sin historial registrado', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: AppSizes.sm),
                const Text('Los cambios de estado y acciones de esta cita\naparecerán aquí automáticamente.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(children: eventos.map((e) => _TimelineCard(evento: e, dateFmt: dateFmt)).toList()),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSizes.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento.tipoEvento.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(evento.detalleJson ?? 'Sin detalles adicionales.', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Text(dateFmt.format(DateTime.fromMillisecondsSinceEpoch(evento.createdAt)), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
