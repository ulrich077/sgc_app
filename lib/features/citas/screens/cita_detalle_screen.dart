import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/database/app_database.dart';
import '../domain/cita_estado.dart';
import '../widgets/acciones_tab.dart';
import '../widgets/documentos_tab.dart';

final citaPorIdProvider = StreamProvider.family<Cita?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.citas)..where((t) => t.id.equals(id)))
      .watchSingleOrNull();
});

class CitaDetalleScreen extends ConsumerWidget {
  final int citaId;
  const CitaDetalleScreen({super.key, required this.citaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citaAsync = ref.watch(citaPorIdProvider(citaId));
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return citaAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Cita')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (cita) {
        if (cita == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cita')),
            body: const Center(child: Text('Cita no encontrada')),
          );
        }
        final estado = CitaEstado.fromDb(cita.estado);

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(cita.personaNombre),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.info_outline), text: 'Datos'),
                  Tab(icon: Icon(Icons.folder_outlined), text: 'Documentos'),
                  Tab(icon: Icon(Icons.checklist), text: 'Acciones'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _DatosTab(cita: cita, estado: estado, dateFmt: dateFmt),
                DocumentosTab(citaId: cita.id),
                AccionesTab(cita: cita),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DatosTab extends StatelessWidget {
  final Cita cita;
  final CitaEstado estado;
  final DateFormat dateFmt;

  const _DatosTab({
    required this.cita,
    required this.estado,
    required this.dateFmt,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppPageHeader(
          title: cita.personaNombre,
          subtitle: 'Estado: ${estado.label}',
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field('Nombre', cita.personaNombre),
                  _field('DPI', cita.personaDpi ?? '—'),
                  _field('Correo', cita.personaCorreo),
                  _field('Teléfono', cita.personaTelefono ?? '—'),
                  _field(
                    'Fecha de firma',
                    dateFmt.format(DateTime.fromMillisecondsSinceEpoch(
                        cita.fechaHoraFirma)),
                  ),
                  _field(
                    'Post Mortem presentado',
                    cita.postMortemPresentado ? 'Sí' : 'No',
                  ),
                  _field(
                    'Contraloría presentada',
                    cita.contraloriaPresentada ? 'Sí' : 'No',
                  ),
                  if (cita.notas != null && cita.notas!.isNotEmpty)
                    _field('Notas', cita.notas!),
                  if (cita.reagendadaVeces > 0)
                    _field('Reagendada', '${cita.reagendadaVeces} veces'),
                  if (cita.motivoUltimaReagenda != null)
                    _field('Motivo última reagenda',
                        cita.motivoUltimaReagenda!),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.xl),
      ],
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
