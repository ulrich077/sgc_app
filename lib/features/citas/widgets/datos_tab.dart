import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/dialogs.dart';
import '../../../data/database/app_database.dart';
import '../data/citas_repository.dart';

class DatosTab extends ConsumerStatefulWidget {
  final Cita cita;
  final dynamic estado;

  const DatosTab({super.key, required this.cita, required this.estado});

  @override
  ConsumerState<DatosTab> createState() => _DatosTabState();
}

class _DatosTabState extends ConsumerState<DatosTab> {
  bool _loadingReenvio = false;

  Future<void> _editarCorreo() async {
    final ctrl = TextEditingController(text: widget.cita.personaCorreo);
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Correo Electrónico'),
              content: TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: 'Nuevo correo',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() => saving = true);
                          try {
                            final auth = ref.read(authProvider);
                            final repo = CitasRepository(ref.read(databaseProvider));
                            await repo.actualizarCorreo(widget.cita.id, ctrl.text.trim(), auth.userId ?? 1);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) AppDialogs.success(context, 'Correo actualizado correctamente.');
                          } catch (e) {
                            if (ctx.mounted) AppDialogs.error(ctx, 'Error: $e');
                            if (ctx.mounted) setState(() => saving = false);
                          }
                        },
                  child: saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _reenviarCorreo() async {
    setState(() => _loadingReenvio = true);
    try {
      final repo = CitasRepository(ref.read(databaseProvider));
      await repo.reenviarCorreoPrueba(widget.cita.id);
      if (mounted) AppDialogs.success(context, 'Correo de prueba encolado para reenvío.');
    } catch (e) {
      if (mounted) AppDialogs.error(context, 'Error al reenviar: $e');
    } finally {
      if (mounted) setState(() => _loadingReenvio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final fecha = DateTime.fromMillisecondsSinceEpoch(widget.cita.fechaHoraFirma * 1000);

    return Container(
      color: const Color(0xFFF4F7F9), // Fondo gris suave para unificar con Acciones
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PremiumCard(
                  title: 'Información Personal',
                  icon: Icons.person_outline,
                  children: [
                    _InfoRow(label: 'Nombre Completo', value: widget.cita.personaNombre),
                    _InfoRow(label: 'Documento (DPI)', value: widget.cita.personaDpi ?? '—'),
                    _InfoRow(label: 'Teléfono', value: widget.cita.personaTelefono ?? '—'),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                _PremiumCard(
                  title: 'Contacto y Cita',
                  icon: Icons.event_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _InfoRow(label: 'Correo Electrónico', value: widget.cita.personaCorreo)),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Editar'),
                          onPressed: _editarCorreo,
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: _loadingReenvio
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.send, size: 16),
                          label: Text(_loadingReenvio ? 'Enviando' : 'Reenviar'),
                          onPressed: _loadingReenvio ? null : _reenviarCorreo,
                        ),
                      ],
                    ),
                    _InfoRow(label: 'Fecha y Hora de Firma', value: dateFmt.format(fecha)),
                    _InfoRow(label: 'Estado Actual', value: widget.estado.label),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                if (widget.cita.notas != null && widget.cita.notas!.isNotEmpty)
                  _PremiumCard(
                    title: 'Notas Adicionales',
                    icon: Icons.notes,
                    children: [
                      Text(widget.cita.notas!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TARJETA PREMIUM UNIFICADA
class _PremiumCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _PremiumCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFEEEEEE)),
          ...children,
        ],
      ),
    );
  }
}

// FILA DE INFORMACIÓN
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
