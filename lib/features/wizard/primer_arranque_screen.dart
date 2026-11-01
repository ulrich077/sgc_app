import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/providers/database_provider.dart';
import '../../data/database/app_database.dart';

class PrimerArranqueScreen extends ConsumerStatefulWidget {
  const PrimerArranqueScreen({super.key});

  @override
  ConsumerState<PrimerArranqueScreen> createState() =>
      _PrimerArranqueScreenState();
}

class _PrimerArranqueScreenState extends ConsumerState<PrimerArranqueScreen> {
  bool? _esServidor;
  final _ipCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_esServidor == null) return;
    if (_esServidor == false && _ipCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    await _upsert(db, 'es_servidor', _esServidor! ? 'true' : 'false');
    await _upsert(db, 'servidor_ip', _esServidor! ? '' : _ipCtrl.text.trim());
    await _upsert(db, 'wizard_completado', 'true');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _WizardDoneScreen()),
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
      await (db.update(db.configuracion)
            ..where((t) => t.clave.equals(clave)))
          .write(ConfiguracionCompanion(valor: Value(valor)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            margin: const EdgeInsets.all(AppSizes.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.settings_suggest,
                      size: 56, color: AppColors.primary),
                  const SizedBox(height: AppSizes.md),
                  Text('Configuración inicial',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'Elige cómo funcionará este equipo dentro del sistema.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _RolTile(
                    titulo: 'Servidor',
                    subtitulo: 'Este equipo almacena la base de datos central '
                        'y los archivos. Los demás se conectan a él.',
                    icon: Icons.dns,
                    selected: _esServidor == true,
                    onTap: () => setState(() => _esServidor = true),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _RolTile(
                    titulo: 'Cliente',
                    subtitulo: 'Este equipo se conecta al servidor. '
                        'Requiere la IP del servidor en la red local.',
                    icon: Icons.computer,
                    selected: _esServidor == false,
                    onTap: () => setState(() => _esServidor = false),
                  ),
                  if (_esServidor == false) ...[
                    const SizedBox(height: AppSizes.lg),
                    TextField(
                      controller: _ipCtrl,
                      decoration: const InputDecoration(
                        labelText: 'IP del servidor',
                        hintText: '192.168.1.10',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lan),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.xl),
                  FilledButton.icon(
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Continuar'),
                    onPressed:
                        (_esServidor == null || _saving) ? null : _guardar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RolTile extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RolTile({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.md),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitulo,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.radio_button_checked,
                  color: AppColors.primary)
            else
              const Icon(Icons.radio_button_unchecked,
                  color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _WizardDoneScreen extends StatelessWidget {
  const _WizardDoneScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                size: 64, color: AppColors.success),
            const SizedBox(height: AppSizes.md),
            Text('Configuración guardada',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSizes.sm),
            const Text('Reinicia la aplicación para continuar.'),
          ],
        ),
      ),
    );
  }
}
