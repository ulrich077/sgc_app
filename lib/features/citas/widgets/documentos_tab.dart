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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expediente de Documentos', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('Gestiona los archivos escaneados y contratos de esta cita.', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md)),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Subir Documento'),
                    onPressed: auth.userId == null ? null : () => _subir(context, ref, auth.userId!),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),
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
                    return _EmptyState(onSubir: () {
                      if (auth.userId != null) _subir(context, ref, auth.userId!);
                    });
                  }
                  return Wrap(
                    spacing: AppSizes.md,
                    runSpacing: AppSizes.md,
                    children: docs.map((d) => _DocumentoCard(
                      doc: d,
                      onEliminar: () => _eliminar(context, ref, d.id, auth.userId!),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _subir(BuildContext context, WidgetRef ref, int userId) async {
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
      await repo.subirDocumento(citaId: citaId, tipo: tipo, archivo: File(picked.first.path!), userId: userId);
      if (!context.mounted) return;
      await AppDialogs.success(context, 'Documento subido correctamente.');
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
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DocumentoTipo.values
              .map((t) => ListTile(
                    leading: const Icon(Icons.description, color: AppColors.primary),
                    title: Text(t.label),
                    onTap: () => Navigator.of(ctx).pop(t),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref, int docId, int userId) async {
    final ok = await AppDialogs.confirm(context, '¿Estás seguro de que deseas eliminar este documento? Esta acción no se puede deshacer.', title: 'Eliminar Documento');
    if (!ok || !context.mounted) return;
    try {
      await ref.read(documentosRepositoryProvider).eliminar(docId, userId);
      if (!context.mounted) return;
      await AppDialogs.success(context, 'Documento eliminado.');
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'No se pudo eliminar: $e');
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onSubir;
  const _EmptyState({required this.onSubir});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.lg),
        border: Border.all(color: AppColors.border, width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_upload_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSizes.lg),
          Text('No hay documentos en el expediente', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: AppSizes.sm),
          const Text('Sube el Post Mortem, la Contraloría, o los escaneos firmados\npara completar la gestión de esta cita.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: AppSizes.xl),
          FilledButton.icon(
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.lg)),
            icon: const Icon(Icons.upload),
            label: const Text('Subir el primer documento'),
            onPressed: onSubir,
          ),
        ],
      ),
    );
  }
}

class _DocumentoCard extends StatelessWidget {
  final Documento doc;
  final VoidCallback onEliminar;
  const _DocumentoCard({required this.doc, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final tipo = DocumentoTipo.fromDb(doc.tipo);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final sizeKb = doc.tamanoBytes != null ? (doc.tamanoBytes! / 1024).toStringAsFixed(1) : '?';
    final isPdf = doc.nombre.toLowerCase().endsWith('.pdf');

    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.md),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: (isPdf ? Colors.red : Colors.blue).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.sm),
                ),
                child: Icon(isPdf ? Icons.picture_as_pdf : Icons.image, color: isPdf ? Colors.red : Colors.blue),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(tipo.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                onPressed: onEliminar,
                tooltip: 'Eliminar',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(doc.nombre, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$sizeKb KB', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(dateFmt.format(DateTime.fromMillisecondsSinceEpoch(doc.subidoAt)), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
