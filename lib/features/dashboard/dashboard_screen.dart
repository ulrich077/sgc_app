import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/app_page_header.dart';
import '../../core/widgets/responsive_kpis_row.dart';
import '../../data/database/app_database.dart';
import '../citas/data/citas_repository.dart';
import '../citas/domain/cita_estado.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final repo = ref.watch(citasRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        children: [
          AppPageHeader(
            title: 'Hola, ${auth.nombreCompleto ?? ''}',
            subtitle: 'Rol: ${auth.rolNombre ?? ''}',
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: ResponsiveKpisRow(
              children: [
                _KpiCard(
                  label: 'Citas totales',
                  icon: Icons.event_note,
                  color: AppColors.primary,
                  stream: repo.watchTotalPorEstado(CitaEstado.citaCreada),
                  sum: true,
                  repo: repo,
                ),
                _KpiCard(
                  label: 'Pendientes envío',
                  icon: Icons.pending_actions,
                  color: AppColors.pendiente,
                  stream:
                      repo.watchTotalPorEstado(CitaEstado.pendienteEnvioContrato),
                ),
                _KpiCard(
                  label: 'Contrato enviado',
                  icon: Icons.mark_email_read,
                  color: AppColors.enviada,
                  stream: repo.watchTotalPorEstado(CitaEstado.contratoEnviado),
                ),
                _KpiCard(
                  label: 'Cerradas',
                  icon: Icons.task_alt,
                  color: AppColors.success,
                  stream: repo.watchTotalPorEstado(CitaEstado.cerrada),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: Text('Actividad reciente',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: AppSizes.md),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: _RecientesList(repo: repo),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Stream<int> stream;
  final bool sum;
  final CitasRepository? repo;

  const _KpiCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.stream,
    this.sum = false,
    this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(label,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            StreamBuilder<int>(
              stream: stream,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                    height: 32,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                return Text('${snap.data}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: color, fontWeight: FontWeight.bold));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecientesList extends StatelessWidget {
  final CitasRepository repo;
  const _RecientesList({required this.repo});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM HH:mm');
    return StreamBuilder<List<Cita>>(
      stream: repo.watchRecientes(limit: 8),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final rows = snap.data!;
        if (rows.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Center(child: Text('Sin actividad reciente.')),
          );
        }
        return Card(
          child: Column(
            children: rows.map((c) {
              final e = CitaEstado.fromDb(c.estado);
              return ListTile(
                dense: true,
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: e.color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(c.personaNombre),
                subtitle: Text(e.label),
                trailing: Text(
                  c.dateCreation == null
                      ? '—'
                      : dateFmt.format(DateTime.fromMillisecondsSinceEpoch(
                          c.dateCreation!)),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
