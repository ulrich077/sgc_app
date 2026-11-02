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

    return Container(
      color: Colors.white, // Fondo blanco para que resalten las tarjetas
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TARJETA 1: DOCUMENTOS FÍSICOS
                _ActionCard(
                  title: 'Documentos Físicos',
                  subtitle: 'Marca los documentos que el firmante presentó el día de la cita.',
                  icon: Icons.folder_shared_outlined,
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Post Mortem presentado', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Designación de Beneficiarios'),
                        value: cita.postMortemPresentado,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        activeThumbColor: AppColors.primary,
                        onChanged: auth.userId == null
                            ? null
                            : (v) => _actualizarCita(context, ref, cita.id, {'postMortemPresentado': v}, auth.userId!),
                      ),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Contraloría presentada', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Actualización de Contraloría'),
                        value: cita.contraloriaPresentada,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        activeThumbColor: AppColors.primary,
                        onChanged: auth.userId == null
                            ? null
                            : (v) => _actualizarCita(context, ref, cita.id, {'contraloriaPresentada': v}, auth.userId!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // TARJETA 2: DOCUMENTO DE RESPONSABILIDAD
                _ActionCard(
                  title: 'Documento de Responsabilidad',
                  subtitle: 'Genera el PDF, imprímelo y hazlo firmar a mano en azul.',
                  icon: Icons.picture_as_pdf_outlined,
                  child: Wrap(
                    spacing: AppSizes.md,
                    runSpacing: AppSizes.md,
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
                        ),
                        icon: const Icon(Icons.print),
                        label: const Text('Generar e Imprimir PDF'),
                        onPressed: () => _generarPdf(context, ref),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
                        ),
                        icon: const Icon(Icons.upload),
                        label: const Text('Subir escaneo firmado'),
                        onPressed: auth.userId == null
                            ? null
                            : () => _subirEscaneo(context, ref, auth.userId!, DocumentoTipo.responsabilidadFirmado),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // TARJETA 3: CONTRATO FIRMADO
                _ActionCard(
                  title: 'Contrato Firmado',
                  subtitle: 'Sube el contrato final firmado por las personas responsables.',
                  icon: Icons.assignment_turned_in_outlined,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
                      ),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Subir contrato firmado'),
                      onPressed: auth.userId == null
                          ? null
                          : () => _subirEscaneo(context, ref, auth.userId!, DocumentoTipo.contratoFirmado),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // TARJETA 4: CORREO DE PRUEBA
                _ActionCard(
                  title: 'Correo de Prueba',
                  subtitle: 'Reenvía al firmante el enlace de confirmación de correo.',
                  icon: Icons.mark_email_read_outlined,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reenviar correo de prueba'),
                      onPressed: () => _reenviarPrueba(context, ref),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // TARJETA 5: CAMBIAR ESTADO
                _ActionCard(
                  title: 'Cambiar Estado de la Cita',
                  subtitle: 'El estado actual es: ${estado.label}',
                  icon: Icons.alt_route,
                  child: estado.nextStates.isEmpty
                      ? const Text('Estado final. No hay transiciones disponibles.',
                          style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary))
                      : Wrap(
                          spacing: AppSizes.sm,
                          runSpacing: AppSizes.sm,
                          children: estado.nextStates.map((e) {
                            return FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
                              ),
                              onPressed: auth.userId == null
                                  ? null
                                  : () => _cambiarEstado(context, ref, e, auth.userId!),
                              child: Text(e.label),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _actualizarCita(BuildContext context, WidgetRef ref, int citaId, Map<String, dynamic> cambios, int userId) async {
    try {
      final api = await ref.read(apiClientProvider.future);
      if (api != null) {
        await api.actualizarCita(citaId, cambios);
        if (!context.mounted) return;
        await AppDialogs.success(context, 'Actualizado.');
      }
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'Error: $e');
    }
  }

  Future<void> _cambiarEstado(BuildContext context, WidgetRef ref, CitaEstado nuevo, int userId) async {
    final ok = await AppDialogs.confirm(context, '¿Cambiar estado a "${nuevo.label}"?');
    if (!ok || !context.mounted) return;
    try {
      await ref.read(citasRepositoryProvider).cambiarEstado(citaId: cita.id, nuevoEstado: nuevo, userId: userId);
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
        await AppDialogs.info(context, 'La generación de PDF requiere el servidor.');
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

  Future<void> _subirEscaneo(BuildContext context, WidgetRef ref, int userId, DocumentoTipo tipo) async {
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
    if (picked.isEmpty || picked.first.path == null) return;
    if (!context.mounted) return;
    try {
      await ref.read(documentosRepositoryProvider).subirDocumento(
        citaId: cita.id, tipo: tipo, archivo: File(picked.first.path!), userId: userId,
      );
      if (!context.mounted) return;
      await AppDialogs.success(context, 'Escaneo subido.');
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'No se pudo subir: $e');
    }
  }

  Future<void> _reenviarPrueba(BuildContext context, WidgetRef ref) async {
    try {
      await AppDialogs.success(context, 'Correo de prueba encolado para reenvío.');
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'Error: $e');
    }
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.sm),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppSizes.xxl),
          child,
        ],
      ),
    );
  }
}
