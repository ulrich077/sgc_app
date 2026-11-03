import 'package:fl_chart/fl_chart.dart';
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
  
  // Paginación
  int _page = 0;
  static const int _pageSize = 5;
  
  // Filtro de gráfica

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _cargarCitasDelDia(_selectedDay!);
  }

  Future<void> _cargarCitasDelDia(DateTime dia, {String? filtroTipo}) async {
    setState(() {
      _loadingDia = true;
      _page = 0;
    });
    final repo = ref.read(citasRepositoryProvider);
    
    final inicio = DateTime(dia.year, dia.month, dia.day, 0, 0, 0);
    final fin = DateTime(dia.year, dia.month, dia.day, 23, 59, 59);
    
    final citas = await repo.obtenerCitasPorFecha(inicio, fin);
    if (mounted) {
      setState(() {
        if (filtroTipo == 'agendados') {
          _citasDelDia = citas.where((c) => c.estado != 'CANCELADA' && c.estado != 'CERRADA').toList();
        } else if (filtroTipo == 'terminados') {
          _citasDelDia = citas.where((c) => c.estado == 'CERRADA').toList();
        } else if (filtroTipo == 'reagendados') {
          _citasDelDia = citas.where((c) => c.estado == 'REAGENDADA').toList();
        } else {
          _citasDelDia = citas;
        }
        _loadingDia = false;
      });
    }
  }

  Future<void> _abrirNuevaCitaEnFecha(DateTime fecha) async {
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
                      DateFormat.yMMMMEEEEd('es').format(DateTime.now()),
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

            // KPIs
            Row(
              children: [
                _KpiMini(label: 'Por firmar', value: repo.watchTotalPorEstado(CitaEstado.citaCreada), color: AppColors.primary),
                const SizedBox(width: AppSizes.md),
                _KpiMini(label: 'Pendientes', value: repo.watchTotalPorEstado(CitaEstado.pendienteEnvioContrato), color: Colors.orange),
                const SizedBox(width: AppSizes.md),
                _KpiMini(label: 'Enviadas', value: repo.watchTotalPorEstado(CitaEstado.contratoEnviado), color: Colors.green),
                const SizedBox(width: AppSizes.md),
                _KpiMini(label: 'Cerradas', value: repo.watchTotalPorEstado(CitaEstado.cerrada), color: Colors.teal),
              ],
            ),
            const SizedBox(height: AppSizes.xl),

            // ALERTA DE CITAS VENCIDAS
            StreamBuilder<int>(
              stream: repo.watchVencidas(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.lg),
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Atención: Hay $count cita(s) vencida(s) que requieren reagendamiento o cancelación.',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // GRÁFICA DE LÍNEAS (Actividad de Citas)
            _LineChartCard(
              repo: repo,
              onPuntoSeleccionado: (fecha, tipo) {
                _cargarCitasDelDia(fecha, filtroTipo: tipo);
                setState(() {
                  _selectedDay = fecha;
                  _focusedDay = fecha;
                });
              },
            ),
            const SizedBox(height: AppSizes.xl),

            // CONTENIDO PRINCIPAL
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

    final fechaStr = DateFormat.yMMMMEEEEd('es').format(_selectedDay!);
    
    // Calcular las citas de la página actual
    final totalPages = (_citasDelDia.length / _pageSize).ceil();
    final startIndex = _page * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, _citasDelDia.length);
    final citasPagina = _citasDelDia.sublist(startIndex, endIndex);

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
                  ],
                ),
              ),
            )
          else ...[
            // Lista de citas paginada
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: citasPagina.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cita = citasPagina[index];
                final estado = CitaEstado.fromDb(cita.estado);
                final hora = DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma * 1000);
                final esCancelada = estado == CitaEstado.cancelada;

                return InkWell(
                  onTap: () => CitaDetalleModal.show(context, cita.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: esCancelada ? Colors.red.withValues(alpha: 0.02) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: esCancelada ? Colors.red.withValues(alpha: 0.2) : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: esCancelada ? Colors.red.shade200 : Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('HH:mm').format(hora), 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                  color: esCancelada ? Colors.red : AppColors.textPrimary,
                                  decoration: esCancelada ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              Text('hrs', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cita.personaNombre, 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 15,
                                  color: esCancelada ? Colors.grey.shade500 : AppColors.textPrimary,
                                  decoration: esCancelada ? TextDecoration.lineThrough : null,
                                ),
                              ),
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
                        const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Controles de paginación
            if (totalPages > 1) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _page > 0 ? () => setState(() => _page--) : null,
                  ),
                  Text('Pág. ${_page + 1} de $totalPages'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _page < totalPages - 1 ? () => setState(() => _page++) : null,
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}


class _LineChartCard extends ConsumerWidget {
  final CitasRepository repo;
  final void Function(DateTime fecha, String tipo) onPuntoSeleccionado;

  const _LineChartCard({required this.repo, required this.onPuntoSeleccionado});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividad de Citas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tendencia de los últimos 5 días y próximos 5 días',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.lg),
          
          // LEYENDA (Estilo Chart.js)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Agendados', Colors.blue),
              const SizedBox(width: 20),
              _buildLegendItem('Terminados', Colors.green),
              const SizedBox(width: 20),
              _buildLegendItem('Reagendados', Colors.orange),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          
          // GRÁFICA
          SizedBox(
            height: 250,
            child: StreamBuilder<List<Cita>>(
              stream: repo.watchTodas(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final citas = snapshot.data!;
                
                // Rango: 5 días antes y 5 después
                final hoy = DateTime.now();
                final inicioRango = hoy.subtract(const Duration(days: 5));
                final finRango = hoy.add(const Duration(days: 5));
                
                final dias = <DateTime>[];
                var temp = DateTime(inicioRango.year, inicioRango.month, inicioRango.day);
                while (temp.isBefore(finRango.add(const Duration(days: 1)))) {
                  dias.add(temp);
                  temp = temp.add(const Duration(days: 1));
                }

                final agendados = <FlSpot>[];
                final terminados = <FlSpot>[];
                final reagendados = <FlSpot>[];
                
                for (int i = 0; i < dias.length; i++) {
                  final dia = dias[i];
                  final inicioDia = DateTime(dia.year, dia.month, dia.day, 0, 0, 0).millisecondsSinceEpoch ~/ 1000;
                  final finDia = DateTime(dia.year, dia.month, dia.day, 23, 59, 59).millisecondsSinceEpoch ~/ 1000;
                  
                  final citasDia = citas.where((c) => c.fechaHoraFirma >= inicioDia && c.fechaHoraFirma <= finDia);
                  
                  agendados.add(FlSpot(i.toDouble(), citasDia.where((c) => c.estado != 'CANCELADA' && c.estado != 'CERRADA').length.toDouble()));
                  terminados.add(FlSpot(i.toDouble(), citasDia.where((c) => c.estado == 'CERRADA').length.toDouble()));
                  reagendados.add(FlSpot(i.toDouble(), citasDia.where((c) => c.estado == 'REAGENDADA').length.toDouble()));
                }

                // Calcular el máximo valor de las 3 series para el maxY
                final maxValor = [
                  ...agendados.map((s) => s.y),
                  ...terminados.map((s) => s.y),
                  ...reagendados.map((s) => s.y),
                ].reduce((a, b) => a > b ? a : b);
                
                // Redondear hacia arriba para dar margen (mínimo 5)
                final maxY = (maxValor + 2).ceilToDouble().clamp(5.0, double.infinity);
                final intervaloY = (maxY / 5).ceilToDouble();

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: intervaloY,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                      getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: intervaloY,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < dias.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('d MMM', 'es').format(dias[index]),
                                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade300),
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    minX: 0,
                    maxX: (dias.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                        if (event is FlTapUpEvent && touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
                          final spot = touchResponse.lineBarSpots!.first;
                          final index = spot.x.toInt();
                          if (index >= 0 && index < dias.length) {
                            final fechaSeleccionada = dias[index];
                            
                            String tipo = 'agendados';
                            if (spot.barIndex == 1) tipo = 'terminados';
                            if (spot.barIndex == 2) tipo = 'reagendados';
                            
                            // Llamar al callback del padre
                            onPuntoSeleccionado(fechaSeleccionada, tipo);
                          }
                        }
                      },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '${spot.y.toInt()} citas',
                              TextStyle(color: spot.bar.color, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: agendados,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: terminados,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: reagendados,
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _KpiMini extends StatelessWidget {
  final String label;
  final Stream<int> value;
  final Color color;

  const _KpiMini({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: value,
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox(height: 28);
                return Text('${snap.data}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color));
              },
            ),
          ],
        ),
      ),
    );
  }
}
