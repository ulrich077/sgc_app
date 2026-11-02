import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            ..where((t) => t.citaId.equals(widget.cita.id) & t.tipo.equals('final'))
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
      color: const Color(0xFFF4F7F9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: StreamBuilder<List<Documento>>(
              stream: docsRepo.watchPorCita(cita.id),
              builder: (context, snapshot) {
                final docs = snapshot.data ?? [];
                
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
                    _PremiumCard(
                      stepNumber: 1,
                      title: 'Documentos Físicos',
                      subtitle: 'Suba el Post Mortem y la Contraloría.',
                      icon: FontAwesomeIcons.folderOpen,
                      isCompleted: paso1Completado,
                      child: Column(
                        children: [
                          if (hasPostMortem == null)
                            _PremiumUploadRow(
                              title: 'Post Mortem',
                              onTap: () async {
                                final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                                if (result.isNotEmpty && result.first.path != null) {
                                  await docsRepo.subirDocumento(citaId: cita.id, tipo: DocumentoTipo.postMortemEscaneo, archivo: File(result.first.path!), userId: auth.userId ?? 1);
                                  await CitasRepository(ref.read(databaseProvider)).cambiarCheckPostMortem(cita.id, true, auth.userId ?? 1);
                                }
                              },
                            )
                          else
                            _PremiumDocRow(
                              title: 'Post Mortem',
                              onDownload: () => _abrirPdf(hasPostMortem.rutaArchivo),
                              onDelete: () async {
                                await docsRepo.eliminar(hasPostMortem.id, auth.userId ?? 1);
                                await CitasRepository(ref.read(databaseProvider)).cambiarCheckPostMortem(cita.id, false, auth.userId ?? 1);
                              },
                            ),
                          const SizedBox(height: 12),
                          if (hasContraloria == null)
                            _PremiumUploadRow(
                              title: 'Contraloría',
                              onTap: () async {
                                final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                                if (result.isNotEmpty && result.first.path != null) {
                                  await docsRepo.subirDocumento(citaId: cita.id, tipo: DocumentoTipo.contraloriaEscaneo, archivo: File(result.first.path!), userId: auth.userId ?? 1);
                                  await CitasRepository(ref.read(databaseProvider)).cambiarCheckContraloria(cita.id, true, auth.userId ?? 1);
                                }
                              },
                            )
                          else
                            _PremiumDocRow(
                              title: 'Contraloría',
                              onDownload: () => _abrirPdf(hasContraloria.rutaArchivo),
                              onDelete: () async {
                                await docsRepo.eliminar(hasContraloria.id, auth.userId ?? 1);
                                await CitasRepository(ref.read(databaseProvider)).cambiarCheckContraloria(cita.id, false, auth.userId ?? 1);
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _PremiumCard(
                      stepNumber: 2,
                      title: 'Documento de Responsabilidad',
                      subtitle: 'Descargue, firme y suba el escaneo.',
                      icon: FontAwesomeIcons.fileSignature,
                      isLocked: !paso1Completado,
                      isCompleted: paso2Completado,
                      child: !paso1Completado
                        ? _buildLockedMessage()
                        : Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  children: [
                                    const FaIcon(FontAwesomeIcons.filePdf, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text('Descargar Plantilla PDF', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    ),
                                    TextButton.icon(
                                      icon: const FaIcon(FontAwesomeIcons.download, size: 14),
                                      onPressed: () => _generarYDescargarPdf(cita),
                                      label: const Text('Descargar'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (hasResp == null)
                                _PremiumUploadRow(
                                  title: 'Subir Documento Firmado',
                                  onTap: () async {
                                    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                                    if (result.isNotEmpty && result.first.path != null) {
                                      await docsRepo.subirDocumento(citaId: cita.id, tipo: DocumentoTipo.responsabilidadFirmado, archivo: File(result.first.path!), userId: auth.userId ?? 1);
                                    }
                                  },
                                )
                              else
                                _PremiumDocRow(
                                  title: 'Documento Firmado',
                                  onDownload: () => _abrirPdf(hasResp.rutaArchivo),
                                  onDelete: () async {
                                    await docsRepo.eliminar(hasResp.id, auth.userId ?? 1);
                                  },
                                ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 16),

                    _PremiumCard(
                      stepNumber: 3,
                      title: 'Contrato Firmado',
                      subtitle: 'Suba el contrato escaneado.',
                      icon: FontAwesomeIcons.fileContract,
                      isLocked: !paso2Completado,
                      isCompleted: paso3Completado,
                      child: !paso2Completado
                        ? _buildLockedMessage()
                        : (hasContrato == null
                            ? _PremiumUploadRow(
                                title: 'Subir Contrato Firmado',
                                onTap: () async {
                                  final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                                  if (result.isNotEmpty && result.first.path != null) {
                                    await docsRepo.subirDocumento(citaId: cita.id, tipo: DocumentoTipo.contratoFirmado, archivo: File(result.first.path!), userId: auth.userId ?? 1);
                                  }
                                },
                              )
                            : _PremiumDocRow(
                                title: 'Contrato Firmado',
                                onDownload: () => _abrirPdf(hasContrato.rutaArchivo),
                                onDelete: () async {
                                  await docsRepo.eliminar(hasContrato.id, auth.userId ?? 1);
                                },
                              )),
                    ),
                    const SizedBox(height: 16),

                    _PremiumCard(
                      stepNumber: 4,
                      title: 'Enviar Correo Final',
                      subtitle: 'Notificar al firmante con los adjuntos.',
                      icon: FontAwesomeIcons.paperPlane,
                      isLocked: !procesoCompleto,
                      child: !procesoCompleto
                        ? _buildLockedMessage()
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
                                  : FaIcon(_finalEnviado ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.paperPlane, size: 18),
                              label: Text(_enviandoFinal ? 'Enviando...' : _finalEnviado ? '¡Enviado!' : 'Enviar Correo Final'),
                              onPressed: (_enviandoFinal || _finalEnviado) ? null : _enviarCorreoFinal,
                            ),
                          ),
                    ),

                    const SizedBox(height: 32),
                    
                    if (estado != CitaEstado.cerrada && estado != CitaEstado.cancelada) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const FaIcon(FontAwesomeIcons.ban, color: Colors.red, size: 16),
                          label: const Text('Cancelar Cita', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            backgroundColor: Colors.red.withValues(alpha: 0.05),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildLockedMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FaIcon(FontAwesomeIcons.lock, size: 24, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Completa el paso anterior para desbloquear.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _PremiumUploadRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _PremiumUploadRow({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.cloudArrowUp, color: Colors.grey.shade500, size: 20),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
            const FaIcon(FontAwesomeIcons.chevronRight, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}

class _PremiumDocRow extends StatelessWidget {
  final String title;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _PremiumDocRow({required this.title, required this.onDownload, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const FaIcon(FontAwesomeIcons.check, color: Colors.green, size: 14),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          IconButton(icon: const FaIcon(FontAwesomeIcons.download, color: AppColors.primary, size: 18), onPressed: onDownload),
          IconButton(icon: const FaIcon(FontAwesomeIcons.trashCan, color: Colors.red, size: 18), onPressed: onDelete),
        ],
      ),
    );
  }
}

// CAMBIAMOS IconData POR FaIconData PARA QUE ACEPTE LOS ÍCONOS DE FONT AWESOME
class _PremiumCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final FaIconData icon;
  final Widget child;
  final bool isCompleted;
  final bool isLocked;

  const _PremiumCard({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.isCompleted = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLocked ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8)),
          ],
          border: Border.all(color: isCompleted ? Colors.green.withValues(alpha: 0.4) : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : (isLocked ? Colors.grey.shade300 : AppColors.primary.withValues(alpha: 0.1)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 14)
                        : Text('$stepNumber', style: TextStyle(color: isLocked ? Colors.grey : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                FaIcon(icon, color: isLocked ? Colors.grey : (isCompleted ? Colors.green : AppColors.primary), size: 20),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
