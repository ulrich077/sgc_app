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

    final bool docsPresentados = cita.postMortemPresentado && cita.contraloriaPresentada;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
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
                  isCompleted: docsPresentados,
                  child: Column(
                    children: [
                      _CustomSwitch(
                        title: 'Post Mortem Presentado',
                        value: cita.postMortemPresentado,
                        onChanged: (v) async {
                          final repo = CitasRepository(ref.read(databaseProvider));
                          await repo.cambiarCheckPostMortem(cita.id, v, auth.userId ?? 1);
                        },
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _CustomSwitch(
                        title: 'Contraloría Presentada',
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

                // PASO 2
                _ActionCard(
                  title: 'Paso 2: Subir Documentos Firmados',
                  subtitle: 'Arrastra los archivos PDF escaneados desde tu escritorio.',
                  icon: Icons.cloud_upload_outlined,
                  isLocked: !docsPresentados,
                  child: !docsPresentados 
                    ? _buildLockedMessage()
                    : StreamBuilder<List<Documento>>(
                        stream: docsRepo.watchPorCita(cita.id),
                        builder: (context, snapshot) {
                          final docs = snapshot.data ?? [];
                          final hasResp = docs.any((d) => d.tipo == DocumentoTipo.responsabilidadFirmado.dbValue);
                          final hasContrato = docs.any((d) => d.tipo == DocumentoTipo.contratoFirmado.dbValue);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                                      if (context.mounted) AppDialogs.success(context, 'Documento subido.');
                                    } catch (e) {
                                      if (context.mounted) AppDialogs.error(context, 'Error: $e');
                                    }
                                  },
                                )
                              else
                                _DocSubidoCard(nombre: 'Documento de Responsabilidad', icon: Icons.check_circle, color: Colors.green),

                              const SizedBox(height: AppSizes.lg),

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
                                      if (context.mounted) AppDialogs.success(context, 'Contrato subido.');
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

                // PASO 3
                _ActionCard(
                  title: 'Paso 3: Enviar Correo Final',
                  subtitle: 'Envía el contrato final al firmante.',
                  icon: Icons.send_outlined,
                  isLocked: !docsPresentados,
                  child: !docsPresentados
                    ? _buildLockedMessage()
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedMessage() {
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
          Text(
            'Completa el Paso 1 para desbloquear esta sección.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Switch personalizado para que se vea premium
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
          Expanded(
            child: Text(title, style: TextStyle(
              fontWeight: value ? FontWeight.bold : FontWeight.normal,
              color: value ? Colors.green.shade800 : AppColors.textPrimary,
            )),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

// Tarjeta de documento subido
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

// Tarjeta de Acción genérica
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final bool isCompleted;
  final bool isLocked;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.isCompleted = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.lg),
        side: BorderSide(
          color: isLocked ? Colors.grey.shade300 : (isCompleted ? Colors.green.withValues(alpha: 0.5) : AppColors.border),
          width: isLocked ? 1 : 1.5,
        ),
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
                    color: isLocked ? Colors.grey.shade200 : (isCompleted ? Colors.green.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_outline : (isCompleted ? Icons.check : icon),
                    color: isLocked ? Colors.grey : (isCompleted ? Colors.green : AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey : AppColors.textPrimary,
                      )),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(
                        color: isLocked ? Colors.grey.shade400 : AppColors.textSecondary,
                        fontSize: 13,
                      )),
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
