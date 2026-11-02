import 'dart:async';
import 'package:drift/drift.dart' hide Column;
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
  bool _enviado = false;
  StreamSubscription? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

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
    setState(() {
      _loadingReenvio = true;
      _enviado = false;
    });

    try {
      final db = ref.read(databaseProvider);
      final repo = CitasRepository(db);
      
      // 1. Encolamos el correo
      await repo.reenviarCorreoPrueba(widget.cita.id);

      // 2. Nos ponemos a escuchar la DB hasta que el worker lo envíe
      _sub?.cancel();
      _sub = (db.select(db.correosLog)
            ..where((t) => t.citaId.equals(widget.cita.id) & t.tipo.equals('prueba'))
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(1))
          .watchSingleOrNull()
          .listen((correo) {
        if (correo != null && correo.estado == 'enviado') {
          if (mounted) {
            setState(() {
              _loadingReenvio = false;
              _enviado = true;
            });
            AppDialogs.success(context, '¡Correo enviado exitosamente!');
            
            // Regresar el botón a la normalidad después de 3 segundos
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _enviado = false);
            });
          }
        }
      });

      // Cancelar la escucha después de 2 minutos para no dejar hilos abiertos
      Future.delayed(const Duration(minutes: 2), () {
        _sub?.cancel();
        if (mounted && _loadingReenvio) setState(() => _loadingReenvio = false);
      });

    } catch (e) {
      if (mounted) {
        setState(() => _loadingReenvio = false);
        AppDialogs.error(context, 'Error al reenviar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    // REGLA VI: La DB guarda segundos, multiplicamos por 1000.
    final fecha = DateTime.fromMillisecondsSinceEpoch(widget.cita.fechaHoraFirma * 1000);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            title: 'Información Personal',
            icon: Icons.person_outline,
            children: [
              _InfoRow(label: 'Nombre', value: widget.cita.personaNombre),
              _InfoRow(label: 'DPI', value: widget.cita.personaDpi ?? '—'),
              _InfoRow(label: 'Teléfono', value: widget.cita.personaTelefono ?? '—'),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          _InfoCard(
            title: 'Contacto y Cita',
            icon: Icons.event_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InfoRow(label: 'Correo Electrónico', value: widget.cita.personaCorreo),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    onPressed: _editarCorreo,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: _loadingReenvio
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : _enviado
                            ? const Icon(Icons.check_circle, size: 16, color: Colors.green)
                            : const Icon(Icons.send, size: 16),
                    label: Text(
                      _loadingReenvio ? 'Enviando...' : _enviado ? '¡Enviado!' : 'Reenviar',
                      style: TextStyle(color: _enviado ? Colors.green : null),
                    ),
                    onPressed: (_loadingReenvio || _enviado) ? null : _reenviarCorreo,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                      side: _enviado ? const BorderSide(color: Colors.green) : null,
                    ),
                  ),
                ],
              ),
              _InfoRow(label: 'Fecha y Hora de Firma', value: dateFmt.format(fecha)),
              _InfoRow(label: 'Estado Actual', value: widget.estado.label),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          if (widget.cita.notas != null && widget.cita.notas!.isNotEmpty)
            _InfoCard(
              title: 'Notas Adicionales',
              icon: Icons.notes,
              children: [
                Text(widget.cita.notas!, style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.lg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: AppSizes.xl),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
