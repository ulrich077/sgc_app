import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as cp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/theme_colors_provider.dart';
import '../../core/utils/dialogs.dart';
import '../../core/network/mdns_discovery.dart';
import '../../data/database/app_database.dart';
import '../citas/widgets/drop_zone.dart'; // Reutilizamos el DropZone
import 'correos_tab.dart';
import 'smtp_config_tab.dart';
import '../../core/network/bonjour_helper.dart';
import '../../core/network/cert_service.dart';
import '../../main.dart' as app_main;

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menu = [
    {'title': 'Apariencia', 'icon': Icons.palette_outlined, 'type': 'colors'},
    {'title': 'Conexión de Red', 'icon': Icons.dns_outlined, 'type': 'network'},
    {'title': 'Agenda', 'icon': Icons.calendar_month, 'type': 'agenda'},
    {
      'title': 'Correo de Prueba',
      'icon': Icons.mark_email_unread_outlined,
      'type': 'template',
      'clave': 'plantilla_prueba',
    },
    {
      'title': 'Correo de Reagenda',
      'icon': Icons.calendar_today_outlined,
      'type': 'template',
      'clave': 'plantilla_reagenda',
    },
    {
      'title': 'Correo Final',
      'icon': Icons.attachment_outlined,
      'type': 'template',
      'clave': 'plantilla_final',
    },
    {'title': 'Servidor SMTP', 'icon': Icons.dns_outlined, 'type': 'smtp'},
    {'title': 'Cola de Correos', 'icon': Icons.email_outlined, 'type': 'queue'},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ajustes')),
        body: const Center(child: Text(AppStrings.noPermission)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: const Text(
          'Ajustes del sistema',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Ir al Dashboard',
            icon: const Icon(
              Icons.dashboard_outlined,
              color: AppColors.primary,
            ),
            onPressed: () => context.go('/dashboard'),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
          const SizedBox(width: AppSizes.md),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 280,
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(AppSizes.md),
                  itemCount: _menu.length,
                  itemBuilder: (context, index) {
                    final item = _menu[index];
                    final isSelected = _selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: ListTile(
                          leading: Icon(
                            item['icon'],
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          title: Text(
                            item['title'],
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () => setState(() => _selectedIndex = index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSizes.xl),
            Expanded(
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final item = _menu[_selectedIndex];
    if (item['type'] == 'colors') return const _ColorPanelWrapper();
    if (item['type'] == 'network') return const _NetworkPanel();
    if (item['type'] == 'agenda') return const _AgendaPanel();
    if (item['type'] == 'template') {
      return _PlantillaEditor(clave: item['clave'], titulo: item['title']);
    }
    if (item['type'] == 'smtp') return const SmtpConfigTab();
    if (item['type'] == 'queue') return const CorreosTab();
    return const SizedBox();
  }
}

class _ColorPanelWrapper extends ConsumerStatefulWidget {
  const _ColorPanelWrapper();
  @override
  ConsumerState<_ColorPanelWrapper> createState() => _ColorPanelWrapperState();
}

class _ColorPanelWrapperState extends ConsumerState<_ColorPanelWrapper> {
  late Color _primary;
  late Color _secondary;
  String? _logoBase64;
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    final db = ref.read(databaseProvider);
    final colors = ref
        .read(themeColorsProvider)
        .maybeWhen(data: (c) => c, orElse: () => ThemeColors.defaults);
    final logoRow = await (db.select(
      db.configuracion,
    )..where((t) => t.clave.equals('empresa_logo_base64'))).getSingleOrNull();

    setState(() {
      _primary = colors.primary;
      _secondary = colors.secondary;
      _logoBase64 = logoRow?.valor;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    await _upsert(db, 'color_primary', colorToHex(_primary));
    await _upsert(db, 'color_secondary', colorToHex(_secondary));
    if (_logoBase64 != null) {
      await _upsert(db, 'empresa_logo_base64', _logoBase64!);
    }

    ref.invalidate(themeColorsProvider);
    if (!mounted) return;
    setState(() => _saving = false);
    await AppDialogs.success(
      context,
      'Apariencia y logo guardados correctamente.',
    );
  }

  Future<void> _upsert(AppDatabase db, String clave, String valor) async {
    final existing = await (db.select(
      db.configuracion,
    )..where((t) => t.clave.equals(clave))).getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.configuracion)
          .insert(
            ConfiguracionCompanion.insert(
              clave: clave,
              valor: Value(valor),
              tipo: const Value('string'),
            ),
          );
    } else {
      await (db.update(db.configuracion)..where((t) => t.clave.equals(clave)))
          .write(ConfiguracionCompanion(valor: Value(valor)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Colores y Logo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: AppSizes.sm),
        const Text(
          'Personaliza los colores y el logo de la institución.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.xl),

        Row(
          children: [
            _ColorSwatch(
              label: 'Color Primario',
              color: _primary,
              onTap: () => _pickColor(true),
            ),
            const SizedBox(width: AppSizes.xl),
            _ColorSwatch(
              label: 'Color Secundario',
              color: _secondary,
              onTap: () => _pickColor(false),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.xl),

        const Text(
          'Logo de la Institución',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: AppSizes.sm),

        // DISEÑO PREMIUM DE LOGO CON DRAG & DROP
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_logoBase64 != null && _logoBase64!.isNotEmpty)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(_logoBase64!),
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) =>
                        const Center(child: Text('Error de imagen')),
                  ),
                ),
              )
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            const SizedBox(width: AppSizes.xl),
            Expanded(
              child: DropZone(
                titulo: 'Arrastra aquí el logo',
                subtitulo:
                    'O haz clic para buscarlo en tu equipo. Formato PNG o JPG.',
                icono: FontAwesomeIcons.cloudArrowUp,
                onFileDropped: (path) async {
                  final file = File(path);
                  final bytes = await file.readAsBytes();
                  setState(() => _logoBase64 = base64Encode(bytes));
                },
              ),
            ),
          ],
        ),

        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: const Text('Guardar Cambios'),
          ),
        ),
      ],
    );
  }

  Future<void> _pickColor(bool isPrimary) async {
    Color temp = isPrimary ? _primary : _secondary;
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Seleccionar Color'),
        content: SingleChildScrollView(
          child: cp.ColorPicker(
            pickerColor: temp,
            onColorChanged: (c) => temp = c,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                if (isPrimary) {
                  _primary = temp;
                } else {
                  _secondary = temp;
                }
              });
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ColorSwatch({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: AppSizes.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 120,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlantillaEditor extends ConsumerStatefulWidget {
  final String clave;
  final String titulo;
  const _PlantillaEditor({required this.clave, required this.titulo});

  @override
  ConsumerState<_PlantillaEditor> createState() => _PlantillaEditorState();
}

class _PlantillaEditorState extends ConsumerState<_PlantillaEditor> {
  final _ctrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _isHtml = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(
      db.configuracion,
    )..where((t) => t.clave.equals(widget.clave))).getSingleOrNull();
    if (mounted) {
      setState(() {
        _ctrl.text = row?.valor ?? '';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final existing = await (db.select(
      db.configuracion,
    )..where((t) => t.clave.equals(widget.clave))).getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.configuracion)
          .insert(
            ConfiguracionCompanion.insert(
              clave: widget.clave,
              valor: Value(_ctrl.text),
              tipo: const Value('string'),
            ),
          );
    } else {
      await (db.update(db.configuracion)
            ..where((t) => t.clave.equals(widget.clave)))
          .write(ConfiguracionCompanion(valor: Value(_ctrl.text)));
    }
    if (!mounted) return;
    setState(() => _saving = false);
    await AppDialogs.success(context, 'Plantilla guardada');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSizes.md,
          runSpacing: AppSizes.sm,
          children: [
            Text(
              widget.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Modo HTML',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Switch(
                  value: _isHtml,
                  onChanged: (v) => setState(() => _isHtml = v),
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.sm),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save, size: 16),
                  label: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _isHtml ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _ctrl,
              maxLines: null,
              expands: true,
              style: TextStyle(
                fontFamily: _isHtml ? 'Courier' : null,
                fontSize: 14,
                color: _isHtml ? Colors.greenAccent : AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgendaPanel extends ConsumerStatefulWidget {
  const _AgendaPanel();
  @override
  ConsumerState<_AgendaPanel> createState() => _AgendaPanelState();
}

class _AgendaPanelState extends ConsumerState<_AgendaPanel> {
  final _ctrlMaxCitas = TextEditingController();
  String _intervalo = '30';
  String _horaInicio = '09:00';
  String _horaFin = '16:00';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final rows = await db.select(db.configuracion).get();
    final cfg = {for (final r in rows) r.clave: r.valor};

    if (mounted) {
      setState(() {
        _ctrlMaxCitas.text = cfg['max_citas_por_hora'] ?? '2';
        _intervalo = cfg['intervalo_minutos'] ?? '30';
        _horaInicio = cfg['hora_inicio_atencion'] ?? '09:00';
        _horaFin = cfg['hora_fin_atencion'] ?? '16:00';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);

    await _upsert(db, 'max_citas_por_hora', _ctrlMaxCitas.text.trim());
    await _upsert(db, 'intervalo_minutos', _intervalo);
    await _upsert(db, 'hora_inicio_atencion', _horaInicio);
    await _upsert(db, 'hora_fin_atencion', _horaFin);

    if (mounted) {
      setState(() => _saving = false);
      await AppDialogs.success(context, 'Configuración de agenda guardada.');
    }
  }

  Future<void> _upsert(AppDatabase db, String clave, String valor) async {
    final existing = await (db.select(
      db.configuracion,
    )..where((t) => t.clave.equals(clave))).getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.configuracion)
          .insert(
            ConfiguracionCompanion.insert(
              clave: clave,
              valor: Value(valor),
              tipo: const Value('string'),
            ),
          );
    } else {
      await (db.update(db.configuracion)..where((t) => t.clave.equals(clave)))
          .write(ConfiguracionCompanion(valor: Value(valor)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuración de Agenda',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: AppSizes.sm),
        const Text(
          'Define el intervalo de tiempo y el máximo de citas por bloque.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.xl),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _intervalo,
                decoration: const InputDecoration(
                  labelText: 'Intervalo entre citas',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '15', child: Text('Cada 15 minutos')),
                  DropdownMenuItem(value: '30', child: Text('Cada 30 minutos')),
                  DropdownMenuItem(value: '45', child: Text('Cada 45 minutos')),
                ],
                onChanged: (v) => setState(() => _intervalo = v!),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: TextField(
                controller: _ctrlMaxCitas,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Máximo de citas por bloque',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: _horaInicio),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Hora de Inicio de Atención',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: 9, minute: 0),
                  );
                  if (picked != null) {
                    setState(
                      () => _horaInicio =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: _horaFin),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Hora de Fin de Atención',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: 16, minute: 0),
                  );
                  if (picked != null) {
                    setState(
                      () => _horaFin =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                    );
                  }
                },
              ),
            ),
          ],
        ),

        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: const Text('Guardar Agenda'),
          ),
        ),
      ],
    );
  }
}

class _NetworkPanel extends ConsumerStatefulWidget {
  const _NetworkPanel();
  @override
  ConsumerState<_NetworkPanel> createState() => _NetworkPanelState();
}

class _NetworkPanelState extends ConsumerState<_NetworkPanel> {
  final _ipCtrl = TextEditingController();
  bool _buscando = false;
  bool _saving = false;
  bool _generando = false;
  bool _esServidor = false;
  bool _cambiandoModo = false;
  String? _mensaje;
  ({String rutaCert, DateTime generadoEn, DateTime validoHasta})? _certInfo;

  @override
  void initState() {
    super.initState();
    _loadIp();
    _cargarCertInfo();
  }

  Future<void> _cargarCertInfo() async {
    final info = await CertService.info();
    if (mounted) setState(() => _certInfo = info);
  }

  Future<void> _loadIp() async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(
      db.configuracion,
    )..where((t) => t.clave.equals('servidor_ip'))).getSingleOrNull();
    final modoRow = await (db.select(db.configuracion)
          ..where((t) => t.clave.equals('es_servidor')))
        .getSingleOrNull();
    if (mounted) {
      setState(() {
        _ipCtrl.text = row?.valor ?? '';
        _esServidor = (modoRow?.valor ?? 'false') == 'true';
      });
    }
  }

  Future<void> _cambiarModo(bool aServidor) async {
    final confirmar = await AppDialogs.confirm(
      context,
      aServidor
          ? 'Vas a activar el MODO SERVIDOR en esta máquina.\n\n'
            'Esto iniciará el servidor SGC, anunciará el servicio en la red '
            'y permitirá que otras computadoras se conecten a esta.\n\n'
            'La aplicación se reiniciará para aplicar el cambio.'
          : 'Vas a cambiar a MODO CLIENTE.\n\n'
            'Esta máquina dejará de actuar como servidor y buscará '
            'conectarse a otro servidor en la red.\n\n'
            'La aplicación se reiniciará para aplicar el cambio.',
      title: aServidor ? 'Activar modo servidor' : 'Cambiar a modo cliente',
      confirmLabel: aServidor ? 'Sí, activar servidor' : 'Sí, cambiar a cliente',
    );
    if (!confirmar) return;

    setState(() => _cambiandoModo = true);
    final db = ref.read(databaseProvider);
    await (db.update(db.configuracion)
          ..where((t) => t.clave.equals('es_servidor')))
        .write(ConfiguracionCompanion(valor: Value(aServidor ? 'true' : 'false')));
    if (!mounted) return;
    setState(() {
      _cambiandoModo = false;
      _esServidor = aServidor;
    });

    final reiniciar = await AppDialogs.confirm(
      context,
      aServidor
          ? 'Modo SERVIDOR activado.\n\n'
            'La aplicación se reiniciará para iniciar el servidor SGC.\n\n'
            '⚠️ Deberás abrirla manualmente de nuevo desde el Dock/Launchpad.'
          : 'Modo CLIENTE activado.\n\n'
            'La aplicación se reiniciará para detener el servidor SGC.\n\n'
            '⚠️ Deberás abrirla manualmente de nuevo desde el Dock/Launchpad.',
      title: 'Modo cambiado',
      confirmLabel: 'Reiniciar ahora',
      cancelLabel: 'Descartar',
    );
    if (!reiniciar) return;
    if (!mounted) return;
    await _mostrarCuentaRegresiva();
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscarServidor() async {
    // ¿Hay Bonjour? En Windows sin Bonjour, ni intentamos.
    final hayBonjour = await BonjourHelper.disponible();
    if (!hayBonjour) {
      if (mounted) {
        setState(() {
          _mensaje = BonjourHelper.mensajeNoDisponible;
        });
      }
      return;
    }

    setState(() {
      _buscando = true;
      _mensaje = 'Buscando servidor en la red...';
    });

    final ip = await MdnsDiscovery.buscarServidor();

    if (mounted) {
      setState(() {
        _buscando = false;
        if (ip != null) {
          _ipCtrl.text = ip;
          _mensaje = 'Servidor encontrado en: $ip';
        } else {
          _mensaje =
              'No se encontró el servidor. '
              'Verifica que estés en la misma red o ingresa la IP manualmente.';
        }
      });
    }
  }

  Future<void> _conectar() async {
    final ip = _ipCtrl.text.trim();
    if (ip.isEmpty) {
      await AppDialogs.error(context, 'Ingresa una IP válida.');
      return;
    }
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);

    await (db.update(db.configuracion)
          ..where((t) => t.clave.equals('servidor_ip')))
        .write(ConfiguracionCompanion(valor: Value(ip)));
    await (db.update(db.configuracion)
          ..where((t) => t.clave.equals('es_servidor')))
        .write(ConfiguracionCompanion(valor: Value('false')));

    if (mounted) {
      setState(() => _saving = false);
      await AppDialogs.success(
        context,
        'Conectado al servidor $ip. Reinicia la aplicación para aplicar los cambios.',
      );
    }
  }

  Future<void> _generarCertificado() async {
    final yaExiste = await CertService.existe();
    if (!mounted) return;
    if (yaExiste) {
      final ok = await AppDialogs.confirm(
        context,
        'Ya existe un certificado TLS.\n'
        '¿Deseas regenerarlo? Las conexiones actuales se invalidarán '
        'hasta reiniciar la aplicación.',
        title: 'Regenerar certificado',
        confirmLabel: 'Sí, regenerar',
      );
      if (!ok) return;
    }

    setState(() => _generando = true);
    try {
      await CertService.generar();
      await _cargarCertInfo();
      if (!mounted) return;
      setState(() => _generando = false);

      final reiniciar = await AppDialogs.confirm(
        context,
        'Certificado generado correctamente.\n\n'
        'Para aplicar TLS, la aplicación debe reiniciarse.\n\n'
        '⚠️ Al reiniciar, la aplicación se cerrará y deberás '
        'abrirla manualmente de nuevo desde el Dock/Launchpad.',
        title: 'Certificado generado',
        confirmLabel: 'Reiniciar ahora',
        cancelLabel: 'Descartar',
      );
      if (!reiniciar) return;
      if (!mounted) return;
      await _mostrarCuentaRegresiva();
    } catch (e) {
      if (!mounted) return;
      setState(() => _generando = false);
      await AppDialogs.error(context, 'Error al generar certificado: $e');
    }
  }

  Future<void> _eliminarCertificado() async {
    final ok = await AppDialogs.confirm(
      context,
      '¿Eliminar el certificado TLS actual?\n'
      'El servidor volverá a HTTP plano hasta que generes uno nuevo.',
      title: 'Eliminar certificado',
      confirmLabel: 'Sí, eliminar',
    );
    if (!ok) return;
    await CertService.borrar();
    await _cargarCertInfo();
    if (mounted) {
      await AppDialogs.success(context, 'Certificado eliminado.');
    }
  }

  Future<void> _mostrarCuentaRegresiva() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CuentaRegresivaDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final esServidor = auth.isAdmin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conexión de Red',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: AppSizes.sm),
        const Text(
          'Busca el servidor SGC en tu red local o ingresa la IP manualmente.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.xl),

        TextField(
          controller: _ipCtrl,
          decoration: InputDecoration(
            labelText: 'IP del Servidor',
            hintText: 'Ej. 192.168.1.50',
            prefixIcon: const Icon(Icons.network_check),
            suffixIcon: IconButton(
              icon: _buscando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              onPressed: _buscando ? null : _buscarServidor,
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        if (_mensaje != null) ...[
          const SizedBox(height: 8),
          Text(
            _mensaje!,
            style: TextStyle(
              color: _mensaje!.contains('encontrado')
                  ? Colors.green
                  : Colors.orange,
            ),
          ),
        ],
        const SizedBox(height: AppSizes.xl),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _buscando ? null : _buscarServidor,
              icon: const Icon(Icons.search),
              label: const Text('Buscar Servidor'),
            ),
            const SizedBox(width: AppSizes.md),
            FilledButton.icon(
              onPressed: _saving ? null : _conectar,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.link),
              label: const Text('Conectar'),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.xxl),
        const Divider(),
        const SizedBox(height: AppSizes.lg),
        const Text(
          'Modo de esta máquina',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: AppSizes.sm),
        const Text(
          'Elige si esta computadora actuará como servidor (guarda los datos '
          'y atiende a los clientes) o como cliente (se conecta al servidor).',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.lg),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(
                _esServidor ? Icons.dns_outlined : Icons.computer,
                color: _esServidor ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _esServidor ? 'Servidor' : 'Cliente',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _esServidor
                          ? 'Esta máquina guarda los datos y atiende a los clientes'
                          : 'Esta máquina se conecta al servidor',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _esServidor,
                onChanged: _cambiandoModo
                    ? null
                    : (v) => _cambiarModo(v),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ),
        if (_cambiandoModo) ...[
          const SizedBox(height: AppSizes.sm),
          const LinearProgressIndicator(),
        ],

        if (esServidor) ...[
          const SizedBox(height: AppSizes.xxl),
          const Divider(),
          const SizedBox(height: AppSizes.lg),
          const Text(
            'Certificado TLS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Genera un certificado autofirmado para que el servidor '
            'use HTTPS en la red local. Solo el administrador puede '
            'generarlo, y solo en la máquina que actúa como servidor.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.lg),
          FilledButton.icon(
            onPressed: _generando ? null : _generarCertificado,
            icon: _generando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.security),
            label: const Text('Generar certificado TLS'),
          ),
          const SizedBox(height: AppSizes.lg),
          if (_certInfo != null) ...[
            TextField(
              enabled: false,
              controller: TextEditingController(
                text: 'Activo',
              ),
              decoration: const InputDecoration(
                labelText: 'Estado',
                prefixIcon: Icon(Icons.check_circle, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              enabled: false,
              controller: TextEditingController(text: _certInfo!.rutaCert),
              decoration: const InputDecoration(
                labelText: 'Ruta del certificado',
                prefixIcon: Icon(Icons.folder_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              enabled: false,
              controller: TextEditingController(
                text:
                    '${_certInfo!.generadoEn.day.toString().padLeft(2, '0')}/'
                    '${_certInfo!.generadoEn.month.toString().padLeft(2, '0')}/'
                    '${_certInfo!.generadoEn.year} '
                    '${_certInfo!.generadoEn.hour.toString().padLeft(2, '0')}:'
                    '${_certInfo!.generadoEn.minute.toString().padLeft(2, '0')}',
              ),
              decoration: const InputDecoration(
                labelText: 'Generado',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              enabled: false,
              controller: TextEditingController(
                text:
                    '${_certInfo!.validoHasta.day.toString().padLeft(2, '0')}/'
                    '${_certInfo!.validoHasta.month.toString().padLeft(2, '0')}/'
                    '${_certInfo!.validoHasta.year}',
              ),
              decoration: const InputDecoration(
                labelText: 'Válido hasta',
                prefixIcon: Icon(Icons.event_available),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            OutlinedButton.icon(
              onPressed: _eliminarCertificado,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Eliminar certificado',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ] else ...[
            const Text(
              'Sin certificado generado. El servidor usará HTTP plano.',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ],
      ],
    );
  }
}

class _CuentaRegresivaDialog extends StatefulWidget {
  const _CuentaRegresivaDialog();
  @override
  State<_CuentaRegresivaDialog> createState() => _CuentaRegresivaDialogState();
}

class _CuentaRegresivaDialogState extends State<_CuentaRegresivaDialog> {
  int _segundos = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _segundos--);
      if (_segundos <= 0) {
        t.cancel();
        _cerrarAplicacion();
      }
    });
  }

  Future<void> _cerrarAplicacion() async {
    await app_main.cerrarAplicacion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cerrando aplicación'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSizes.lg),
          Text(
            'La aplicación se cerrará en $_segundos segundos.\n\n'
            '⚠️ Deberás abrirla manualmente de nuevo desde el Dock '
            '(o Launchpad / menú de inicio) para aplicar el certificado TLS.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
