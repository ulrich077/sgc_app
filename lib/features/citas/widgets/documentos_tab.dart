import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/database/app_database.dart';
import '../../documentos/data/documentos_repository.dart';
import '../../documentos/domain/documento_tipo.dart';

class DocumentosTab extends ConsumerStatefulWidget {
  final int citaId;
  const DocumentosTab({super.key, required this.citaId});

  @override
  ConsumerState<DocumentosTab> createState() => _DocumentosTabState();
}

class _DocumentosTabState extends ConsumerState<DocumentosTab> {
  Future<void> _mostrarOpcionesDocumento(Documento doc) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Opciones del Documento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new, color: AppColors.primary),
              title: const Text('Abrir Documento'),
              subtitle: const Text('Ver el archivo PDF en el visor'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = File(doc.rutaArchivo);
                if (await file.exists()) {
                  await launchUrl(Uri.file(doc.rutaArchivo));
                } else {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El archivo no existe.')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.orange),
              title: const Text('Abrir Carpeta'),
              subtitle: const Text('Ir a la ubicación del archivo en el disco'),
              onTap: () async {
                Navigator.pop(ctx);
                final dir = File(doc.rutaArchivo).parent.path;
                await launchUrl(Uri.file(dir));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('Ver Detalles'),
              subtitle: const Text('Ver tamaño, fecha y ruta'),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Detalles del Archivo'),
                    content: Text('Ruta: ${doc.rutaArchivo}\n\nTamaño: ${(doc.tamanoBytes ?? 0) / 1024} KB\n\nSubido el: ${doc.subidoAt}'),
                    actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cerrar'))],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(documentosRepositoryProvider);

    return StreamBuilder<List<Documento>>(
      stream: repo.watchPorCita(widget.citaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!;
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expediente de Documentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Subir Documento'),
                    onPressed: () async {
                       // Aquí podrías abrir un FilePicker
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: docs.isEmpty
                  ? const Center(child: Text('No hay documentos subidos.'))
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisExtent: 140,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        return InkWell(
                          onTap: () => _mostrarOpcionesDocumento(doc),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                        child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          DocumentoTipo.fromDb(doc.tipo).label,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(doc.nombre, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('${(doc.tamanoBytes ?? 0) / 1024} KB', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
