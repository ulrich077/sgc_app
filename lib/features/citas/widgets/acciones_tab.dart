import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/sync_provider.dart';
import '../../../core/utils/dialogs.dart';
import '../../../data/database/app_database.dart';
import '../../documentos/data/documentos_repository.dart';
import '../../documentos/domain/documento_tipo.dart';
import '../data/citas_repository.dart';
import '../domain/cita_estado.dart';

class AccionesTab extends ConsumerWidget {
  final Cita cita;
  const AccionesTab({super.key, required this.cita});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = CitaEstado.fromDb(cita.estado);
    final auth = ref.watch(authProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Documentos físicos',
                    style: Theme.of(context).textTheme.titleMedium),
                SwitchListTile(
                  title: const Text('Post Mortem presentado'),
                  subtitle: const Text(
                      'Designación de Beneficiarios presentada'),
                  value: cita.postMortemPresentado,
                  onChanged: auth.userId == null
                      ? null
                      : (v) => _actualizarCita(
                            context,
                            ref,
                            cita.id,
                            {'postMortemPresentado': v},
                            auth.userId!,
                          ),
                ),
                SwitchListTile(
                  title: const Text('Contraloría presentada'),
                  subtitle: const Text('Actualización de Contraloría'),
                  value: cita.contraloriaPresentada,
                  onChanged: auth.userId == null
                      ? null
                      : (v) => _actualizarCita(
                            context,
                            ref,
                            cita.id,
                            {'contraloriaPresentada': v},
                            auth.userId!,
                          ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Documento de Responsabilidad',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  '1. Genera y visualiza el PDF.\n'
                  '2. Imprímelo y hazlo firmar a mano en azul.\n'
                  '3. Escanea el documento firmado y súbelo.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: AppSizes.md),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Generar PDF'),
                      onPressed: () => _generarPdf(context, ref),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Subir escaneo firmado'),
                      onPressed: auth.userId == null
                          ? null
                          : () => _subirEscaneo(
                                context,
                                ref,
                                auth.userId!,
                                DocumentoTipo.responsabilidadFirmado,
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contrato firmado',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'Sube el contrato firmado por las personas responsables.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: AppSizes.md),
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Subir contrato firmado'),
                  onPressed: auth.userId == null
                      ? null
                      : () => _subirEscaneo(
                            context,
                            ref,
                            auth.userId!,
                            DocumentoTipo.contratoFirmado,
                          ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cambiar estado',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSizes.sm),
                Text('Estado actual: ${estado.label}'),
                const SizedBox(height: AppSizes.md),
                if (estado.nextStates.isEmpty)
                  const Text('Estado final. No hay transiciones disponibles.',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary))
                else
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: estado.nextStates
                        .map((e) => FilledButton.tonal(
                              onPressed: auth.userId == null
                                  ? null
                                  : () => _cambiarEstado(
                                      context, ref, e, auth.userId!),
                              child: Text(e.label),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.xl),
      ],
    );
  }

  Future<void> _actualizarCita(
    BuildContext context,
    WidgetRef ref,
    int citaId,
    Map<String, dynamic> cambios,
    int userId,
  ) async {
    try {
      final api = await ref.read(apiClientProvider.future);
      if (api != null) {
        await api.actualizarCita(citaId, cambios);
        if (!context.mounted) return;
        await AppDialogs.success(context, 'Actualizado.');
      } else {
        // Servidor: actualizar directo con Drift (el notifier hará el broadcast)
        // Aún no hay endpoint para actualizar campos booleanos en servidor.
        if (!context.mounted) return;
        await AppDialogs.info(
          context,
          'Modo servidor: actualiza la cita desde la UI de escritorio del servidor. '
          'Próximamente se agregará el endpoint.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'Error: $e');
    }
  }

  Future<void> _cambiarEstado(BuildContext context, WidgetRef ref,
      CitaEstado nuevo, int userId) async {
    final ok = await AppDialogs.confirm(
      context,
      '¿Cambiar estado a "${nuevo.label}"?',
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(citasRepositoryProvider).cambiarEstado(
            citaId: cita.id,
            nuevoEstado: nuevo,
            userId: userId,
          );
      if (!context.mounted) return;
      await AppDialogs.success(context, 'Estado actualizado.');
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'Error: $e');
    }
  }

  Future<void> _generarPdf(BuildContext context, WidgetRef ref) async {
    try {
      final api = await ref.read(apiClientProvider.future);
      if (api == null) {
        if (!context.mounted) return;
        await AppDialogs.info(
          context,
          'La generación de PDF requiere el servidor. '
          'Configura la IP del servidor en ajustes.',
        );
        return;
      }
      final bytes = await api.descargarPdfResponsabilidad(cita.id);
      if (!context.mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) async => Uint8List.fromList(bytes),
        name: 'documento_responsabilidad_${cita.personaDpi ?? cita.id}.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'Error al generar PDF: $e');
    }
  }

  Future<void> _subirEscaneo(BuildContext context, WidgetRef ref,
      int userId, DocumentoTipo tipo) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (picked.isEmpty || picked.first.path == null) return;
    if (!context.mounted) return;
    try {
      await ref.read(documentosRepositoryProvider).subirDocumento(
            citaId: cita.id,
            tipo: tipo,
            archivo: File(picked.first.path!),
            userId: userId,
          );
      if (!context.mounted) return;
      await AppDialogs.success(context, 'Escaneo subido.');
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'No se pudo subir: $e');
    }
  }
}
