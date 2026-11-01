import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' hide colorToHex;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/theme_colors_provider.dart';
import '../../data/database/app_database.dart';
import 'package:drift/drift.dart' show Value;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes del sistema'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Colores del sistema',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSizes.md),
                  colorsAsync.when(
                    loading: () => const Center(
                        child: Padding(
                      padding: EdgeInsets.all(AppSizes.lg),
                      child: CircularProgressIndicator(),
                    )),
                    error: (e, _) => Text('Error: $e'),
                    data: (colors) => _ColorPanel(colors: colors),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: current,
            onColorChanged: (c) => temp = c,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ColorSwatch(
              label: 'Primary',
              color: _primary,
              onTap: () => _pick(_primary, (c) {
                setState(() => _primary = c);
              }, 'Color primario'),
            ),
            const SizedBox(width: AppSizes.lg),
            _ColorSwatch(
              label: 'Secondary',
              color: _secondary,
              onTap: () => _pick(_secondary, (c) {
                setState(() => _secondary = c);
              }, 'Color secundario'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar colores'),
                onPressed: _save,
              ),
            ),
            const SizedBox(width: AppSizes.md),
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
                Text(label,
                    style: Theme.of(context).textTheme.labelSmall),
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
