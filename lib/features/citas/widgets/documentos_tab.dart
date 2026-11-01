import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/dialogs.dart';
import '../../../data/database/app_database.dart';
import '../../documentos/data/documentos_repository.dart';
import '../../documentos/domain/documento_tipo.dart';

class DocumentosTab extends ConsumerWidget {
  final int citaId;
  const DocumentosTab({super.key, required this.citaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(documentosRepositoryProvider);
    final auth = ref.watch(authProvider);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Documentos de la cita',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Subir'),
              onPressed: auth.userId == null
                  ? null
                  : () => _subir(context, ref, auth.userId!),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        StreamBuilder<List<Documento>>(
          stream: repo.watchPorCita(citaId),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.xl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final docs = snap.data!;
            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.xl),
                child: Center(child: Text('Sin documentos subidos.')),
              );
            }
            return Card(
              child: Column(
                children: docs.map((d) {
                  final tipo = DocumentoTipo.fromDb(d.tipo);
                  return ListTile(
                    leading: const Icon(Icons.description,
                        color: AppColors.primary),
                    title: Text(d.nombre),
                    subtitle: Text(
                      '${tipo.label} — ${dateFmt.format(DateTime.fromMillisecondsSinceEpoch(d.subidoAt))}'
                      '${d.tamanoBytes != null ? ' (${(d.tamanoBytes! / 1024).toStringAsFixed(1)} KB)' : ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Abrir',
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _abrir(d),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.danger),
                          onPressed: () =>
                              _eliminar(context, ref, d.id, auth.userId!),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _subir(
      BuildContext context, WidgetRef ref, int userId) async {
    final tipo = await _elegirTipo(context);
    if (tipo == null || !context.mounted) return;

    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (picked.isEmpty || picked.first.path == null) return;
    if (!context.mounted) return;

    try {
      final repo = ref.read(documentosRepositoryProvider);
      await repo.subirDocumento(
        citaId: citaId,
        tipo: tipo,
        archivo: File(picked.first.path!),
        userId: userId,
      );
      if (!context.mounted) return;
      await AppDialogs.success(context, 'Documento subido.');
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'No se pudo subir: $e');
    }
  }

  Future<DocumentoTipo?> _elegirTipo(BuildContext context) async {
    return showDialog<DocumentoTipo>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tipo de documento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DocumentoTipo.values
              .map((t) => ListTile(
                    title: Text(t.label),
                    onTap: () => Navigator.of(ctx).pop(t),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _abrir(Documento d) {
    // En desktop, abrir con el visor del sistema.
    Process.run('open', [d.rutaArchivo]);
  }

  Future<void> _eliminar(
      BuildContext context, WidgetRef ref, int docId, int userId) async {
    final ok = await AppDialogs.confirm(
      context,
      '¿Eliminar este documento?',
    );
    if (!ok || !context.mounted) return;
    try {
      await ref
          .read(documentosRepositoryProvider)
          .eliminar(docId, userId);
      if (!context.mounted) return;
      await AppDialogs.success(context, 'Documento eliminado.');
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'No se pudo eliminar: $e');
    }
  }
}
