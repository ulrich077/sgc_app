import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/widgets/app_dialog_shell.dart';
import '../data/citas_repository.dart';

class NuevaCitaDialog extends ConsumerStatefulWidget {
  const NuevaCitaDialog({super.key});

  @override
  ConsumerState<NuevaCitaDialog> createState() => _NuevaCitaDialogState();
}

class _NuevaCitaDialogState extends ConsumerState<NuevaCitaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _dpi = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _notas = TextEditingController();
  DateTime _fecha = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 10, minute: 0);
  bool _saving = false;

  @override
  void dispose() {
    _nombre.dispose();
    _dpi.dispose();
    _correo.dispose();
    _telefono.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(context: context, initialTime: _hora);
    if (picked != null) setState(() => _hora = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authProvider);
    if (auth.userId == null) {
      await AppDialogs.error(context, 'Sesión no válida.');
      return;
    }
    setState(() => _saving = true);
    try {
      final dt = DateTime(
        _fecha.year,
        _fecha.month,
        _fecha.day,
        _hora.hour,
        _hora.minute,
      );
      await ref.read(citasRepositoryProvider).crear(
            personaNombre: _nombre.text.trim(),
            personaCorreo: _correo.text.trim(),
            fechaHoraFirma: dt,
            personaDpi: _dpi.text.trim().isEmpty ? null : _dpi.text.trim(),
            personaTelefono:
                _telefono.text.trim().isEmpty ? null : _telefono.text.trim(),
            notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
            creadaPor: auth.userId!,
          );
      if (!mounted) return;
      await AppDialogs.success(context, 'Cita creada correctamente.');
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      await AppDialogs.error(context, 'No se pudo crear la cita: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return AppDialogShell(
      title: 'Nueva cita',
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: const Text('Guardar'),
          onPressed: _saving ? null : _guardar,
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre completo *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _dpi,
              decoration: const InputDecoration(
                labelText: 'DPI',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo *',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                if (!v.contains('@')) return 'Correo inválido';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _telefono,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dateFmt.format(_fecha)),
                    onPressed: _pickFecha,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(_hora.format(context)),
                    onPressed: _pickHora,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _notas,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
