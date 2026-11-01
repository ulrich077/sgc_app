import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_page_header.dart';
import '../../data/database/app_database.dart';
import '../citas/data/auditoria_repository.dart';

class AuditoriaScreen extends ConsumerWidget {
  const AuditoriaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Auditoría')),
        body: const Center(child: Text(AppStrings.noPermission)),
      );
    }
    final repo = ref.watch(auditoriaRepositoryProvider);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Auditoría')),
      body: ListView(
        children: [
          const AppPageHeader(
            title: 'Auditoría',
            subtitle: 'Registro inmutable de acciones del sistema',
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: StreamBuilder<List<AuditoriaData>>(
              stream: repo.watchTodos(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSizes.xl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final rows = snap.data!;
                if (rows.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSizes.xl),
                    child: Center(child: Text('Sin registros de auditoría.')),
                  );
                }
                return Card(
                  child: Column(
                    children: rows.map((a) {
                      return ListTile(
                        leading: _iconoAccion(a.accion),
                        title: Text('${a.tabla} #${a.registroId ?? '—'}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Acción: ${a.accion}'),
                            if (a.valorDespues != null)
                              Text(
                                'Después: ${a.valorDespues}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: Text(
                          dateFmt.format(DateTime.fromMillisecondsSinceEpoch(
                              a.fecha)),
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _iconoAccion(String accion) {
    switch (accion) {
      case 'crear':
        return const Icon(Icons.add_circle, color: AppColors.success);
      case 'eliminar':
        return const Icon(Icons.delete, color: AppColors.danger);
      case 'cambiar_estado':
        return const Icon(Icons.swap_horiz, color: AppColors.info);
      default:
        return const Icon(Icons.edit, color: AppColors.warning);
    }
  }
}
