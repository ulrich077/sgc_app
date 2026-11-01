import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/providers/database_provider.dart';
import '../../core/widgets/app_page_header.dart';
import '../../core/widgets/responsive_kpis_row.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final db = ref.watch(databaseProvider);

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
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding),
            child: ResponsiveKpisRow(
              children: [
                _KpiCard(
                  label: 'Citas totales',
                  icon: Icons.event_note,
                  color: AppColors.primary,
                  stream: db.select(db.citas).watch().map((r) => r.length),
                ),
                _KpiCard(
                  label: 'Pendientes de envío',
                  icon: Icons.pending_actions,
                  color: AppColors.pendiente,
                  stream: (db.select(db.citas)
                        ..where((t) =>
                            t.estado.equals('PENDIENTE_ENVIO_CONTRATO')))
                      .watch()
                      .map((r) => r.length),
                ),
                _KpiCard(
                  label: 'Firmas enviadas',
                  icon: Icons.mark_email_read,
                  color: AppColors.enviada,
                  stream: (db.select(db.citas)
                        ..where((t) => t.estado.equals('CONTRATO_ENVIADO')))
                      .watch()
                      .map((r) => r.length),
                ),
                _KpiCard(
                  label: 'Cerradas',
                  icon: Icons.task_alt,
                  color: AppColors.success,
                  stream: (db.select(db.citas)
                        ..where((t) => t.estado.equals('CERRADA')))
                      .watch()
                      .map((r) => r.length),
                ),
              ],
            ),
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

  const _KpiCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.stream,
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
