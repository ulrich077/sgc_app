import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/database/app_database.dart';
import '../citas/data/citas_repository.dart';
import '../citas/domain/cita_estado.dart';
import '../citas/widgets/cita_detalle_modal.dart';
import '../citas/widgets/nueva_cita_dialog.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Cita> _citasDelDia = [];
  bool _loadingDia = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _cargarCitasDelDia(_selectedDay!);
  }

  Future<void> _cargarCitasDelDia(DateTime dia) async {
    setState(() => _loadingDia = true);
    final repo = ref.read(citasRepositoryProvider);
    
    // Buscamos las citas de ese día (desde las 00:00 hasta las 23:59)
    final inicio = DateTime(dia.year, dia.month, dia.day, 0, 0, 0);
    final fin = DateTime(dia.year, dia.month, dia.day, 23, 59, 59);
    
    final citas = await repo.obtenerCitasPorFecha(inicio, fin);
    if (mounted) {
      setState(() {
        _citasDelDia = citas;
        _loadingDia = false;
      });
    }
  }

  Future<void> _abrirNuevaCitaEnFecha(DateTime fecha) async {
    // Abre el modal de nueva cita y le pasa la fecha seleccionada (si tu modal lo permite)
    final creada = await showDialog<bool>(
      context: context,
      builder: (_) => const NuevaCitaDialog(),
    );
    if (creada == true) {
      _cargarCitasDelDia(_selectedDay!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final repo = ref.watch(citasRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${auth.nombreCompleto ?? 'Usuario'}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, d de MMMM de yyyy', 'es').format(DateTime.now()),
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.textSecondary),
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),

            // CONTENIDO: CALENDARIO + PANEL DEL DÍA
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                final calendario = _buildCalendario(repo);
                final detalleDia = _buildDetalleDia();

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: calendario),
                      const SizedBox(width: AppSizes.xl),
                      Expanded(flex: 7, child: detalleDia),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      calendario,
                      const SizedBox(height: AppSizes.xl),
                      detalleDia,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendario(CitasRepository repo) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calendario de Citas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.lg),
          StreamBuilder<List<Cita>>(
            stream: repo.watchTodas(),
            builder: (context, snapshot) {
              final todasLasCitas = snapshot.data ?? [];
              
              return TableCalendar<Cita>(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                locale: 'es_ES',
                availableGestures: AvailableGestures.horizontalSwipe,
                // ESTO PINTA LOS PUNTITOS EN LOS DÍAS CON CITAS
                eventLoader: (day) {
                  return todasLasCitas.where((cita) {
                    final fecha = DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma * 1000);
                    return isSameDay(fecha, day);
                  }).toList();
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.textSecondary),
                  rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
                  todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  outsideDaysVisible: false,
                  cellMargin: const EdgeInsets.all(6),
                  markerDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  markersMaxCount: 1,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _cargarCitasDelDia(selectedDay);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleDia() {
    if (_loadingDia) {
      return const Center(child: CircularProgressIndicator());
    }

    final fechaStr = DateFormat('EEEE, d de MMMM', 'es').format(_selectedDay!);
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Citas para el $fechaStr',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_citasDelDia.length} cita(s) agendada(s)',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agendar'),
                onPressed: () => _abrirNuevaCitaEnFecha(_selectedDay!),
              ),
            ],
          ),
          const Divider(height: 32),
          if (_citasDelDia.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'No hay citas agendadas para este día.',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¡Tienes el día libre para agendar!',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _citasDelDia.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cita = _citasDelDia[index];
                final estado = CitaEstado.fromDb(cita.estado);
                final hora = DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma * 1000);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(DateFormat('HH:mm').format(hora), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('hrs', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cita.personaNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(color: estado.color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(estado.label, style: TextStyle(fontSize: 12, color: estado.color, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                        onPressed: () => CitaDetalleModal.show(context, cita.id),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
