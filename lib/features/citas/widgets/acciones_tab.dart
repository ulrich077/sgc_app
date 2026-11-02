import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class AccionesTab extends ConsumerWidget {
  final Cita cita;
  const AccionesTab({super.key, required this.cita});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = CitaEstado.fromDb(cita.estado);
    final auth = ref.watch(authProvider);
    final docsRepo = ref.watch(documentosRepositoryProvider);

    // Si ya subió alguno de los documentos, habilitamos lo demás (puedes ajustar la lógica)
    final bool docsPresentados = cita.postMortemPresentado && cita.contraloriaPresentada;

    // Validar si ya existen documentos subidos para este paso
    final docsStream = docsRepo.watchPorCita(cita.id);

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PASO 1
                _ActionCard(
                  title: 'Paso 1: Documentos Requeridos',
                  subtitle: 'Marque si el firmante presentó el Post Mortem y la Contraloría.',
                  icon: Icons.assignment_turned_in_outlined,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Post Mortem Presentado'),
                        value: cita.postMortemPresentado,
                        onChanged: (v) async {
                          final repo = CitasRepository(ref.read(databaseProvider));
                          await repo.cambiarCheckPostMortem(cita.id, v, auth.userId ?? 1);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Contraloría Presentada'),
                        value: cita.contraloriaPresentada,
                        onChanged: (v) async {
                          final repo = CitasRepository(ref.read(databaseProvider));
                          await repo.cambiarCheckContraloria(cita.id, v, auth.userId ?? 1);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // PASO 2: DRAG & DROP REAL
                if (docsPresentados) ...[
                  _ActionCard(
                    title: 'Paso 2: Subir Documentos Firmados',
                    subtitle: 'Arrastra los archivos PDF escaneados desde tu escritorio.',
                    icon: Icons.cloud_upload_outlined,
                    child: StreamBuilder<List<Documento>>(
                      stream: docsStream,
                      builder: (context, snapshot) {
                        final docs = snapshot.data ?? [];
                        final hasResp = docs.any((d) => d.tipo == DocumentoTipo.responsabilidadFirmado.dbValue);
                        final hasContrato = docs.any((d) => d.tipo == DocumentoTipo.contratoFirmado.dbValue);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Zona 1: Responsabilidad
                            if (!hasResp)
                              DropZone(
                                titulo: 'Arrastra aquí el PDF de Responsabilidad',
                                subtitulo: 'Debe estar firmado por el candidato.',
                                icono: Icons.description,
                                onFileDropped: (path) async {
                                  try {
                                    final file = File(path);
                                    await docsRepo.subirDocumento(
                                      citaId: cita.id,
                                      tipo: DocumentoTipo.responsabilidadFirmado,
                                      archivo: file,
                                      userId: auth.userId ?? 1,
                                    );
                                    if (context.mounted) AppDialogs.success(context, 'Documento de Responsabilidad subido.');
                                  } catch (e) {
                                    if (context.mounted) AppDialogs.error(context, 'Error: $e');
                                  }
                                },
                              )
                            else
                              _DocSubidoCard(nombre: 'Documento de Responsabilidad', icon: Icons.check_circle, color: Colors.green),

                            const SizedBox(height: AppSizes.lg),

                            // Zona 2: Contrato (solo si ya subió el de responsabilidad)
                            if (hasResp && !hasContrato)
                              DropZone(
                                titulo: 'Arrastra aquí el Contrato Firmado',
                                subtitulo: 'Documento final escaneado.',
                                icono: Icons.file_present,
                                onFileDropped: (path) async {
                                  try {
                                    final file = File(path);
                                    await docsRepo.subirDocumento(
                                      citaId: cita.id,
                                      tipo: DocumentoTipo.contratoFirmado,
                                      archivo: file,
                                      userId: auth.userId ?? 1,
                                    );
                                    if (context.mounted) AppDialogs.success(context, 'Contrato Firmado subido.');
                                  } catch (e) {
                                    if (context.mounted) AppDialogs.error(context, 'Error: $e');
                                  }
                                },
                              )
                            else if (hasResp && hasContrato)
                              _DocSubidoCard(nombre: 'Contrato Firmado', icon: Icons.check_circle, color: Colors.green),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // PASO 3: ENVIAR CORREO FINAL
                  _ActionCard(
                    title: 'Paso 3: Enviar Correo Final',
                    subtitle: 'Envía el contrato final al firmante.',
                    icon: Icons.send_outlined,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar Correo con Contrato'),
                        onPressed: () async {
                          final repo = CitasRepository(ref.read(databaseProvider));
                          await repo.cambiarEstado(citaId: cita.id, nuevoEstado: CitaEstado.contratoEnviado, userId: auth.userId ?? 1);
                          if (context.mounted) AppDialogs.success(context, 'Contrato enviado y proceso finalizado.');
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('⚠️ Debe completar el Paso 1 para habilitar la subida de documentos.', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                ],

                const SizedBox(height: AppSizes.lg),
                
                // CANCELAR CITA
                if (estado != CitaEstado.cerrada && estado != CitaEstado.cancelada) ...[
                  TextButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('Cancelar Cita', style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      AppDialogs.info(context, 'Módulo de cancelación en construcción.');
                    },
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocSubidoCard extends StatelessWidget {
  final String nombre;
  final IconData icon;
  final Color color;

  const _DocSubidoCard({required this.nombre, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppSizes.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSizes.md),
          Expanded(child: Text(nombre, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
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

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.lg),
        side: const BorderSide(color: AppColors.border),
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
      ),
    );
  }
}
