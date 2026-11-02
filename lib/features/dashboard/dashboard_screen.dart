import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/app_page_header.dart';
import '../../core/widgets/responsive_kpis_row.dart';
import '../../data/database/app_database.dart';
import '../citas/data/citas_repository.dart';
import '../citas/domain/cita_estado.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
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
          // KPIs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: ResponsiveKpisRow(
              children: [
                _KpiCard(
                  label: 'Citas totales',
                  icon: Icons.event_note,
                  color: AppColors.primary,
                  stream: repo.watchTotalPorEstado(CitaEstado.citaCreada),
                ),
                _KpiCard(
                  label: 'Pendientes envío',
                  icon: Icons.pending_actions,
                  color: AppColors.pendiente,
                  stream: repo.watchTotalPorEstado(CitaEstado.pendienteEnvioContrato),
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
          
          // CALENDARIO Y ACTIVIDAD RECIENTE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                final calendarWidget = _buildCalendar(repo);
                final recientesWidget = _RecientesList(repo: repo);

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: calendarWidget),
                      const SizedBox(width: AppSizes.xl),
                      Expanded(flex: 2, child: recientesWidget),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      calendarWidget,
                      const SizedBox(height: AppSizes.xl),
                      recientesWidget,
                    ],
                  );
                }
              },
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildCalendar(CitasRepository repo) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.lg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calendario de Citas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.md),
            TableCalendar<Cita>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              availableGestures: AvailableGestures.horizontalSwipe,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
              eventLoader: (day) {
                // Aquí podrías filtrar las citas del día usando un stream o consulta
                // Por ahora retornamos lista vacía para evitar sobrecarga.
                return [];
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
          ],
        ),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.lg),
        side: const BorderSide(color: AppColors.border),
      ),
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
                  child: Text(label, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
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
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  );
                }
                return Text('${snap.data}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actividad reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.md),
        StreamBuilder<List<Cita>>(
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
              elevation: 0,
              color: Colors.transparent,
              child: Column(
                children: rows.map((c) {
                  final e = CitaEstado.fromDb(c.estado);
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.xs),
                    child: ListTile(
                      dense: true,
                      leading: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: e.color, shape: BoxShape.circle),
                      ),
                      title: Text(c.personaNombre),
                      subtitle: Text(e.label),
                      trailing: Text(
                        c.dateCreation == null ? '—' : dateFmt.format(DateTime.fromMillisecondsSinceEpoch(c.dateCreation! * 1000)),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
