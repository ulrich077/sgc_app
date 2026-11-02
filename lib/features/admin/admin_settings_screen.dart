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
import '../../core/widgets/app_dialog_shell.dart';
import '../../core/widgets/app_page_header.dart';
import '../../core/widgets/responsive.dart';
import '../../data/database/app_database.dart';
import '../documentos/services/placeholder_resolver.dart';
import 'correos_tab.dart';
import 'smtp_config_tab.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ajustes')),
        body: const Center(child: Text(AppStrings.noPermission)),
      );
    }

    final colorsAsync = ref.watch(themeColorsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ajustes del sistema'),
          actions: [
            // BOTÓN TEMPORAL PARA PROBAR NAVEGACIÓN
            IconButton(
              tooltip: 'Ir al Dashboard',
              icon: const Icon(Icons.dashboard, color: AppColors.primary),
              onPressed: () => context.go('/dashboard'),
            ),
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authProvider.notifier).logout(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.tune), text: 'General'),
              Tab(icon: Icon(Icons.dns_outlined), text: 'SMTP'),
              Tab(icon: Icon(Icons.email_outlined), text: 'Correos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                const AppPageHeader(
                  title: 'Ajustes',
                  subtitle: 'Configuración global del sistema',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pagePadding),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Colores del sistema',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSizes.md),
                          colorsAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.all(AppSizes.lg),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (e, _) => Text('Error: $e'),
                            data: (colors) => _ColorPanel(colors: colors),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pagePadding),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Plantillas de correo',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSizes.sm),
                          const Text(
                            PlaceholderResolver.ayudaPlaceholders,
                            style: TextStyle(fontSize: 11),
                          ),
                          const SizedBox(height: AppSizes.md),
                          _PlantillaEditor(
                            clave: 'plantilla_prueba',
                            titulo: 'Correo de prueba',
                          ),
                          _PlantillaEditor(
                            clave: 'plantilla_confirmacion',
                            titulo: 'Confirmación',
                          ),
                          _PlantillaEditor(
                            clave: 'plantilla_reagenda',
                            titulo: 'Reagenda',
                          ),
                          _PlantillaEditor(
                            clave: 'plantilla_final',
                            titulo: 'Correo final',
                          ),
                          _PlantillaEditor(
                            clave: 'plantilla_recordatorio',
                            titulo: 'Recordatorio',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
            const SmtpConfigTab(),
            const CorreosTab(),
          ],
        ),
      ),
    );
  }
}

class _ColorPanel extends ConsumerStatefulWidget {
  final ThemeColors colors;
  const _ColorPanel({required this.colors});

  @override
  ConsumerState<_ColorPanel> createState() => _ColorPanelState();
}

class _ColorPanelState extends ConsumerState<_ColorPanel> {
  late Color _primary;
  late Color _secondary;

  @override
  void initState() {
    super.initState();
    _primary = widget.colors.primary;
    _secondary = widget.colors.secondary;
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    await _upsert(db, 'color_primary', colorToHex(_primary));
    await _upsert(db, 'color_secondary', colorToHex(_secondary));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Colores guardados')),
    );
  }

  Future<void> _upsert(AppDatabase db, String clave, String valor) async {
    final existing = await (db.select(db.configuracion)
          ..where((t) => t.clave.equals(clave)))
        .getSingleOrNull();
    if (existing == null) {
      await db.into(db.configuracion).insert(ConfiguracionCompanion.insert(
            clave: clave,
            valor: Value(valor),
            tipo: const Value('string'),
          ));
    } else {
      await (db.update(db.configuracion)..where((t) => t.clave.equals(clave)))
          .write(ConfiguracionCompanion(valor: Value(valor)));
    }
  }

  Future<void> _pick(Color current, ValueChanged<Color> onPicked,
      String title) async {
    Color temp = current;
    await showDialog<void>(
      context: context,
      builder: (_) => AppDialogShell(
        title: title,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              onPicked(temp);
              Navigator.of(context).pop();
            },
            child: const Text('Aplicar'),
          ),
        ],
        child: cp.ColorPicker(
          pickerColor: current,
          onColorChanged: (c) => temp = c,
          enableAlpha: false,
          labelTypes: const [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final swatches = [
      _ColorSwatch(
        label: 'Primary',
        color: _primary,
        onTap: () => _pick(_primary, (c) {
          setState(() => _primary = c);
        }, 'Color primario'),
      ),
      _ColorSwatch(
        label: 'Secondary',
        color: _secondary,
        onTap: () => _pick(_secondary, (c) {
          setState(() => _secondary = c);
        }, 'Color secundario'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              swatches[0],
              const SizedBox(height: AppSizes.md),
              swatches[1],
            ],
          )
        else
          Row(
            children: [
              swatches[0],
              const SizedBox(width: AppSizes.lg),
              swatches[1],
            ],
          ),
        const SizedBox(height: AppSizes.lg),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar colores'),
              onPressed: _save,
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.restore),
              label: const Text('Restablecer'),
              onPressed: () => setState(() {
                _primary = ThemeColors.defaults.primary;
                _secondary = ThemeColors.defaults.secondary;
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ColorSwatch(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSizes.xs),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(colorToHex(color),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
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
  bool _cargado = false;
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    if (_cargado) return;
    final db = ref.read(databaseProvider);
    final row = await (db.select(db.configuracion)
          ..where((t) => t.clave.equals(widget.clave)))
        .getSingleOrNull();
    if (!mounted) return;
    setState(() {
      _ctrl.text = row?.valor ?? '';
      _cargado = true;
    });
  }

  Future<void> _guardar() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final existing = await (db.select(db.configuracion)
          ..where((t) => t.clave.equals(widget.clave)))
        .getSingleOrNull();
    if (existing == null) {
      await db.into(db.configuracion).insert(ConfiguracionCompanion.insert(
            clave: widget.clave,
            valor: Value(_ctrl.text),
            tipo: const Value('string'),
          ));
    } else {
      await (db.update(db.configuracion)
            ..where((t) => t.clave.equals(widget.clave)))
          .write(ConfiguracionCompanion(valor: Value(_ctrl.text)));
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plantilla guardada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    _cargar();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.titulo,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.sm),
          TextField(
            controller: _ctrl,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Escribe el cuerpo HTML de la plantilla...',
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save, size: 18),
              label: const Text('Guardar'),
              onPressed: _saving ? null : _guardar,
            ),
          ),
        ],
      ),
    );
  }
}
