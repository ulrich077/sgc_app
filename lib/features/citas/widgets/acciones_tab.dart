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
                final hasResp = docs.where((d) => d.tipo == DocumentoTipo.responsabilidadFirmado.dbValue).firstOrNull;
                final hasContrato = docs.where((d) => d.tipo == DocumentoTipo.contratoFirmado.dbValue).firstOrNull;
                
                final bool paso3Habilitado = hasResp != null;
                final bool procesoCompleto = hasResp != null && hasContrato != null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PASO 1: SOLO POST MORTEM Y CONTRALORÍA
                    _ActionCard(
                      title: 'Paso 1: Documentos Requeridos',
                      subtitle: 'Marque si el firmante presentó el Post Mortem y la Contraloría.',
                      icon: Icons.assignment_turned_in_outlined,
                      isCompleted: cita.postMortemPresentado && cita.contraloriaPresentada,
                      child: Column(
                        children: [
                          _CustomSwitch(
                            title: 'Post Mortem Presentado',
                            value: cita.postMortemPresentado,
                            onChanged: (v) async {
                              await CitasRepository(ref.read(databaseProvider)).cambiarCheckPostMortem(cita.id, v, auth.userId ?? 1);
                            },
                          ),
                          const SizedBox(height: AppSizes.sm),
                          _CustomSwitch(
                            title: 'Contraloría Presentada',
                            value: cita.contraloriaPresentada,
                            onChanged: (v) async {
                              await CitasRepository(ref.read(databaseProvider)).cambiarCheckContraloria(cita.id, v, auth.userId ?? 1);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // PASO 2: RESPONSABILIDAD
                    _ActionCard(
                      title: 'Paso 2: Documento de Responsabilidad',
                      subtitle: 'Descargue el documento, fírmelo y súbalo escaneado.',
                      icon: Icons.description_outlined,
                      isCompleted: hasResp != null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            icon: const Icon(Icons.download, color: AppColors.primary),
                            label: const Text('Descargar PDF de Responsabilidad', style: TextStyle(color: AppColors.primary)),
                            onPressed: () => _generarYDescargarPdf(cita),
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

                    // PASO 3: CONTRATO FIRMADO
                    _ActionCard(
                      title: 'Paso 3: Subir Contrato Firmado',
                      subtitle: 'Arrastra el contrato escaneado.',
                      icon: Icons.file_present,
                      isLocked: !paso3Habilitado,
                      child: !paso3Habilitado
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

                    // PASO 4: ENVIAR CORREO FINAL
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

// SWITCH PREMIUM DEL PASO 1
class _CustomSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _CustomSwitch({required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: value ? Colors.green.withValues(alpha: 0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSizes.md),
        border: Border.all(color: value ? Colors.green.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(fontWeight: value ? FontWeight.bold : FontWeight.normal, color: value ? Colors.green.shade800 : AppColors.textPrimary))),
          Switch(value: value, onChanged: onChanged, activeThumbColor: Colors.green),
        ],
      ),
    );
  }
}

// ITEM DE DOCUMENTO PREMIUM (Paso 2 y 3)
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
        color: Colors.green.withValues(alpha: 0.05),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppSizes.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(nombre, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.primary),
            tooltip: 'Descargar PDF',
            onPressed: onDownload,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Eliminar documento',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// TARJETA GENERAL
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