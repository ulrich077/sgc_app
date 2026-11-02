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
  ConsumerState<CancelarReagendarDialog> createState() => _CancelarReagendarDialogState();
}

class _CancelarReagendarDialogState extends ConsumerState<CancelarReagendarDialog> {
  final _motivoCtrl = TextEditingController();
  DateTime _nuevaFecha = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _nuevaHora = const TimeOfDay(hour: 10, minute: 0);
  
  bool _esReagenda = true;
  bool _saving = false;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nuevaFecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _nuevaFecha = picked);
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(context: context, initialTime: _nuevaHora);
    if (picked != null) setState(() => _nuevaHora = picked);
  }

  Future<void> _guardar() async {
    final motivo = _motivoCtrl.text.trim();
    if (motivo.isEmpty) {
      await AppDialogs.error(context, 'Debes escribir un motivo para continuar.');
      return;
    }

    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);
      final auth = ref.read(authProvider);
      final repo = CitasRepository(db);
      final userId = auth.userId ?? 1;

      if (_esReagenda) {
        final nuevaFechaHora = DateTime(_nuevaFecha.year, _nuevaFecha.month, _nuevaFecha.day, _nuevaHora.hour, _nuevaHora.minute);
        await repo.hayDisponibilidad(nuevaFechaHora);

        await (db.update(db.citas)..where((t) => t.id.equals(widget.cita.id))).write(
          CitasCompanion(
            fechaHoraFirma: Value(nuevaFechaHora.millisecondsSinceEpoch ~/ 1000),
            motivoUltimaReagenda: Value(motivo),
            reagendadaVeces: Value(widget.cita.reagendadaVeces + 1),
            dateUpdated: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
          ),
        );

        await repo.cambiarEstado(citaId: widget.cita.id, nuevoEstado: CitaEstado.reagendada, userId: userId);
        
        if (mounted) AppDialogs.success(context, 'Cita reagendada. El correo ha sido encolado.');
      } else {
        await (db.update(db.citas)..where((t) => t.id.equals(widget.cita.id))).write(
          CitasCompanion(
            motivoUltimaReagenda: Value(motivo),
            dateUpdated: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
          ),
        );
        await repo.cambiarEstado(citaId: widget.cita.id, nuevoEstado: CitaEstado.cancelada, userId: userId);

        if (mounted) AppDialogs.success(context, 'Cita cancelada definitivamente.');
      }

      if (mounted) Navigator.of(context).pop();
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const FaIcon(FontAwesomeIcons.calendarXmark, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text('Gestionar Cita', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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
                    labelStyle: TextStyle(color: _esReagenda ? AppColors.primary : Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Cancelar Definitivo'),
                    selected: !_esReagenda,
                    onSelected: (v) => setState(() => _esReagenda = false),
                    selectedColor: Colors.red.withValues(alpha: 0.2),
                    labelStyle: TextStyle(color: !_esReagenda ? Colors.red : Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // FECHA Y HORA (Solo si es reagenda)
            if (_esReagenda) ...[
              const Text('Nueva Fecha y Hora', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const FaIcon(FontAwesomeIcons.calendarDays, size: 16),
                      label: Text(dateFmt.format(_nuevaFecha)),
                      onPressed: _pickFecha,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const FaIcon(FontAwesomeIcons.clock, size: 16),
                      label: Text(_nuevaHora.format(context)),
                      onPressed: _pickHora,
                    ),
                  ),
                ],
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
                    backgroundColor: _esReagenda ? AppColors.primary : Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: _saving ? null : _guardar,
                  icon: _saving 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : FaIcon(_esReagenda ? FontAwesomeIcons.calendarCheck : FontAwesomeIcons.ban, size: 16),
                  label: Text(_saving ? 'Procesando...' : (_esReagenda ? 'Confirmar Reagenda' : 'Confirmar Cancelación')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
