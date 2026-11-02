import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/dialogs.dart';
import '../../data/database/app_database.dart';

class SmtpConfigTab extends ConsumerStatefulWidget {
  const SmtpConfigTab({super.key});

  @override
  ConsumerState<SmtpConfigTab> createState() => _SmtpConfigTabState();
}

class _SmtpConfigTabState extends ConsumerState<SmtpConfigTab> {
  final _hostCtrl = TextEditingController();
  final _portCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _ccCtrl = TextEditingController();

  bool _cargado = false;
  bool _saving = false;

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _fromCtrl.dispose();
    _ccCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    if (_cargado) return;
    final db = ref.read(databaseProvider);
    final rows = await db.select(db.configuracion).get();
    final map = {for (final r in rows) r.clave: r.valor};
    if (!mounted) return;
    setState(() {
      _hostCtrl.text = map['smtp_host'] ?? '';
      _portCtrl.text = map['smtp_port'] ?? '587';
      _userCtrl.text = map['smtp_user'] ?? '';
      _passCtrl.text = map['smtp_password'] ?? '';
      _fromCtrl.text = map['correo_remitente'] ?? '';
      _ccCtrl.text = map['correo_cc_final'] ?? '';
      _cargado = true;
    });
  }

  Future<void> _guardar() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    try {
      await _upsert(db, 'smtp_host', _hostCtrl.text.trim());
      await _upsert(db, 'smtp_port', _portCtrl.text.trim());
      await _upsert(db, 'smtp_user', _userCtrl.text.trim());
      await _upsert(db, 'smtp_password', _passCtrl.text.trim());
      await _upsert(db, 'correo_remitente', _fromCtrl.text.trim());
      await _upsert(db, 'correo_cc_final', _ccCtrl.text.trim());
      if (!mounted) return;
      await AppDialogs.success(context, 'Configuración SMTP guardada.');
    } catch (e) {
      if (!mounted) return;
      await AppDialogs.error(context, 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _upsert(AppDatabase db, String clave, String valor) async {
    final existing = await (db.select(db.configuracion)..where((t) => t.clave.equals(clave))).getSingleOrNull();
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

  @override
  Widget build(BuildContext context) {
    _cargar();

    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        const Text('Configuración del Servidor de Correo (SMTP)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.sm),
        const Text('Los correos se envían desde este servidor. Si usas Gmail, usa una "Contraseña de Aplicación" en lugar de tu contraseña normal.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(controller: _hostCtrl, decoration: const InputDecoration(labelText: 'Servidor SMTP (ej. smtp.gmail.com)', border: OutlineInputBorder())),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              flex: 1,
              child: TextField(controller: _portCtrl, decoration: const InputDecoration(labelText: 'Puerto (ej. 587)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Usuario / Correo', border: OutlineInputBorder())),
        const SizedBox(height: AppSizes.md),
        TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña o Contraseña de Aplicación', border: OutlineInputBorder())),
        const SizedBox(height: AppSizes.md),
        TextField(controller: _fromCtrl, decoration: const InputDecoration(labelText: 'Correo Remitente (de dónde sale el correo)', border: OutlineInputBorder())),
        const SizedBox(height: AppSizes.md),
        TextField(controller: _ccCtrl, decoration: const InputDecoration(labelText: 'CC Final (ej. oceballos@congreso.gob.gt)', border: OutlineInputBorder())),
        const SizedBox(height: AppSizes.xl),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.lg)),
            icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
            label: const Text('Guardar Configuración'),
            onPressed: _saving ? null : _guardar,
          ),
        ),
      ],
    );
  }
}
