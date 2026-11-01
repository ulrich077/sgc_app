import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_config.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/sync_provider.dart';
import '../../../data/database/app_database.dart';
import '../domain/cita_estado.dart';
import '../../correos/data/correos_repository.dart';
import '../../correos/domain/correo_tipo.dart';
import '../../correos/services/email_dispatcher.dart';

class CitasPage {
  final List<Cita> rows;
  final int totalFiltered;
  const CitasPage({required this.rows, required this.totalFiltered});
}

OrderingTerm _orderBy(String column, bool ascending, $CitasTable t) {
  final mode = ascending ? OrderingMode.asc : OrderingMode.desc;
  switch (column) {
    case 'nombre':
      return OrderingTerm(expression: t.personaNombre, mode: mode);
    case 'estado':
      return OrderingTerm(expression: t.estado, mode: mode);
    case 'creada':
      return OrderingTerm(expression: t.dateCreation, mode: mode);
    case 'fecha':
    default:
      return OrderingTerm(expression: t.fechaHoraFirma, mode: mode);
  }
}

class CitasRepository {
  final AppDatabase _db;
  final ApiClient? _api;
  final NetworkConfig? _network;

  CitasRepository(
    this._db, {
    ApiClient? api,
    NetworkConfig? network,
  })  : _api = api, // ignore: prefer_initializing_formals
        _network = network; // ignore: prefer_initializing_formals

  bool get _esClienteRemoto =>
      _api != null && _network != null && !_network.esServidor;

  Stream<CitasPage> watchPage({
    required int page,
    required int pageSize,
    CitaEstado? estadoFiltro,
    String search = '',
    String sortColumn = 'fecha',
    bool ascending = false,
  }) {
    final query = _db.select(_db.citas)
      ..where((t) => t.isDelete.equals(false));

    if (estadoFiltro != null) {
      query.where((t) => t.estado.equals(estadoFiltro.dbValue));
    }

    if (search.trim().isNotEmpty) {
      final s = '%${search.trim()}%';
      query.where((t) =>
          t.personaNombre.like(s) |
          t.personaDpi.like(s) |
          t.personaCorreo.like(s) |
          t.personaTelefono.like(s));
    }

    query.orderBy([(t) => _orderBy(sortColumn, ascending, t)]);
    query.limit(pageSize, offset: page * pageSize);

    final countQuery = _db.selectOnly(_db.citas)
      ..addColumns([_db.citas.id.count()])
      ..where(_db.citas.isDelete.equals(false));
    if (estadoFiltro != null) {
      countQuery.where(_db.citas.estado.equals(estadoFiltro.dbValue));
    }
    if (search.trim().isNotEmpty) {
      final s = '%${search.trim()}%';
      countQuery.where(_db.citas.personaNombre.like(s) |
          _db.citas.personaDpi.like(s) |
          _db.citas.personaCorreo.like(s) |
          _db.citas.personaTelefono.like(s));
    }

    return query.watch().asyncMap((rows) async {
      final countRow = await countQuery.getSingle();
      final total = countRow.read(_db.citas.id.count()) ?? 0;
      return CitasPage(rows: rows, totalFiltered: total);
    });
  }

  Future<Cita?> porId(int id) =>
      (_db.select(_db.citas)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> crear({
    required String personaNombre,
    required String personaCorreo,
    required DateTime fechaHoraFirma,
    String? personaDpi,
    String? personaTelefono,
    String? notas,
    required int creadaPor,
  }) async {
    if (_esClienteRemoto) {
      final res = await _api!.crearCita({
        'personaNombre': personaNombre,
        'personaCorreo': personaCorreo,
        'fechaHoraFirma': fechaHoraFirma.millisecondsSinceEpoch,
        'personaDpi': personaDpi,
        'personaTelefono': personaTelefono,
        'notas': notas,
        'creadaPor': creadaPor,
      });
      return (res['id'] as num).toInt();
    }

    final uuid =
        '${DateTime.now().microsecondsSinceEpoch}-${_db.hashCode}';
    final token = _generarToken();
    final cfgRows = await _db.select(_db.configuracion).get();
    final cfg = {for (final r in cfgRows) r.clave: r.valor};
    final diasToken =
        int.tryParse(cfg['dias_vencimiento_token'] ?? '') ?? 30;
    final expira = DateTime.now()
        .add(Duration(days: diasToken))
        .millisecondsSinceEpoch;

    final id = await _db.into(_db.citas).insert(CitasCompanion.insert(
          uuidPublico: uuid,
          personaNombre: personaNombre,
          personaCorreo: personaCorreo,
          fechaHoraFirma: fechaHoraFirma.millisecondsSinceEpoch,
          personaDpi: Value(personaDpi),
          personaTelefono: Value(personaTelefono),
          notas: Value(notas),
          creadaPor: creadaPor,
          tokenConfirmacion: Value(token),
          tokenExpira: Value(expira),
          dateCreation: Value(DateTime.now().millisecondsSinceEpoch),
          userCreation: Value(creadaPor),
        ));

    await _encolarCorreoPrueba(
      id: id,
      cfg: cfg,
      personaNombre: personaNombre,
      personaCorreo: personaCorreo,
      personaDpi: personaDpi,
      fechaHoraFirma: fechaHoraFirma,
      token: token,
    );
    return id;
  }

  String _generarToken() {
    // Token simple basado en microsegundos + hash. Para producción usar uuid v4.
    final ms = DateTime.now().microsecondsSinceEpoch;
    return '${ms.toRadixString(16)}${_db.hashCode.toRadixString(16)}';
  }

  Future<void> _encolarCorreoPrueba({
    required int id,
    required Map<String, String?> cfg,
    required String personaNombre,
    required String personaCorreo,
    required String? personaDpi,
    required DateTime fechaHoraFirma,
    required String token,
  }) async {
    final servidorIp = cfg['servidor_ip'] ?? '';
    final puerto = cfg['servidor_puerto'] ?? '8080';
    final enlace = servidorIp.isEmpty
        ? '(configura la IP del servidor)'
        : 'http://$servidorIp:$puerto/api/confirmar/$token';
    final plantilla = cfg['plantilla_prueba'] ?? '';
    final empresa = cfg['empresa_nombre'] ?? 'SGC';

    // Cita sintética para el dispatcher
    final cita = Cita(
      id: id,
      uuidPublico: '',
      personaNombre: personaNombre,
      personaCorreo: personaCorreo,
      personaDpi: personaDpi,
      personaTelefono: null,
      fechaHoraFirma: fechaHoraFirma.millisecondsSinceEpoch,
      estado: 'CITA_CREADA',
      tokenConfirmacion: token,
      tokenExpira: null,
      confirmadoRecibidoAt: null,
      reagendadaVeces: 0,
      motivoUltimaReagenda: null,
      categoriaMotivoReagenda: null,
      postMortemPresentado: false,
      contraloriaPresentada: false,
      probidadAperturadaAt: null,
      notas: null,
      creadaPor: 1,
      userCreation: null,
      dateCreation: null,
      userUpdated: null,
      dateUpdated: null,
      isDelete: false,
    );
    final cuerpo = EmailDispatcher.resolverPlantilla(
      plantilla: plantilla,
      cita: cita,
      config: cfg.cast<String, String>(),
      enlaceConfirmacion: enlace,
    );
    final repo = CorreosRepository(_db);
    await repo.encolar(
      citaId: id,
      tipo: CorreoTipo.prueba,
      destinatario: personaCorreo,
      asunto: EmailDispatcher.asuntoPara(CorreoTipo.prueba, empresa: empresa),
      cuerpoHtml: cuerpo,
    );
  }

  Future<void> cambiarEstado({
    required int citaId,
    required CitaEstado nuevoEstado,
    required int userId,
  }) async {
    if (_esClienteRemoto) {
      await _api!.actualizarCita(citaId, {
        'estado': nuevoEstado.dbValue,
        'userUpdated': userId,
      });
      return;
    }
    await (_db.update(_db.citas)..where((t) => t.id.equals(citaId))).write(
      CitasCompanion(
        estado: Value(nuevoEstado.dbValue),
        dateUpdated: Value(DateTime.now().millisecondsSinceEpoch),
        userUpdated: Value(userId),
      ),
    );

    if (nuevoEstado == CitaEstado.contratoEnviado) {
      await _encolarCorreoFinal(citaId);
    } else if (nuevoEstado == CitaEstado.reagendada) {
      await _encolarCorreoReagenda(citaId);
    }
  }

  Future<void> _encolarCorreoFinal(int citaId) async {
    final cita = await porId(citaId);
    if (cita == null) return;
    final cfgRows = await _db.select(_db.configuracion).get();
    final cfg = {for (final r in cfgRows) r.clave: r.valor};

    // Adjuntos: contrato firmado + documento de responsabilidad firmado
    final docs = await (_db.select(_db.documentos)
          ..where((t) =>
              t.citaId.equals(citaId) & t.isDelete.equals(false)))
        .get();
    final adjuntos = <String>[];
    for (final d in docs) {
      if (d.tipo == 'contrato_firmado' ||
          d.tipo == 'responsabilidad_firmado') {
        adjuntos.add(d.rutaArchivo);
      }
    }

    final plantilla = cfg['plantilla_final'] ?? '';
    final empresa = cfg['empresa_nombre'] ?? 'SGC';
    final cuerpo = EmailDispatcher.resolverPlantilla(
      plantilla: plantilla,
      cita: cita,
      config: cfg.cast<String, String>(),
    );
    final repo = CorreosRepository(_db);
    await repo.encolar(
      citaId: citaId,
      tipo: CorreoTipo.final_,
      destinatario: cita.personaCorreo,
      cc: cfg['correo_cc_final'],
      asunto: EmailDispatcher.asuntoPara(CorreoTipo.final_, empresa: empresa),
      cuerpoHtml: cuerpo,
      adjuntos: adjuntos,
    );
  }

  Future<void> _encolarCorreoReagenda(int citaId) async {
    final cita = await porId(citaId);
    if (cita == null) return;
    final cfgRows = await _db.select(_db.configuracion).get();
    final cfg = {for (final r in cfgRows) r.clave: r.valor};
    final plantilla = cfg['plantilla_reagenda'] ?? '';
    final empresa = cfg['empresa_nombre'] ?? 'SGC';
    final cuerpo = EmailDispatcher.resolverPlantilla(
      plantilla: plantilla,
      cita: cita,
      config: cfg.cast<String, String>(),
      motivo: cita.motivoUltimaReagenda,
    );
    final repo = CorreosRepository(_db);
    await repo.encolar(
      citaId: citaId,
      tipo: CorreoTipo.reagenda,
      destinatario: cita.personaCorreo,
      asunto: EmailDispatcher.asuntoPara(CorreoTipo.reagenda, empresa: empresa),
      cuerpoHtml: cuerpo,
    );
  }

  Stream<int> watchTotalPorEstado(CitaEstado estado) {
    return (_db.select(_db.citas)
          ..where((t) =>
              t.estado.equals(estado.dbValue) & t.isDelete.equals(false)))
        .watch()
        .map((r) => r.length);
  }

  Stream<List<Cita>> watchRecientes({int limit = 10}) {
    return (_db.select(_db.citas)
          ..where((t) => t.isDelete.equals(false))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.dateCreation, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .watch();
  }
}

/// Provider que se reconfigura cuando cambia networkConfig o apiClient.
final citasRepositoryProvider = Provider<CitasRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final netAsync = ref.watch(networkConfigProvider);
  final apiAsync = ref.watch(apiClientProvider);

  final net = netAsync.maybeWhen(data: (c) => c, orElse: () => null);
  final api = apiAsync.maybeWhen(data: (a) => a, orElse: () => null);

  return CitasRepository(db, api: api, network: net);
});
