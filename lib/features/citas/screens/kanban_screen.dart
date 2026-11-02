import 'package:drift/drift.dart' show OrderingTerm, OrderingMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/database/app_database.dart';
import '../data/citas_repository.dart';
import '../domain/cita_estado.dart';
import '../widgets/cita_detalle_modal.dart';

class KanbanScreen extends ConsumerWidget {
  const KanbanScreen({super.key});

  static const _columnas = [
    CitaEstado.citaCreada,
    CitaEstado.firmado,
    CitaEstado.documentoSubido,
    CitaEstado.pendienteEnvioContrato,
    CitaEstado.contratoEnviado,
    CitaEstado.cerrada,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    final stream = (db.select(db.citas)
          ..where((t) => t.isDelete.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.fechaHoraFirma, mode: OrderingMode.asc)
          ]))
        .watch();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: const Text('Kanban (Flujo de Citas)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const AppPageHeader(
            title: 'Kanban',
            subtitle: 'Arrastra las tarjetas para avanzar en el flujo.',
          ),
          Expanded(
            child: StreamBuilder<List<Cita>>(
              stream: stream,
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final citas = snap.data!;
                final grouped = <CitaEstado, List<Cita>>{};
                for (final e in _columnas) {
                  grouped[e] = [];
                }
                for (final c in citas) {
                  final e = CitaEstado.fromDb(c.estado);
                  if (grouped.containsKey(e)) grouped[e]!.add(c);
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _columnas.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSizes.md),
                        child: SizedBox(
                          width: 300,
                          child: _KanbanColumn(estado: e, citas: grouped[e] ?? []),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanColumn extends ConsumerWidget {
  final CitaEstado estado;
  final List<Cita> citas;
  const _KanbanColumn({required this.estado, required this.citas});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<Cita>(
      onWillAcceptWithDetails: (details) {
        final cita = details.data;
        final currentEstado = CitaEstado.fromDb(cita.estado);
        return currentEstado.nextStates.contains(estado);
      },
      onAcceptWithDetails: (details) async {
        final cita = details.data;
        final auth = ref.read(authProvider);
        if (auth.userId == null) return;

        final ok = await AppDialogs.confirm(
          context,
          '¿Mover la cita de "${cita.personaNombre}" a "${estado.label}"?',
        );
        if (!ok || !context.mounted) return;

        try {
          await ref.read(citasRepositoryProvider).cambiarEstado(
                citaId: cita.id,
                nuevoEstado: estado,
                userId: auth.userId!,
              );
          if (!context.mounted) return;
          AppDialogs.success(context, 'Estado actualizado.');
        } catch (e) {
          if (!context.mounted) return;
          AppDialogs.error(context, 'No se pudo actualizar: $e');
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isHovering ? estado.color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(
              color: isHovering ? estado.color : Colors.grey.shade200,
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: estado.color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        estado.label,
                        style: TextStyle(fontWeight: FontWeight.bold, color: estado.color),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: estado.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${citas.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: citas.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('Suelta aquí', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                            )
                          ]
                        : citas.map((c) => _KanbanCard(cita: c)).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

    final cardContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => CitaDetalleModal.show(context, cita.id),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(cita.personaNombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    if (next.isNotEmpty)
                      Icon(Icons.drag_indicator, size: 16, color: Colors.grey.shade400),
                  ],
                ),
                const SizedBox(height: 4),
                Text(cita.personaCorreo, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      dateFmt.format(DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma * 1000)),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (next.isEmpty) return cardContent;

    return Draggable<Cita>(
      data: cita,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 280,
          child: Opacity(opacity: 0.9, child: cardContent),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: cardContent),
      child: cardContent,
    );
  }
}
