import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/dialogs.dart';
import '../../../data/database/app_database.dart';
import '../../documentos/data/documentos_repository.dart';
import '../../documentos/domain/documento_tipo.dart';
import '../data/citas_repository.dart';
import '../domain/cita_estado.dart';
import 'drop_zone.dart';

class AccionesTab extends ConsumerStatefulWidget {
  final Cita cita;
  const AccionesTab({super.key, required this.cita});

  @override
  ConsumerState<AccionesTab> createState() => _AccionesTabState();
}

class _AccionesTabState extends ConsumerState<AccionesTab> {
  bool _enviandoFinal = false;
  bool _finalEnviado = false;
  StreamSubscription? _subFinal;

  @override
  void dispose() {
    _subFinal?.cancel();
    super.dispose();
  }

  Future<void> _enviarCorreoFinal() async {
    setState(() { _enviandoFinal = true; _finalEnviado = false; });
    try {
      final db = ref.read(databaseProvider);
      final auth = ref.read(authProvider);
      final repo = CitasRepository(db);
      
      await repo.cambiarEstado(citaId: widget.cita.id, nuevoEstado: CitaEstado.contratoEnviado, userId: auth.userId ?? 1);

      _subFinal?.cancel();
      _subFinal = (db.select(db.correosLog)
            ..where((t) => t.citaId.equals(widget.cita.id) & t.tipo.equals('final_'))
            ..orderBy([(t) => OrderingTerm.desc(t.id)])..limit(1))
          .watchSingleOrNull().listen((correo) {
        if (correo != null && correo.estado == 'enviado') {
          if (mounted) {
            setState(() { _enviandoFinal = false; _finalEnviado = true; });
            AppDialogs.success(context, '¡Contrato y Documentos enviados exitosamente!');
          }
        }
      });
    } catch (e) {
      if (mounted) { setState(() => _enviandoFinal = false); AppDialogs.error(context, 'Error al enviar: $e'); }
    }
  }

  Future<void> _abrirPdf(String ruta) async {
    final file = File(ruta);
    if (await file.exists()) {
      await launchUrl(Uri.file(ruta));
    } else {
      if (mounted) AppDialogs.error(context, 'El archivo ya no existe en el disco.');
    }
  }

  Future<void> _generarYDescargarPdf(Cita cita) async {
    try {
      if (mounted) AppDialogs.info(context, 'Generando PDF en el servidor...');
      final db = ref.read(databaseProvider);
      final cfgRows = await db.select(db.configuracion).get();
      final cfg = {for (final r in cfgRows) r.clave: r.valor};
      final ip = cfg['es_servidor'] == 'true' ? '127.0.0.1' : (cfg['servidor_ip'] ?? '127.0.0.1');
      final puerto = cfg['servidor_puerto'] ?? '8080';
      final url = 'http://$ip:$puerto/api/citas/${cita.id}/pdf';
      
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        throw Exception('No se pudo abrir el enlace');
      }
    } catch (e) {
      if (mounted) AppDialogs.error(context, 'Error al generar PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cita = widget.cita;
    final estado = CitaEstado.fromDb(cita.estado);
    final auth = ref.watch(authProvider);
    final docsRepo = ref.watch(documentosRepositoryProvider);

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: StreamBuilder<List<Documento>>(
              stream: docsRepo.watchPorCita(cita.id),
              builder: (context, snapshot) {
                final docs = snapshot.data ?? [];
                
                // Buscamos si los documentos ya fueron subidos
                final hasPostMortem = docs.where((d) => d.tipo == DocumentoTipo.postMortemEscaneo.dbValue).firstOrNull;
                final hasContraloria = docs.where((d) => d.tipo == DocumentoTipo.contraloriaEscaneo.dbValue).firstOrNull;
                final hasResp = docs.where((d) => d.tipo == DocumentoTipo.responsabilidadFirmado.dbValue).firstOrNull;
                final hasContrato = docs.where((d) => d.tipo == DocumentoTipo.contratoFirmado.dbValue).firstOrNull;
                
                final bool paso1Completado = hasPostMortem != null && hasContraloria != null;
                final bool paso2Completado = hasResp != null;
                final bool paso3Completado = hasContrato != null;
                final bool procesoCompleto = paso1Completado && paso2Completado && paso3Completado;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PASO 1 (CON DROPZONE PROFESIONAL)
                    _ActionCard(
                      title: 'Paso 1: Documentos Físicos',
                      subtitle: 'Suba los escaneos del Post Mortem y la Contraloría.',
                      icon: Icons.assignment_turned_in_outlined,
                      isCompleted: paso1Completado,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Post Mortem
                          if (hasPostMortem == null)
                            DropZone(
                              titulo: 'Arrastra aquí el Post Mortem',
                              subtitulo: 'O haz clic para buscarlo. (PDF)',
                              icono: Icons.description,
                              onFileDropped: (path) async {
                                try {
                                  await docsRepo.subirDocumento(citaId: cita.id, tipo: DocumentoTipo.postMortemEscaneo, archivo: File(path), userId: auth.userId ?? 1);
                                  // Actualizar el switch en la DB a true automáticamente
                                  await CitasRepository(ref.read(databaseProvider)).cambiarCheckPostMortem(cita.id, true, auth.userId ?? 1);
                                  if (context.mounted) AppDialogs.success(context, 'Post Mortem subido.');
                                } catch (e) {
                                  if (context.mounted) AppDialogs.error(context, 'Error: $e');
                                }
                              },
                            )
                          else
                            _DocItem(
                              nombre: 'Post Mortem Escaneado', 
                              ruta: hasPostMortem.rutaArchivo,
                              onDownload: () => _abrirPdf(hasPostMortem.rutaArchivo),
                              onDelete: () async {
                                await docsRepo.eliminar(hasPostMortem.id, auth.userId ?? 1);
                                await CitasRepository(ref.read(databaseProvider)).cambiarCheckPostMortem(cita.id, false, auth.userId ?? 1);
                              },
                            ),

                          const SizedBox(height: AppSizes.lg),

                          // Contraloría
                          if (hasContraloria == null)
                            DropZone(
                              titulo: 'Arrastra aquí la Contraloría',
                              subtitulo: 'O haz clic para buscarla. (PDF)',
                              icono: Icons.description,
                              onFileDropped: (path) async {
                                try {
                                  await docsRepo.subirDocumento(citaId: cita.id, tipo: DocumentoTipo.contraloriaEscaneo, archivo: File(path), userId: auth.userId ?? 1);
                                  await CitasRepository(ref.read(databaseProvider)).cambiarCheckContraloria(cita.id, true, auth.userId ?? 1);
                                  if (context.mounted) AppDialogs.success(context, 'Contraloría subida.');
                                } catch (e) {
                                  if (context.mounted) AppDialogs.error(context, 'Error: $e');
                                }
                              },
                            )
                          else
                            _DocItem(
                              nombre: 'Contraloría Escaneada', 
                              ruta: hasContraloria.rutaArchivo,
                              onDownload: () => _abrirPdf(hasContraloria.rutaArchivo),
                              onDelete: () async {
                                await docsRepo.eliminar(hasContraloria.id, auth.userId ?? 1);
                                await CitasRepository(ref.read(databaseProvider)).cambiarCheckContraloria(cita.id, false, auth.userId ?? 1);
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // PASO 2
                    _ActionCard(
                      title: 'Paso 2: Documento de Responsabilidad',
                      subtitle: 'Descargue el documento, fírmelo y súbalo escaneado.',
                      icon: Icons.description_outlined,
                      isCompleted: paso2Completado,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text('Documento de Responsabilidad (PDF)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                ),
                                TextButton.icon(
                                  onPressed: () => _generarYDescargarPdf(cita),
                                  icon: const Icon(Icons.download, size: 18),
                                  label: const Text('Descargar'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          
                          if (hasResp == null)
                            DropZone(
                              titulo: 'Arrastra aquí el PDF Firmado',
                              subtitulo: 'Una vez firmado en papel, escanéelo y súbalo aquí.',
                              icono: Icons.upload_file,
                              onFileDropped: (path) async {
                                try {
                                  await docsRepo.subirDocumento(citaId: cita.id, tipo: DocumentoTipo.responsabilidadFirmado, archivo: File(path), userId: auth.userId ?? 1);
                                  if (context.mounted) AppDialogs.success(context, 'Documento subido.');
                                } catch (e) {
                                  if (context.mounted) AppDialogs.error(context, 'Error: $e');
                                }
                              },
                            )
                          else
                            _DocItem(
                              nombre: 'Documento de Responsabilidad Firmado', 
                              ruta: hasResp.rutaArchivo,
                              onDownload: () => _abrirPdf(hasResp.rutaArchivo),
                              onDelete: () async {
                                await docsRepo.eliminar(hasResp.id, auth.userId ?? 1);
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // PASO 3
                    _ActionCard(
                      title: 'Paso 3: Subir Contrato Firmado',
                      subtitle: 'Arrastra el contrato escaneado.',
                      icon: Icons.file_present,
                      isLocked: !paso2Completado,
                      isCompleted: paso3Completado,
                      child: !paso2Completado
                        ? _buildLockedMessage('Complete el Paso 2 para desbloquear.')
                        : (hasContrato == null
                            ? DropZone(
                                titulo: 'Arrastra aquí el Contrato Firmado',
                                subtitulo: 'Documento final escaneado.',
                                icono: Icons.file_present,
                                onFileDropped: (path) async {
                                  try {
                                    await docsRepo.subirDocumento(citaId: cita.id, tipo: DocumentoTipo.contratoFirmado, archivo: File(path), userId: auth.userId ?? 1);
                                    if (context.mounted) AppDialogs.success(context, 'Contrato subido.');
                                  } catch (e) {
                                    if (context.mounted) AppDialogs.error(context, 'Error: $e');
                                  }
                                },
                              )
                            : _DocItem(
                                nombre: 'Contrato Firmado', 
                                ruta: hasContrato.rutaArchivo,
                                onDownload: () => _abrirPdf(hasContrato.rutaArchivo),
                                onDelete: () async {
                                  await docsRepo.eliminar(hasContrato.id, auth.userId ?? 1);
                                },
                              )),
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // PASO 4
                    _ActionCard(
                      title: 'Paso 4: Enviar Correo Final',
                      subtitle: 'Envía los documentos firmados al firmante.',
                      icon: Icons.send_outlined,
                      isLocked: !procesoCompleto,
                      child: !procesoCompleto
                        ? _buildLockedMessage('Complete los pasos anteriores para desbloquear.')
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: _finalEnviado ? Colors.green : AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                              icon: _enviandoFinal
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Icon(_finalEnviado ? Icons.check_circle : Icons.send),
                              label: Text(_enviandoFinal ? 'Enviando correo...' : _finalEnviado ? '¡Correo Enviado!' : 'Enviar Correo Final'),
                              onPressed: (_enviandoFinal || _finalEnviado) ? null : _enviarCorreoFinal,
                            ),
                          ),
                    ),

                    const SizedBox(height: AppSizes.xxl),
                    
                    // CANCELAR CITA
                    if (estado != CitaEstado.cerrada && estado != CitaEstado.cancelada) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                          label: const Text('Cancelar Cita', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.md)),
                          ),
                          onPressed: () async {
                            AppDialogs.info(context, 'Módulo de cancelación en construcción.');
                          },
                        ),
                      ),
                    ]
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedMessage(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppSizes.md),
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.lock, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: AppSizes.sm),
          Text(mensaje, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// COMPONENTE PREMIUM PARA MOSTRAR EL DOCUMENTO SUBIDO
class _DocItem extends StatelessWidget {
  final String nombre;
  final String ruta;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _DocItem({required this.nombre, required this.ruta, required this.onDownload, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.md),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                const Text('Documento subido exitosamente', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
            icon: const Icon(Icons.download, color: AppColors.primary, size: 20),
            tooltip: 'Descargar PDF',
            onPressed: onDownload,
          ),
          const SizedBox(width: 8),
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.1)),
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            tooltip: 'Eliminar documento',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final bool isCompleted;
  final bool isLocked;

  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.child, this.isCompleted = false, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.lg),
        side: BorderSide(color: isLocked ? Colors.grey.shade300 : (isCompleted ? Colors.green.withValues(alpha: 0.5) : AppColors.border), width: isLocked ? 1 : 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(color: isLocked ? Colors.grey.shade200 : (isCompleted ? Colors.green.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(AppSizes.sm)),
                  child: Icon(isLocked ? Icons.lock_outline : (isCompleted ? Icons.check : icon), color: isLocked ? Colors.grey : (isCompleted ? Colors.green : AppColors.primary)),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isLocked ? Colors.grey : AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: isLocked ? Colors.grey.shade400 : AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSizes.xxl),
            child,
          ],
        ),
      ),
    );
  }
}
