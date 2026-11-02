import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_page_header.dart';
import '../data/citas_repository.dart';
import '../domain/cita_estado.dart';
import '../providers/citas_page_provider.dart';
import '../widgets/nueva_cita_dialog.dart';
import '../widgets/cita_detalle_modal.dart';

class CitasScreen extends ConsumerStatefulWidget {
  const CitasScreen({super.key});

  @override
  ConsumerState<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends ConsumerState<CitasScreen> {
  CitasQuery _query = const CitasQuery();
  final _searchCtrl = TextEditingController();
  int? _sortColumnIndex;
  bool _sortAscending = false;

  static const _sortKeys = ['nombre', 'fecha', 'estado', 'creada'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _query = _query.copyWith(
        sortColumn: _sortKeys[columnIndex],
        ascending: ascending,
        page: 0,
      );
    });
  }

  void _onSearch(String value) {
    setState(() => _query = _query.copyWith(search: value, page: 0));
  }

  void _onFiltroEstado(CitaEstado? estado) {
    setState(() {
      _query = _query.copyWith(
        estado: estado,
        clearEstado: estado == null,
        page: 0,
      );
    });
  }

  void _cambiarPagina(int delta) {
    final next = _query.page + delta;
    if (next < 0) return;
    setState(() => _query = _query.copyWith(page: next));
  }

  Future<void> _abrirNuevaCita() async {
    final creada = await showDialog<bool>(
      context: context,
      builder: (_) => const NuevaCitaDialog(),
    );
    if (creada == true && mounted) {
      setState(() => _query = _query.copyWith(page: 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final pageAsync = ref.watch(citasPageProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: 'Gestión de Citas',
            subtitle: 'Administra las citas de firma del sistema',
            actions: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg, vertical: AppSizes.md),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Nueva cita'),
                onPressed: auth.isAuthenticated ? _abrirNuevaCita : null,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.md),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<CitaEstado?>(
                    initialValue: _query.estado,
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.md),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    ),
                    items: [
                      const DropdownMenuItem<CitaEstado?>(value: null, child: Text('Todos')),
                      ...CitaEstado.values.map((e) => DropdownMenuItem<CitaEstado?>(
                        value: e,
                        child: Row(children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: e.color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(e.label),
                        ]),
                      )),
                    ],
                    onChanged: _onFiltroEstado,
                  ),
                ),
                const SizedBox(width: AppSizes.lg),
                pageAsync.maybeWhen(
                  data: (page) => _PaginacionBar(
                    page: page,
                    query: _query,
                    onPrev: () => _cambiarPagina(-1),
                    onNext: () => _cambiarPagina(1),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Expanded(
            child: pageAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (page) => _CitasTable(
                page: page,
                query: _query,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                onSort: _onSort,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }
}

class _CitasTable extends StatelessWidget {
  final CitasPage page;
  final CitasQuery query;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int, bool) onSort;

  const _CitasTable({
    required this.page,
    required this.query,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      child: Container(
        width: double.infinity, // 100% width
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.md),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth = constraints.maxWidth;

            return ConstrainedBox(
              constraints: BoxConstraints(minWidth: tableWidth, maxHeight: 600),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: sortAscending,
                    showCheckboxColumn: false,
                    headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.05)),
                    dataRowColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return AppColors.primary.withValues(alpha: 0.02);
                      }
                      return Colors.transparent;
                    }),
                    columns: [
                      DataColumn(label: const Text('Nombre'), onSort: (columnIndex, ascending) => onSort(0, !sortAscending)),
                      const DataColumn(label: Text('DPI')),
                      const DataColumn(label: Text('Correo')),
                      const DataColumn(label: Text('Teléfono')),
                      DataColumn(label: const Text('Fecha firma'), onSort: (columnIndex, ascending) => onSort(1, !sortAscending)),
                      DataColumn(label: const Text('Estado'), onSort: (columnIndex, ascending) => onSort(2, !sortAscending)),
                      DataColumn(label: const Text('Creada'), onSort: (columnIndex, ascending) => onSort(3, !sortAscending)),
                    ],
                    rows: page.rows.map((cita) {
                      final estado = CitaEstado.fromDb(cita.estado);
                      return DataRow(
                        onSelectChanged: (_) => CitaDetalleModal.show(context, cita.id),
                        cells: [
                          DataCell(Text(cita.personaNombre, style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(Text(cita.personaDpi ?? '—')),
                          DataCell(Text(cita.personaCorreo)),
                          DataCell(Text(cita.personaTelefono ?? '—')),
                          DataCell(Text(dateFmt.format(DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma)))),
                          DataCell(_EstadoBadge(estado: estado)),
                          DataCell(Text(cita.dateCreation == null ? '—' : dateFmt.format(DateTime.fromMillisecondsSinceEpoch(cita.dateCreation!)))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaginacionBar extends StatelessWidget {
  final CitasPage page;
  final CitasQuery query;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PaginacionBar({
    required this.page,
    required this.query,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (page.totalFiltered / query.pageSize).ceil();
    final currentPage = query.page + 1;
    final canPrev = query.page > 0;
    final canNext = query.page + 1 < totalPages;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Pág. $currentPage de ${totalPages == 0 ? 1 : totalPages}',
          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        IconButton(
          onPressed: canPrev ? onPrev : null,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Anterior',
        ),
        IconButton(
          onPressed: canNext ? onNext : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Siguiente',
        ),
      ],
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final CitaEstado estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: estado.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.sm),
        border: Border.all(color: estado.color.withValues(alpha: 0.5)),
      ),
      child: Text(
        estado.label,
        style: TextStyle(color: estado.color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
