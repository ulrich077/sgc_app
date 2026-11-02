import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _contrato = TextEditingController();
  final _puesto = TextEditingController();
  final _salario = TextEditingController();
  final _ubicacionEspecifica = TextEditingController();
  final _fechaInicio = TextEditingController();
  final _fechaFin = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime(DateTime.now().year, 12, 31)));
  String? _direccionSeleccionada;
  final _notas = TextEditingController();
  
  final List<String> _direcciones = [
    'Dirección General',
    'Dirección de Recursos Humanos',
    'Dirección de Protocolo y Atención Ciudadana',
    'Dirección de Informática y Telecomunicaciones',
    'Dirección de Asuntos Jurídicos',
    'Dirección de Auditoría Interna',
    'Dirección Financiera',
    'Dirección de Estudios e Investigación Legislativa',
    'Dirección Legislativa',
    'Dirección de Comunicación Social y Relaciones Públicas',
    'Dirección Administrativa',
  ];

  DateTime _fecha = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 10, minute: 0);
  bool _saving = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nombre.dispose();
    _dpi.dispose();
    _telefono.dispose();
    _correo.dispose();
    _contrato.dispose();
    _puesto.dispose();
    _salario.dispose();
    _ubicacionEspecifica.dispose();
    _fechaInicio.dispose();
    _fechaFin.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
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

  Future<void> _pickFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _fechaInicio.text = DateFormat('dd/MM/yyyy').format(picked);
        // Auto-completar la fecha fin con el 31 de diciembre del mismo año
        final finDeAnio = DateTime(picked.year, 12, 31);
        _fechaFin.text = DateFormat('dd/MM/yyyy').format(finDeAnio);
      });
    }
  }

  Future<void> _pickFechaFin() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate: DateTime.now(), // O el 31 de dic del año actual
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _fechaFin.text = DateFormat('dd/MM/yyyy').format(picked));
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
      final repo = ref.read(citasRepositoryProvider);
      await repo.hayDisponibilidad(dt);

      await repo.crear(
        personaNombre: _nombre.text.trim(),
        personaCorreo: _correo.text.trim(),
        fechaHoraFirma: dt,
        personaDpi: _dpi.text.trim(),
        personaTelefono: _telefono.text.trim(),
        notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
        creadaPor: auth.userId!,
        numeroContrato: _contrato.text.trim().isEmpty ? null : _contrato.text.trim(),
        puesto: _puesto.text.trim().isEmpty ? null : _puesto.text.trim(),
        salario: _salario.text.trim().isEmpty ? null : _salario.text.trim(),
        ubicacion: _direccionSeleccionada,
        ubicacionEspecifica: _ubicacionEspecifica.text.trim().isEmpty ? null : _ubicacionEspecifica.text.trim(),
        fechaInicio: _fechaInicio.text.trim().isEmpty ? null : _fechaInicio.text.trim(),
        fechaFin: _fechaFin.text.trim().isEmpty ? null : _fechaFin.text.trim(),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 750,
        constraints: const BoxConstraints(maxHeight: 850),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER PREMIUM
              Container(
                padding: const EdgeInsets.all(AppSizes.xl),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const FaIcon(FontAwesomeIcons.userPlus, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text('Registrar Nueva Cita', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop(false)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
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
              
              // CONTENIDO
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentStep == 0
                        ? _Paso1(
                            formKey: _formKey1,
                            nombre: _nombre,
                            dpi: _dpi,
                            telefono: _telefono,
                            contrato: _contrato,
                            puesto: _puesto,
                            salario: _salario,
                            direccionSeleccionada: _direccionSeleccionada,
                            onDireccionChanged: (val) => setState(() => _direccionSeleccionada = val),
                            ubicacionEspecifica: _ubicacionEspecifica,
                            fechaInicio: _fechaInicio,
                            fechaFin: _fechaFin,
                            onPickFechaInicio: _pickFechaInicio,
                            onPickFechaFin: _pickFechaFin,
                            direcciones: _direcciones,
                          )
                        : _currentStep == 1
                            ? _Paso2(formKey: _formKey2, correo: _correo, fecha: _fecha, hora: _hora, onPickFecha: _pickFecha, onPickHora: _pickHora)
                            : _Paso3(nombre: _nombre, dpi: _dpi, correo: _correo, telefono: _telefono, notas: _notas, fecha: _fecha, hora: _hora, direccion: _direccionSeleccionada ?? '', puesto: _puesto.text, salario: _salario.text),
                  ),
                ),
              ),

              // FOOTER PREMIUM
              Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton.icon(
                        icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 14),
                        label: const Text('Atrás'),
                        onPressed: _saving ? null : () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (_currentStep < 2)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const FaIcon(FontAwesomeIcons.arrowRight, size: 14),
                        label: const Text('Siguiente'),
                        onPressed: _saving ? null : _siguientePaso,
                      ),
                    if (_currentStep == 2)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const FaIcon(FontAwesomeIcons.check, size: 14),
                        label: const Text('Guardar Cita'),
                        onPressed: _saving ? null : _guardar,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step - 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive 
              ? const FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 10)
              : Text('$step', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: isActive ? AppColors.primary : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: isActive ? AppColors.primary : Colors.grey.shade200,
      ),
    );
  }
}

class _Paso1 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombre;
  final TextEditingController dpi;
  final TextEditingController telefono;
  final TextEditingController contrato;
  final TextEditingController puesto;
  final TextEditingController salario;
  final TextEditingController ubicacionEspecifica;
  final TextEditingController fechaInicio;
  final TextEditingController fechaFin;
  final String? direccionSeleccionada;
  final Function(String?) onDireccionChanged;
  final List<String> direcciones;
  final VoidCallback onPickFechaInicio;
  final VoidCallback onPickFechaFin;

  const _Paso1({
    required this.formKey,
    required this.nombre,
    required this.dpi,
    required this.telefono,
    required this.contrato,
    required this.puesto,
    required this.salario,
    required this.ubicacionEspecifica,
    required this.fechaInicio,
    required this.fechaFin,
    required this.direccionSeleccionada,
    required this.onDireccionChanged,
    required this.direcciones,
    required this.onPickFechaInicio,
    required this.onPickFechaFin,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Datos Personales',
            icon: FontAwesomeIcons.user,
            children: [
              TextFormField(
                controller: nombre,
                decoration: _inputDecoration('Nombre completo *', FontAwesomeIcons.solidUser),
                validator: (v) => v!.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: dpi,
                      keyboardType: TextInputType.number,
                      maxLength: 13,
                      decoration: _inputDecoration('DPI (13 dígitos) *', FontAwesomeIcons.idCard, counterText: ''),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (v.trim().length != 13) return 'Debe ser 13 dígitos';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextFormField(
                      controller: telefono,
                      keyboardType: TextInputType.phone,
                      maxLength: 8,
                      decoration: _inputDecoration('Teléfono (8 dígitos) *', FontAwesomeIcons.phone, counterText: ''),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (v.trim().length != 8) return 'Debe ser 8 dígitos';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.lg),
          
          _SectionCard(
            title: 'Datos para Contraloría General de Cuentas',
            icon: FontAwesomeIcons.buildingColumns,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: contrato,
                      decoration: _inputDecoration('No. de Contrato', FontAwesomeIcons.fileContract),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextFormField(
                      controller: puesto,
                      decoration: _inputDecoration('Puesto', FontAwesomeIcons.briefcase),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: salario,
                      decoration: _inputDecoration('Salario / Honorarios', FontAwesomeIcons.moneyBill),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: direccionSeleccionada,
                      isExpanded: true,
                      decoration: _inputDecoration('Dirección Asignada', FontAwesomeIcons.building),
                      items: direcciones.map((dir) => DropdownMenuItem(value: dir, child: Text(dir, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: onDireccionChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: ubicacionEspecifica,
                decoration: _inputDecoration('Ubicación Específica (Opcional)', FontAwesomeIcons.locationDot),
                enabled: direccionSeleccionada != null,
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: fechaInicio,
                      readOnly: true,
                      decoration: _inputDecoration('Fecha de Inicio', FontAwesomeIcons.calendarDays),
                      onTap: onPickFechaInicio,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextFormField(
                      controller: fechaFin,
                      readOnly: true,
                      decoration: _inputDecoration('Fecha de Fin', FontAwesomeIcons.calendarDays),
                      onTap: onPickFechaFin,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, dynamic icon, {String? counterText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 12.0, top: 14.0, bottom: 14.0),
        child: Center(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: FaIcon(icon, size: 16, color: Colors.grey.shade400),
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      counterText: counterText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final FaIconData icon;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, color: AppColors.primary, size: 16),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
            ],
          ),
          const Divider(height: 24),
          ...children,
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
      child: _SectionCard(
        title: 'Contacto y Fecha de Firma',
        icon: FontAwesomeIcons.calendarCheck,
        children: [
          TextFormField(
            controller: correo,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico *',
              labelStyle: const TextStyle(color: Colors.grey),
              floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 16.0, right: 12.0, top: 14.0, bottom: 14.0),
                child: Center(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: FaIcon(FontAwesomeIcons.solidEnvelope, size: 16, color: Colors.grey),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Campo requerido';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  icon: const FaIcon(FontAwesomeIcons.calendarDays, size: 16, color: Colors.grey),
                  label: Text(dateFmt.format(fecha), style: const TextStyle(color: Colors.black87)),
                  onPressed: onPickFecha,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  icon: const FaIcon(FontAwesomeIcons.clock, size: 16, color: Colors.grey),
                  label: Text(hora.format(context), style: const TextStyle(color: Colors.black87)),
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
  final String direccion;
  final String puesto;
  final String salario;

  const _Paso3({
    required this.nombre,
    required this.dpi,
    required this.correo,
    required this.telefono,
    required this.notas,
    required this.fecha,
    required this.hora,
    required this.direccion,
    required this.puesto,
    required this.salario,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Resumen de la Cita',
          icon: FontAwesomeIcons.clipboardCheck,
          children: [
            _buildTicketRow(FontAwesomeIcons.solidUser, 'Nombre', nombre.text),
            const Divider(),
            _buildTicketRow(FontAwesomeIcons.idCard, 'DPI', dpi.text),
            const Divider(),
            _buildTicketRow(FontAwesomeIcons.phone, 'Teléfono', telefono.text),
            const Divider(),
            _buildTicketRow(FontAwesomeIcons.solidEnvelope, 'Correo', correo.text),
            if (puesto.isNotEmpty) ...[
              const Divider(),
              _buildTicketRow(FontAwesomeIcons.briefcase, 'Puesto', puesto),
            ],
            if (salario.isNotEmpty) ...[
              const Divider(),
              _buildTicketRow(FontAwesomeIcons.moneyBill, 'Salario', salario),
            ],
            if (direccion.isNotEmpty) ...[
              const Divider(),
              _buildTicketRow(FontAwesomeIcons.building, 'Dirección', direccion),
            ],
            const Divider(),
            _buildTicketRow(FontAwesomeIcons.calendarDays, 'Fecha de firma', '${dateFmt.format(fecha)} a las ${hora.format(context)}'),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        _SectionCard(
          title: 'Notas Adicionales',
          icon: FontAwesomeIcons.penToSquare,
          children: [
            TextFormField(
              controller: notas,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Agrega alguna observación sobre la cita (opcional)...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketRow(FaIconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSizes.md),
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        ],
      ),
    );
  }
}
