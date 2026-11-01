import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_config.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/sync_provider.dart';
import '../../../data/database/app_database.dart';
import '../domain/documento_tipo.dart';

class DocumentosRepository {
  final AppDatabase _db;
  final ApiClient? _api;
  final NetworkConfig? _network;

  DocumentosRepository(this._db, {ApiClient? api, NetworkConfig? network})
      : _api = api, // ignore: prefer_initializing_formals
        _network = network; // ignore: prefer_initializing_formals

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
    // Import dinámico para no romper en cliente si FileStorageService se usa.
    final storage = _ServerStorageHolder.instance;
    final stored = await storage.guardarBytes(
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

/// Holder para evitar importar FileStorageService en el cliente.
class _ServerStorageHolder {
  static late final dynamic instance;
}

final documentosRepositoryProvider = Provider<DocumentosRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final netAsync = ref.watch(networkConfigProvider);
  final apiAsync = ref.watch(apiClientProvider);
  final net = netAsync.maybeWhen(data: (c) => c, orElse: () => null);
  final api = apiAsync.maybeWhen(data: (a) => a, orElse: () => null);
  return DocumentosRepository(db, api: api, network: net);
});
