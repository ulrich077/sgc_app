import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/citas_repository.dart';
import '../domain/cita_estado.dart';

class CitasQuery {
  final int page;
  final int pageSize;
  final CitaEstado? estado;
  final String search;
  final String sortColumn;
  final bool ascending;

  const CitasQuery({
    this.page = 0,
    this.pageSize = 20,
    this.estado,
    this.search = '',
    this.sortColumn = 'fecha',
    this.ascending = false,
  });

  CitasQuery copyWith({
    int? page,
    int? pageSize,
    CitaEstado? estado,
    bool clearEstado = false,
    String? search,
    String? sortColumn,
    bool? ascending,
  }) {
    return CitasQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      estado: clearEstado ? null : (estado ?? this.estado),
      search: search ?? this.search,
      sortColumn: sortColumn ?? this.sortColumn,
      ascending: ascending ?? this.ascending,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CitasQuery &&
          page == other.page &&
          pageSize == other.pageSize &&
          estado == other.estado &&
          search == other.search &&
          sortColumn == other.sortColumn &&
          ascending == other.ascending;

  @override
  int get hashCode =>
      Object.hash(page, pageSize, estado, search, sortColumn, ascending);
}

final citasPageProvider =
    StreamProvider.family<CitasPage, CitasQuery>((ref, query) {
  final repo = ref.watch(citasRepositoryProvider);
  return repo.watchPage(
    page: query.page,
    pageSize: query.pageSize,
    estadoFiltro: query.estado,
    search: query.search,
    sortColumn: query.sortColumn,
    ascending: query.ascending,
  );
});
