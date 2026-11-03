import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/mdns_discovery.dart';
import '../../core/providers/database_provider.dart';
import '../../data/database/app_database.dart';
import '../../core/utils/dialogs.dart';

class PrimerArranqueScreen extends ConsumerStatefulWidget {
  const PrimerArranqueScreen({super.key});

  @override
  ConsumerState<PrimerArranqueScreen> createState() => _PrimerArranqueScreenState();
}

class _PrimerArranqueScreenState extends ConsumerState<PrimerArranqueScreen> {
  bool? _esServidor;
  final _ipCtrl = TextEditingController();
  bool _saving = false;
  bool _buscando = false;

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  Future<void> _upsert(String clave, String valor) async {
    final db = ref.read(databaseProvider);
    final existing = await (db.select(db.configuracion)..where((t) => t.clave.equals(clave))).getSingleOrNull();
    if (existing == null) {
      await db.into(db.configuracion).insert(ConfiguracionCompanion.insert(clave: clave, valor: Value(valor)));
    } else {
      await (db.update(db.configuracion)..where((t) => t.clave.equals(clave))).write(ConfiguracionCompanion(valor: Value(valor)));
    }
  }

  Future<void> _buscarServidor() async {
    setState(() => _buscando = true);
    final ip = await MdnsDiscovery.buscarServidor();
    if (!mounted) return;
    setState(() => _buscando = false);
    if (ip != null) {
      _ipCtrl.text = ip;
      await AppDialogs.success(context, 'Servidor encontrado en: $ip');
    } else {
      await AppDialogs.error(context, 'No se encontró el servidor. Ingresa la IP manualmente.');
    }
  }

  Future<void> _guardar() async {
    if (_esServidor == null) return;
    if (_esServidor == false && _ipCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    
    await _upsert('es_servidor', _esServidor! ? 'true' : 'false');
    await _upsert('servidor_ip', _esServidor! ? '' : _ipCtrl.text.trim());
    await _upsert('wizard_completado', 'true');
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _WizardDoneScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FaIcon(FontAwesomeIcons.calendarCheck, color: AppColors.primary, size: 48),
              const SizedBox(height: 24),
              const Text('Bienvenido al SGC', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('¿Cómo se usará este equipo?', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 32),

              // Botón Servidor
              _OptionCard(
                title: 'Servidor',
                subtitle: 'Este equipo almacenará la base de datos central y enviará los correos.',
                icon: FontAwesomeIcons.server,
                isSelected: _esServidor == true,
                onTap: () => setState(() => _esServidor = true),
              ),
              const SizedBox(height: 16),

              // Botón Cliente
              _OptionCard(
                title: 'Cliente',
                subtitle: 'Este equipo se conectará a un servidor central en la red.',
                icon: FontAwesomeIcons.laptop,
                isSelected: _esServidor == false,
                onTap: () => setState(() => _esServidor = false),
              ),

              // Si es cliente, mostrar la IP
              if (_esServidor == false) ...[
                const SizedBox(height: 24),
                const Text('IP del Servidor', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _ipCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ej. 192.168.1.50',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.network_check),
                    suffixIcon: IconButton(
                      icon: _buscando
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.search),
                      onPressed: _buscando ? null : _buscarServidor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Presiona la lupa para buscar el servidor en tu red local.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],

              const SizedBox(height: 32),

              // Botón Guardar
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (_saving || _esServidor == null) ? null : _guardar,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Comenzar a usar el sistema', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final FaIconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({required this.title, required this.subtitle, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            FaIcon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppColors.primary : Colors.black)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
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
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text('¡Todo listo!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Reinicia la aplicación para aplicar los cambios.', textAlign: TextAlign.center),
            const SizedBox(height: 32),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Entendido')),
          ],
        ),
      ),
    );
  }
}
