import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/dialogs.dart';
import '../../data/database/app_database.dart';
import '../correos/data/correos_repository.dart';
import '../correos/domain/correo_tipo.dart';

class CorreosTab extends ConsumerWidget {
  const CorreosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(correosRepositoryProvider);
    final dateFmt = DateFormat('dd/MM HH:mm');

    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        Text('Cola de correos',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.sm),
        const Text(
          'Los correos pendientes se envían automáticamente. '
          'Los fallidos se reintentan hasta 6 veces con backoff.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.md),
        StreamBuilder<List<CorreosLogData>>(
          stream: repo.watchTodos(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.xl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final correos = snap.data!;
            if (correos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.xl),
                child: Center(child: Text('Sin correos en la cola.')),
              );
            }
            return Card(
              child: Column(
                children: correos.map((c) {
                  final tipo = CorreoTipo.fromDb(c.tipo);
                  final estado = CorreoEstado.fromDb(c.estado);
                  return ListTile(
                    leading: _estadoIcon(estado),
                    title: Text(c.asunto),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${tipo.label} → ${c.destinatario}'),
                        if (c.errorMensaje != null)
                          Text(
                            'Error: ${c.errorMensaje}',
                            style: const TextStyle(
                                color: AppColors.danger, fontSize: 11),
                          ),
                        Text(
                          'Programado: ${dateFmt.format(DateTime.fromMillisecondsSinceEpoch(c.programadoAt))}'
                          '${c.intentos > 0 ? ' — intentos: ${c.intentos}' : ''}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    trailing: estado == CorreoEstado.fallido ||
                            estado == CorreoEstado.pendiente
                        ? IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Reintentar',
                            onPressed: () =>
                                _reintentar(context, ref, c.id),
                          )
                        : null,
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _estadoIcon(CorreoEstado e) {
    switch (e) {
      case CorreoEstado.enviado:
        return const Icon(Icons.check_circle, color: AppColors.success);
      case CorreoEstado.pendiente:
        return const Icon(Icons.schedule, color: AppColors.pendiente);
      case CorreoEstado.fallido:
        return const Icon(Icons.error, color: AppColors.danger);
    }
  }

  Future<void> _reintentar(
      BuildContext context, WidgetRef ref, int id) async {
    final ok = await AppDialogs.confirm(
      context,
      '¿Reintentar el envío de este correo ahora?',
    );
    if (!ok || !context.mounted) return;
    try {
      final db = ref.read(databaseProvider);
      await (db.update(db.correosLog)..where((t) => t.id.equals(id))).write(
        CorreosLogCompanion(
          estado: const Value('pendiente'),
          intentos: const Value(0),
          proximoIntentoAt: Value(DateTime.now().millisecondsSinceEpoch),
          errorMensaje: const Value(null),
        ),
      );
      if (!context.mounted) return;
      await AppDialogs.success(context, 'Correo marcado para reintento.');
    } catch (e) {
      if (!context.mounted) return;
      await AppDialogs.error(context, 'Error: $e');
    }
  }
}
