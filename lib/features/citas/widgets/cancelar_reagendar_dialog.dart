import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drift/drift.dart' hide Column; // IMPORTANTE: Import de Drift
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/dialogs.dart';
import '../../../data/database/app_database.dart';
import '../data/citas_repository.dart';
import '../domain/cita_estado.dart';

class CancelarReagendarDialog extends ConsumerStatefulWidget {
  final Cita cita;
  const CancelarReagendarDialog({super.key, required this.cita});

  static Future<void> show(BuildContext context, Cita cita) {
    return showDialog(
      context: context,
      builder: (_) => CancelarReagendarDialog(cita: cita),
    );
  }

  @override
  ConsumerState<CancelarReagendarDialog> createState() =>
      _CancelarReagendarDialogState();
}

class _CancelarReagendarDialogState
    extends ConsumerState<CancelarReagendarDialog> {
  final _motivoCtrl = TextEditingController();
  DateTime _nuevaFecha = DateTime.now().add(const Duration(days: 1));
  List<TimeOfDay> _horariosDisponibles = [];
  TimeOfDay? _horaSeleccionada;

  bool _esReagenda = true;
  bool _saving = false;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarHorarios() async {
    final db = ref.read(databaseProvider);
    final cfgRows = await db.select(db.configuracion).get();
    final cfg = {for (final r in cfgRows) r.clave: r.valor};

    final intervalo = int.tryParse(cfg['intervalo_minutos'] ?? '30') ?? 30;
    final horaInicioStr = cfg['hora_inicio_atencion'] ?? '09:00';
    final horaFinStr = cfg['hora_fin_atencion'] ?? '16:00';
    final maxCitas = int.tryParse(cfg['max_citas_por_hora'] ?? '2') ?? 2;

    final partesInicio = horaInicioStr.split(':');
    final partesFin = horaFinStr.split(':');
    final inicioHora = int.parse(partesInicio[0]);
    final inicioMinuto = int.parse(partesInicio[1]);
    final finHora = int.parse(partesFin[0]);
    final finMinuto = int.parse(partesFin[1]);

    // Generar bloques de tiempo
    final bloques = <TimeOfDay>[];
    var tempHora = inicioHora;
    var tempMinuto = inicioMinuto;
    while (tempHora < finHora ||
        (tempHora == finHora && tempMinuto < finMinuto)) {
      bloques.add(TimeOfDay(hour: tempHora, minute: tempMinuto));
      tempMinuto += intervalo;
      if (tempMinuto >= 60) {
        tempHora += 1;
        tempMinuto -= 60;
      }
    }

    // Consultar la DB para ver cuántas citas hay en cada bloque
    final inicioDia = DateTime(
      _nuevaFecha.year,
      _nuevaFecha.month,
      _nuevaFecha.day,
      0,
      0,
      0,
    );
    final finDia = inicioDia.add(const Duration(days: 1));
    final citasDia =
        await (db.select(db.citas)..where(
              (t) =>
                  t.fechaHoraFirma.isBiggerOrEqualValue(
                    inicioDia.millisecondsSinceEpoch ~/ 1000,
                  ) &
                  t.fechaHoraFirma.isSmallerThanValue(
                    finDia.millisecondsSinceEpoch ~/ 1000,
                  ) &
                  t.isDelete.equals(false) &
                  t.estado.equals(CitaEstado.cancelada.dbValue).not(),
            ))
            .get();

    final disponibles = <TimeOfDay>[];
    for (final bloque in bloques) {
      final fechaBloque = DateTime(
        _nuevaFecha.year,
        _nuevaFecha.month,
        _nuevaFecha.day,
        bloque.hour,
        bloque.minute,
      );
      final segundosBloque = fechaBloque.millisecondsSinceEpoch ~/ 1000;
      final citasEnBloque = citasDia
          .where((c) => c.fechaHoraFirma == segundosBloque)
          .length;
      if (citasEnBloque < maxCitas) {
        disponibles.add(bloque);
      }
    }

    if (mounted) {
      setState(() {
        _horariosDisponibles = disponibles;
        _horaSeleccionada = null;
      });
    }
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate: _nuevaFecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _nuevaFecha = picked);
      _cargarHorarios();
    }
  }

  Future<void> _guardar() async {
    final motivo = _motivoCtrl.text.trim();
    if (motivo.isEmpty) {
      await AppDialogs.error(
        context,
        'Debes escribir un motivo para continuar.',
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);
      final auth = ref.read(authProvider);
      final repo = CitasRepository(db);
      final userId = auth.userId ?? 1;

      if (_esReagenda) {
        if (_horaSeleccionada == null) {
          await AppDialogs.error(
            context,
            'Debes seleccionar un horario disponible.',
          );
          return;
        }
        final nuevaFechaHora = DateTime(
          _nuevaFecha.year,
          _nuevaFecha.month,
          _nuevaFecha.day,
          _horaSeleccionada!.hour,
          _horaSeleccionada!.minute,
        );
        await repo.hayDisponibilidad(nuevaFechaHora);

        await (db.update(
          db.citas,
        )..where((t) => t.id.equals(widget.cita.id))).write(
          CitasCompanion(
            fechaHoraFirma: Value(
              nuevaFechaHora.millisecondsSinceEpoch ~/ 1000,
            ),
            motivoUltimaReagenda: Value(motivo),
            reagendadaVeces: Value(widget.cita.reagendadaVeces + 1),
            dateUpdated: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
          ),
        );

        await repo.cambiarEstado(
          citaId: widget.cita.id,
          nuevoEstado: CitaEstado.reagendada,
          userId: userId,
        );

        if (mounted) {
          Navigator.of(context).pop();
          AppDialogs.success(
            context,
            'Cita reagendada. El correo ha sido encolado.',
          );
        }
      } else {
        await (db.update(
          db.citas,
        )..where((t) => t.id.equals(widget.cita.id))).write(
          CitasCompanion(
            motivoUltimaReagenda: Value(motivo),
            dateUpdated: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
          ),
        );
        await repo.cambiarEstado(
          citaId: widget.cita.id,
          nuevoEstado: CitaEstado.cancelada,
          userId: userId,
        );

        if (mounted) {
          Navigator.of(context).pop();
          AppDialogs.success(context, 'Cita cancelada definitivamente.');
        }
      }
    } catch (e) {
      if (mounted) AppDialogs.error(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 550,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.calendarXmark,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Gestionar Cita',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // SELECTOR TIPO (Reagendar / Cancelar)
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Reagendar'),
                    selected: _esReagenda,
                    onSelected: (v) => setState(() => _esReagenda = true),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: _esReagenda ? AppColors.primary : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Cancelar Definitivo'),
                    selected: !_esReagenda,
                    onSelected: (v) => setState(() => _esReagenda = false),
                    selectedColor: Colors.red.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: !_esReagenda ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // FECHA Y HORA (Solo si es reagenda)
            if (_esReagenda) ...[
              const Text(
                'Nueva Fecha y Hora',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const FaIcon(FontAwesomeIcons.calendarDays, size: 16),
                label: Text(dateFmt.format(_nuevaFecha)),
                onPressed: _pickFecha,
              ),
              const SizedBox(height: 12),
              if (_horariosDisponibles.isEmpty)
                const Text(
                  'No hay horarios disponibles para este día.',
                  style: TextStyle(color: Colors.red),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _horariosDisponibles.map((hora) {
                    final isSelected = _horaSeleccionada == hora;
                    return ChoiceChip(
                      label: Text(hora.format(context)),
                      selected: isSelected,
                      onSelected: (v) =>
                          setState(() => _horaSeleccionada = hora),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
            ],

            // MOTIVO
            const Text('Motivo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _motivoCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escribe el motivo de la cancelación o reagenda...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _esReagenda
                        ? AppColors.primary
                        : Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  onPressed: _saving ? null : _guardar,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : FaIcon(
                          _esReagenda
                              ? FontAwesomeIcons.calendarCheck
                              : FontAwesomeIcons.ban,
                          size: 16,
                        ),
                  label: Text(
                    _saving
                        ? 'Procesando...'
                        : (_esReagenda
                              ? 'Confirmar Reagenda'
                              : 'Confirmar Cancelación'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
