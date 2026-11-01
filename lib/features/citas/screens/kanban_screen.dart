import 'package:drift/drift.dart' show OrderingTerm, OrderingMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/responsive.dart';
import '../../../data/database/app_database.dart';
import '../data/citas_repository.dart';
import '../domain/cita_estado.dart';

class KanbanScreen extends ConsumerWidget {
  const KanbanScreen({super.key});

  /// Estados que se muestran como columnas (los finales no van al Kanban).
  static const _columnas = [
    CitaEstado.citaCreada,
    CitaEstado.correoConfirmado,
    CitaEstado.enEsperaFirma,
    CitaEstado.firmado,
    CitaEstado.documentoSubido,
    CitaEstado.pendienteEnvioContrato,
    CitaEstado.contratoEnviado,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final isMobile = Responsive.isMobile(context);

    // Stream reactivo de todas las citas activas (no finales)
    final stream = (db.select(db.citas)
          ..where((t) => t.isDelete.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.fechaHoraFirma, mode: OrderingMode.asc)
          ]))
        .watch();

    return Scaffold(
      appBar: AppBar(title: const Text('Kanban')),
      body: ListView(
        children: [
          const AppPageHeader(
            title: 'Kanban',
            subtitle: 'Flujo de estados de las citas',
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
              final citas = snap.data!;
              final grouped = <CitaEstado, List<Cita>>{};
              for (final e in _columnas) {
                grouped[e] = [];
              }
              for (final c in citas) {
                final e = CitaEstado.fromDb(c.estado);
                grouped[e]?.add(c);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePadding),
                child: isMobile
                    ? Column(
                        children: _columnas
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSizes.lg),
                                  child: _KanbanColumn(
                                    estado: e,
                                    citas: grouped[e] ?? [],
                                  ),
                                ))
                            .toList(),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _columnas
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(
                                        right: AppSizes.md),
                                    child: SizedBox(
                                      width: 280,
                                      child: _KanbanColumn(
                                        estado: e,
                                        citas: grouped[e] ?? [],
                                      ),
                                    ),
                                  ))
                              .toList(),
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
}

class _KanbanColumn extends StatelessWidget {
  final CitaEstado estado;
  final List<Cita> citas;
  const _KanbanColumn({required this.estado, required this.citas});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: estado.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSizes.md),
        border: Border.all(color: estado.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: estado.color.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.md)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    estado.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: estado.color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: estado.color,
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                  ),
                  child: Text(
                    '${citas.length}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          if (citas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Center(
                child: Text('Sin citas',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ...citas.map((c) => _KanbanCard(cita: c)),
        ],
      ),
    );
  }
}

class _KanbanCard extends ConsumerWidget {
  final Cita cita;
  const _KanbanCard({required this.cita});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFmt = DateFormat('dd/MM HH:mm');
    final estado = CitaEstado.fromDb(cita.estado);
    final next = estado.nextStates;

    return Card(
      margin: const EdgeInsets.all(AppSizes.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.sm),
        onTap: () => context.push('/citas/${cita.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cita.personaNombre,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.xs),
              Text(cita.personaCorreo,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSizes.xs),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    dateFmt.format(DateTime.fromMillisecondsSinceEpoch(
                        cita.fechaHoraFirma)),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              if (next.isNotEmpty) ...[
                const SizedBox(height: AppSizes.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<CitaEstado>(
                    tooltip: 'Cambiar estado',
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    onSelected: (nuevo) => _cambiarEstado(context, ref, nuevo),
                    itemBuilder: (_) => next
                        .map((e) => PopupMenuItem<CitaEstado>(
                              value: e,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: e.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  Text(e.label),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cambiarEstado(
      BuildContext context, WidgetRef ref, CitaEstado nuevo) async {
    final auth = ref.read(authProvider);
    if (auth.userId == null) return;
    final ok = await AppDialogs.confirm(
      context,
      '¿Cambiar estado de "${cita.personaNombre}" a "${nuevo.label}"?',
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(citasRepositoryProvider).cambiarEstado(
            citaId: cita.id,
            nuevoEstado: nuevo,
            userId: auth.userId!,
          );
      if (!context.mounted) return;
      await AppDialogs.success(context, 'Estado actualizado.');
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'No se pudo actualizar: $e');
    }
  }
}
