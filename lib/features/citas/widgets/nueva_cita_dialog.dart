import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/dialogs.dart';
import '../data/citas_repository.dart';

class NuevaCitaDialog extends ConsumerStatefulWidget {
  const NuevaCitaDialog({super.key});

  @override
  ConsumerState<NuevaCitaDialog> createState() => _NuevaCitaDialogState();
}

class _NuevaCitaDialogState extends ConsumerState<NuevaCitaDialog> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final _nombre = TextEditingController();
  final _dpi = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _notas = TextEditingController();
  
  DateTime _fecha = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 10, minute: 0);
  bool _saving = false;
  int _currentStep = 0;

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(context: context, initialTime: _hora);
    if (picked != null) setState(() => _hora = picked);
  }

  void _siguientePaso() {
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      if (_formKey2.currentState!.validate()) {
        setState(() => _currentStep = 2);
      }
    }
  }

  Future<void> _guardar() async {
    final auth = ref.read(authProvider);
    if (auth.userId == null) {
      await AppDialogs.error(context, 'Sesión no válida.');
      return;
    }
    setState(() => _saving = true);
    try {
      final dt = DateTime(_fecha.year, _fecha.month, _fecha.day, _hora.hour, _hora.minute);
      await ref.read(citasRepositoryProvider).crear(
            personaNombre: _nombre.text.trim(),
            personaCorreo: _correo.text.trim(),
            fechaHoraFirma: dt,
            personaDpi: _dpi.text.trim(),
            personaTelefono: _telefono.text.trim(),
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.lg)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER DEL MODAL
            Container(
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.lg)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_add_alt_1, color: Colors.white, size: 28),
                      const SizedBox(width: AppSizes.md),
                      const Expanded(
                        child: Text(
                          'Registrar Nueva Cita',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  // BARRA DE PROGRESO
                  Row(
                    children: [
                      _buildStepIndicator(1, 'Datos'),
                      _buildStepLine(_currentStep >= 1),
                      _buildStepIndicator(2, 'Contacto'),
                      _buildStepLine(_currentStep >= 2),
                      _buildStepIndicator(3, 'Resumen'),
                    ],
                  ),
                ],
              ),
            ),
            
            // CONTENIDO SCROLLEABLE
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentStep == 0
                      ? _Paso1(formKey: _formKey1, nombre: _nombre, dpi: _dpi, telefono: _telefono)
                      : _currentStep == 1
                          ? _Paso2(formKey: _formKey2, correo: _correo, fecha: _fecha, hora: _hora, onPickFecha: _pickFecha, onPickHora: _pickHora)
                          : _Paso3(nombre: _nombre, dpi: _dpi, correo: _correo, telefono: _telefono, notas: _notas, fecha: _fecha, hora: _hora),
                ),
              ),
            ),

            // FOOTER CON BOTONES
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSizes.lg)),
                border: const Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Atrás'),
                      onPressed: _saving ? null : () => setState(() => _currentStep--),
                    )
                  else
                    const SizedBox.shrink(),
                  if (_currentStep < 2)
                    FilledButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Siguiente'),
                      onPressed: _saving ? null : _siguientePaso,
                    ),
                  if (_currentStep == 2)
                    FilledButton.icon(
                      icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
                      label: const Text('Confirmar y Guardar'),
                      onPressed: _saving ? null : _guardar,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step - 1;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('$step', style: TextStyle(color: isActive ? AppColors.primary : Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 80,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
    );
  }
}

class _Paso1 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombre;
  final TextEditingController dpi;
  final TextEditingController telefono;

  const _Paso1({required this.formKey, required this.nombre, required this.dpi, required this.telefono});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paso 1: Datos Personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: AppSizes.lg),
          TextFormField(
            controller: nombre,
            decoration: const InputDecoration(labelText: 'Nombre completo *', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
            validator: (v) => v!.trim().isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: AppSizes.md),
          TextFormField(
            controller: dpi,
            keyboardType: TextInputType.number,
            maxLength: 13,
            decoration: const InputDecoration(labelText: 'DPI (13 dígitos) *', prefixIcon: Icon(Icons.badge), border: OutlineInputBorder(), counterText: ''),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Campo requerido';
              if (v.trim().length != 13) return 'Debe tener exactamente 13 dígitos';
              return null;
            },
          ),
          const SizedBox(height: AppSizes.md),
          TextFormField(
            controller: telefono,
            keyboardType: TextInputType.phone,
            maxLength: 8,
            decoration: const InputDecoration(labelText: 'Teléfono (8 dígitos) *', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(), counterText: ''),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Campo requerido';
              if (v.trim().length != 8) return 'Debe tener exactamente 8 dígitos';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _Paso2 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController correo;
  final DateTime fecha;
  final TimeOfDay hora;
  final VoidCallback onPickFecha;
  final VoidCallback onPickHora;

  const _Paso2({required this.formKey, required this.correo, required this.fecha, required this.hora, required this.onPickFecha, required this.onPickHora});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paso 2: Contacto y Fecha', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: AppSizes.lg),
          TextFormField(
            controller: correo,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Correo Electrónico *', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Campo requerido';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: AppSizes.xl),
          const Text('Fecha y Hora de Firma', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(dateFmt.format(fecha)),
                  onPressed: onPickFecha,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(hora.format(context)),
                  onPressed: onPickHora,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Paso3 extends StatelessWidget {
  final TextEditingController nombre;
  final TextEditingController dpi;
  final TextEditingController correo;
  final TextEditingController telefono;
  final TextEditingController notas;
  final DateTime fecha;
  final TimeOfDay hora;

  const _Paso3({required this.nombre, required this.dpi, required this.correo, required this.telefono, required this.notas, required this.fecha, required this.hora});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Paso 3: Resumen y Notas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: AppSizes.lg),
        
        // TICKET DE RESUMEN PREMIUM
        Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.md),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildTicketRow(Icons.person, 'Nombre', nombre.text),
              const Divider(),
              _buildTicketRow(Icons.badge, 'DPI', dpi.text),
              const Divider(),
              _buildTicketRow(Icons.phone, 'Teléfono', telefono.text),
              const Divider(),
              _buildTicketRow(Icons.email, 'Correo', correo.text),
              const Divider(),
              _buildTicketRow(Icons.event, 'Fecha de firma', '${dateFmt.format(fecha)} a las ${hora.format(context)}'),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        
        // NOTAS
        const Text('Notas Adicionales', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSizes.sm),
        TextFormField(
          controller: notas,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Agrega alguna observación sobre la cita (opcional)...',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSizes.md),
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        ],
      ),
    );
  }
}
