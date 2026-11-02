import 'dart:convert';
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
                      Tab(icon: Icon(Icons.playlist_add_check), text: 'Acciones'),
                      Tab(icon: Icon(Icons.folder_outlined), text: 'Documentos'),
                      Tab(icon: Icon(Icons.history), text: 'Historial'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        DatosTab(cita: cita, estado: estado),
                        AccionesTab(cita: cita),
                        DocumentosTab(citaId: cita.id),
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
            final fecha = DateTime.fromMillisecondsSinceEpoch(e.createdAt * 1000);
            
            String titulo = 'Evento';
            String subtitulo = '';
            IconData icono = Icons.check;
            Color colorIcono = AppColors.primary;
            Map<String, dynamic>? detalleMap;

            if (e.detalleJson != null && e.detalleJson!.isNotEmpty) {
              try {
                detalleMap = jsonDecode(e.detalleJson!) as Map<String, dynamic>;
              } catch (_) {}
            }

            switch (e.tipoEvento) {
              case 'cambio_estado':
                titulo = 'Cambio de Estado';
                if (detalleMap != null) {
                  subtitulo = "De ${detalleMap['anterior']} a ${detalleMap['nuevo']}";
                }
                break;
              case 'post_mortem_subido':
                titulo = 'Post Mortem Subido';
                subtitulo = 'El documento físico fue agregado.';
                break;
              case 'post_mortem_eliminado':
                titulo = 'Post Mortem Eliminado';
                subtitulo = 'El documento físico fue eliminado.';
                break;
              case 'contraloria_subida':
                titulo = 'Contraloría Subida';
                subtitulo = 'El documento físico fue agregado.';
                break;
              case 'contraloria_eliminada':
                titulo = 'Contraloría Eliminada';
                subtitulo = 'El documento físico fue eliminado.';
                break;
              case 'responsabilidad_subida':
                titulo = 'Documento de Responsabilidad Subido';
                subtitulo = 'El documento firmado fue agregado.';
                break;
              case 'responsabilidad_eliminada':
                titulo = 'Documento de Responsabilidad Eliminado';
                subtitulo = 'El documento firmado fue eliminado.';
                break;
              case 'contrato_subido':
                titulo = 'Contrato Firmado Subido';
                subtitulo = 'El contrato firmado fue agregado.';
                break;
              case 'contrato_eliminado':
                titulo = 'Contrato Firmado Eliminado';
                subtitulo = 'El contrato firmado fue eliminado.';
                break;
              case 'error_envio_correo':
                titulo = 'Error de Envío de Correo';
                subtitulo = 'No se pudo enviar el correo. Revisar detalles.';
                icono = Icons.error;
                colorIcono = Colors.red;
                break;
              default:
                titulo = e.tipoEvento.replaceAll('_', ' ').toUpperCase();
            }

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: detalleMap != null ? () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(titulo),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: detalleMap!.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key.toUpperCase()}: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value.toString(),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
                      ],
                    ),
                  );
                } : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorIcono.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icono, color: colorIcono, size: 16),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titulo,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (subtitulo.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(subtitulo, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              dateFmt.format(fecha),
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (detalleMap != null) const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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
