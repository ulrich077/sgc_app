import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_config.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/sync_provider.dart';
import '../../../data/database/app_database.dart';
import '../domain/documento_tipo.dart';
import '../services/file_storage_service.dart';

class DocumentosRepository {
  final AppDatabase _db;
  final ApiClient? _api;
  final NetworkConfig? _network;
  final FileStorageService _storage; // Agregamos el servicio de guardado local

  DocumentosRepository(
    this._db, {
    ApiClient? api,
    NetworkConfig? network,
  })  : _api = api,
        _network = network,
        _storage = FileStorageService();

  bool get _esClienteRemoto =>
      _api != null && _network != null && !_network.esServidor;

  Stream<List<Documento>> watchPorCita(int citaId) {
    return (_db.select(_db.documentos)
          ..where((t) =>
              t.citaId.equals(citaId) & t.isDelete.equals(false))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.subidoAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Future<int> subirDocumento({
    required int citaId,
    required DocumentoTipo tipo,
    required File archivo,
    required int userId,
  }) async {
    final bytes = await archivo.readAsBytes();
    return subirBytes(
      citaId: citaId,
      tipo: tipo,
      bytes: bytes,
      nombreArchivo: archivo.uri.pathSegments.last,
      userId: userId,
    );
  }

  Future<int> subirBytes({
    required int citaId,
    required DocumentoTipo tipo,
    required List<int> bytes,
    required String nombreArchivo,
    required int userId,
  }) async {
    if (_esClienteRemoto) {
      final res = await _api!.subirDocumento(
        citaId: citaId,
        tipo: tipo.dbValue,
        userId: userId,
        bytes: bytes,
        nombreArchivo: nombreArchivo,
      );
      return (res['id'] as num).toInt();
    }

    // Servidor: guarda local + inserta en DB maestra.
    final stored = await _storage.guardarBytes(
      bytes: bytes,
      citaId: citaId,
      nombre: nombreArchivo,
    );
    
    return _db.into(_db.documentos).insert(DocumentosCompanion.insert(
          citaId: citaId,
          tipo: tipo.dbValue,
          nombre: stored.nombre,
          rutaArchivo: stored.rutaAbsoluta,
          hashSha256: Value(stored.hashSha256),
          mimeType: Value(stored.mimeType),
          tamanoBytes: Value(stored.tamanoBytes),
          subidoPor: userId,
          subidoAt: DateTime.now().millisecondsSinceEpoch,
        ));
  }

  Future<void> eliminar(int documentoId, int userId) async {
    await (_db.update(_db.documentos)
          ..where((t) => t.id.equals(documentoId)))
        .write(const DocumentosCompanion(
      isDelete: Value(true),
    ));
  }
}

final documentosRepositoryProvider = Provider<DocumentosRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final netAsync = ref.watch(networkConfigProvider);
  final apiAsync = ref.watch(apiClientProvider);
  final net = netAsync.maybeWhen(data: (c) => c, orElse: () => null);
  final api = apiAsync.maybeWhen(data: (a) => a, orElse: () => null);
  return DocumentosRepository(db, api: api, network: net);
});
