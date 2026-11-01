import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/responsive.dart';
import '../../../data/database/app_database.dart';
import '../data/citas_repository.dart';
import '../domain/cita_estado.dart';
import '../providers/citas_page_provider.dart';
import '../widgets/nueva_cita_dialog.dart';

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
    setState(() {
      _query = _query.copyWith(search: value, page: 0);
    });
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
      appBar: AppBar(title: const Text('Citas')),
      body: ListView(
        children: [
          AppPageHeader(
            title: 'Citas',
            subtitle: 'Gestión de citas de firma',
            actions: [
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Nueva cita'),
                onPressed: auth.isAuthenticated ? _abrirNuevaCita : null,
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            child: _FiltrosBar(
              searchCtrl: _searchCtrl,
              onSearch: _onSearch,
              estado: _query.estado,
              onEstado: _onFiltroEstado,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          pageAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSizes.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Center(child: Text('Error: $e')),
            ),
            data: (page) => _CitasTable(
              page: page,
              query: _query,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              onSort: _onSort,
              onPrev: () => _cambiarPagina(-1),
              onNext: () => _cambiarPagina(1),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _FiltrosBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final CitaEstado? estado;
  final ValueChanged<CitaEstado?> onEstado;

  const _FiltrosBar({
    required this.searchCtrl,
    required this.onSearch,
    required this.estado,
    required this.onEstado,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final search = TextField(
      controller: searchCtrl,
      onChanged: onSearch,
      decoration: const InputDecoration(
        labelText: 'Buscar (nombre, DPI, correo, teléfono)',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
    final filtro = DropdownButtonFormField<CitaEstado?>(
      initialValue: estado,
      decoration: const InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<CitaEstado?>(
          value: null,
          child: Text('Todos'),
        ),
        ...CitaEstado.values.map(
          (e) => DropdownMenuItem<CitaEstado?>(
            value: e,
            child: Text(e.label),
          ),
        ),
      ],
      onChanged: onEstado,
    );

    if (isMobile) {
      return Column(
        children: [
          search,
          const SizedBox(height: AppSizes.sm),
          filtro,
        ],
      );
    }
    return Row(
      children: [
        Expanded(flex: 2, child: search),
        const SizedBox(width: AppSizes.md),
        Expanded(child: filtro),
      ],
    );
  }
}

class _CitasTable extends StatelessWidget {
  final CitasPage page;
  final CitasQuery query;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int, bool) onSort;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _CitasTable({
    required this.page,
    required this.query,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    final columns = [
      DataColumn(
        label: const Text('Nombre'),
        onSort: onSort,
        columnWidth: const FixedColumnWidth(200),
      ),
      const DataColumn(label: Text('DPI'), columnWidth: FixedColumnWidth(120)),
      const DataColumn(
          label: Text('Correo'), columnWidth: FixedColumnWidth(200)),
      const DataColumn(
          label: Text('Teléfono'), columnWidth: FixedColumnWidth(120)),
      DataColumn(
        label: const Text('Fecha firma'),
        onSort: onSort,
        columnWidth: const FixedColumnWidth(150),
      ),
      DataColumn(
        label: const Text('Estado'),
        onSort: onSort,
        columnWidth: const FixedColumnWidth(160),
      ),
      DataColumn(
        label: const Text('Creada'),
        onSort: onSort,
        columnWidth: const FixedColumnWidth(150),
      ),
    ];

    final rows = page.rows.map((cita) {
      final estado = CitaEstado.fromDb(cita.estado);
      return DataRow(
        onSelectChanged: (_) => _abrirDetalle(context, cita),
        cells: [
          DataCell(Text(cita.personaNombre)),
          DataCell(Text(cita.personaDpi ?? '—')),
          DataCell(Text(cita.personaCorreo)),
          DataCell(Text(cita.personaTelefono ?? '—')),
          DataCell(Text(
              dateFmt.format(DateTime.fromMillisecondsSinceEpoch(
                  cita.fechaHoraFirma)))),
          DataCell(_EstadoBadge(estado: estado)),
          DataCell(Text(cita.dateCreation == null
              ? '—'
              : dateFmt.format(
                  DateTime.fromMillisecondsSinceEpoch(cita.dateCreation!)))),
        ],
      );
    }).toList();

    final totalPages = (page.totalFiltered / query.pageSize).ceil();
    final currentPage = query.page + 1;
    final canPrev = query.page > 0;
    final canNext = query.page + 1 < totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.md),
              border: Border.all(color: AppColors.border),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 950),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortColumnIndex: sortColumnIndex,
                      sortAscending: sortAscending,
                      showCheckboxColumn: false,
                      columns: columns,
                      rows: rows,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mostrando ${page.rows.length} de ${page.totalFiltered} — Página $currentPage de ${totalPages == 0 ? 1 : totalPages}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Row(
                children: [
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _abrirDetalle(BuildContext context, Cita cita) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(cita.personaNombre),
        content: Text(
          'Detalle de cita — se implementa en 2.C\n\n'
          'Correo: ${cita.personaCorreo}\n'
          'Estado: ${CitaEstado.fromDb(cita.estado).label}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final CitaEstado estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm, vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: estado.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.sm),
        border: Border.all(color: estado.color),
      ),
      child: Text(
        estado.label,
        style: TextStyle(
          color: estado.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
