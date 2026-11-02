import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
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
import '../../data/database/app_database.dart';
import 'correos_tab.dart';
import 'smtp_config_tab.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  int _selectedIndex = 0;

  // Lista de opciones del menú lateral de ajustes
  final List<Map<String, dynamic>> _menu = [
    {'title': 'Apariencia', 'icon': Icons.palette_outlined, 'type': 'colors'},
    {'title': 'Correo de Prueba', 'icon': Icons.mark_email_unread_outlined, 'type': 'template', 'clave': 'plantilla_prueba'},
    {'title': 'Correo de Reagenda', 'icon': Icons.calendar_today_outlined, 'type': 'template', 'clave': 'plantilla_reagenda'},
    {'title': 'Correo Final', 'icon': Icons.attachment_outlined, 'type': 'template', 'clave': 'plantilla_final'},
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajustes del sistema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              '${auth.nombreCompleto ?? ''} (${auth.rolNombre ?? ''})',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Ir al Dashboard',
            icon: const Icon(Icons.dashboard_outlined, color: AppColors.primary),
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
            // MENÚ LATERAL (Maestro)
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
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: ListTile(
                          leading: Icon(
                            item['icon'],
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            size: 20,
                          ),
                          title: Text(
                            item['title'],
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onTap: () => setState(() => _selectedIndex = index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSizes.xl),

            // ÁREA DE CONTENIDO (Detalle)
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
    if (item['type'] == 'template') return _PlantillaEditor(clave: item['clave'], titulo: item['title']);
    if (item['type'] == 'smtp') return const SmtpConfigTab(); // Tu widget existente
    if (item['type'] == 'queue') return const CorreosTab(); // Tu widget existente
    return const SizedBox();
  }
}

// --- PANEL DE COLORES ---
class _ColorPanelWrapper extends ConsumerStatefulWidget {
  const _ColorPanelWrapper();
  @override
  ConsumerState<_ColorPanelWrapper> createState() => _ColorPanelWrapperState();
}

class _ColorPanelWrapperState extends ConsumerState<_ColorPanelWrapper> {
  late Color _primary;
  late Color _secondary;
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    final colors = ref.read(themeColorsProvider).maybeWhen(data: (c) => c, orElse: () => ThemeColors.defaults);
    setState(() {
      _primary = colors.primary;
      _secondary = colors.secondary;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    await _upsert(db, 'color_primary', colorToHex(_primary));
    await _upsert(db, 'color_secondary', colorToHex(_secondary));
    ref.invalidate(themeColorsProvider);
    if (!mounted) return;
    setState(() => _saving = false);
    await AppDialogs.success(context, 'Colores guardados y aplicados');
  }

  Future<void> _upsert(AppDatabase db, String clave, String valor) async {
    final existing = await (db.select(db.configuracion)..where((t) => t.clave.equals(clave))).getSingleOrNull();
    if (existing == null) {
      await db.into(db.configuracion).insert(ConfiguracionCompanion.insert(clave: clave, valor: Value(valor), tipo: const Value('string')));
    } else {
      await (db.update(db.configuracion)..where((t) => t.clave.equals(clave))).write(ConfiguracionCompanion(valor: Value(valor)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Personaliza los colores principales de la aplicación.', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: AppSizes.xl),
        Row(
          children: [
            _ColorSwatch(label: 'Color Primario', color: _primary, onTap: () => _pickColor(true)),
            const SizedBox(width: AppSizes.xl),
            _ColorSwatch(label: 'Color Secundario', color: _secondary, onTap: () => _pickColor(false)),
          ],
        ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _saving ? null : _save,
            icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
            label: const Text('Guardar Apariencia'),
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
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              setState(() {
                if (isPrimary) { _primary = temp; }
                else { _secondary = temp; }
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
  const _ColorSwatch({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Center(child: Icon(Icons.edit, color: Colors.white, size: 20)),
          ),
        ),
      ],
    );
  }
}

// --- EDITOR DE PLANTILLAS ---
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
    final row = await (db.select(db.configuracion)..where((t) => t.clave.equals(widget.clave))).getSingleOrNull();
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
    final existing = await (db.select(db.configuracion)..where((t) => t.clave.equals(widget.clave))).getSingleOrNull();
    if (existing == null) {
      await db.into(db.configuracion).insert(ConfiguracionCompanion.insert(clave: widget.clave, valor: Value(_ctrl.text), tipo: const Value('string')));
    } else {
      await (db.update(db.configuracion)..where((t) => t.clave.equals(widget.clave))).write(ConfiguracionCompanion(valor: Value(_ctrl.text)));
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Row(
              children: [
                Text('Modo HTML', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Switch(
                  value: _isHtml,
                  onChanged: (v) => setState(() => _isHtml = v),
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.md),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: _saving ? null : _save,
                  icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save, size: 16),
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
