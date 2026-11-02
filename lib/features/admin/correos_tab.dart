import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/dialogs.dart';
import '../../data/database/app_database.dart';
import '../correos/data/correos_repository.dart';

class CorreosTab extends ConsumerWidget {
  const CorreosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(correosRepositoryProvider);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return StreamBuilder<List<CorreosLogData>>(
      stream: repo.watchTodos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final correos = snapshot.data!;
        if (correos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mark_email_read, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay correos en la cola', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.xl),
          itemCount: correos.length,
          separatorBuilder: (_, index) => const SizedBox(height: AppSizes.md),
          itemBuilder: (context, index) {
            final correo = correos[index];
            final isEnviado = correo.estado == 'enviado';
            final isFallido = correo.estado == 'fallido';
            final isPendiente = correo.estado == 'pendiente';

            Color statusColor = Colors.grey;
            IconData statusIcon = Icons.schedule;
            if (isEnviado) { statusColor = Colors.green; statusIcon = Icons.check_circle; }
            if (isFallido) { statusColor = Colors.red; statusIcon = Icons.error; }
            if (isPendiente) { statusColor = Colors.orange; statusIcon = Icons.hourglass_empty; }

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  title: Text(
                    correo.asunto,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Para: ${correo.destinatario}', 
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(dateFmt.format(DateTime.fromMillisecondsSinceEpoch(correo.programadoAt)), style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(label: 'Tipo de correo', value: correo.tipo),
                          _InfoRow(label: 'Estado actual', value: correo.estado.toUpperCase(), color: statusColor),
                          _InfoRow(label: 'Intentos de envío', value: '${correo.intentos}'),
                          if (correo.enviadoAt != null)
                            _InfoRow(label: 'Enviado el', value: dateFmt.format(DateTime.fromMillisecondsSinceEpoch(correo.enviadoAt!))),
                          if (correo.errorMensaje != null && correo.errorMensaje!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Último error:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
                                  const SizedBox(height: 4),
                                  Text(correo.errorMensaje!, style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSizes.md),
                          if (isFallido)
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Reintentar envío'),
                                onPressed: () async {
                                  await repo.reintentar(correo.id);
                                  if (context.mounted) AppDialogs.success(context, 'Correo re-encolado. Se enviará en breve.');
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
