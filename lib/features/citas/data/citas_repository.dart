import 'dart:async';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../../correos/data/correos_repository.dart';
import '../../correos/domain/correo_tipo.dart';
import '../../correos/services/email_dispatcher.dart';
import '../domain/cita_estado.dart';
import 'eventos_repository.dart';

class CitasRepository {
  final AppDatabase _db;
  final ApiClient? _api;

  CitasRepository(this._db, {ApiClient? api}) : _api = api;

  bool get _esClienteRemoto => _api != null;

  Future<Cita?> porId(int id) {
    return (_db.select(_db.citas)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<String, dynamic>> hayDisponibilidad(DateTime fechaHora) async {
    final cfgRows = await _db.select(_db.configuracion).get();
    final cfg = {for (final r in cfgRows) r.clave: r.valor};
    final maxCitas = int.tryParse(cfg['max_citas_por_hora'] ?? '2') ?? 2;
    final intervalo = int.tryParse(cfg['intervalo_minutos'] ?? '30') ?? 30;

    if (fechaHora.minute % intervalo != 0) {
      return {'disponible': false, 'error': 'La hora debe ser en bloques de $intervalo minutos.'};
    }

    // Validar el bloque de intervalo (ej. 30 minutos)
    final inicioBloque = fechaHora;
    final finBloque = fechaHora.add(Duration(minutes: intervalo));
    
    // Si el bloque ya pasó, no está disponible
    if (finBloque.isBefore(DateTime.now())) {
      return {'disponible': false, 'error': 'Este horario ya pasó.'};
    }
    
    final inicioSegundos = inicioBloque.millisecondsSinceEpoch ~/ 1000;
    final finSegundos = finBloque.millisecondsSinceEpoch ~/ 1000;

    final citasEnBloque = await (_db.select(_db.citas)
          ..where((t) => 
              t.fechaHoraFirma.isBiggerOrEqualValue(inicioSegundos) &
              t.fechaHoraFirma.isSmallerThanValue(finSegundos) &
              t.isDelete.equals(false) &
              t.estado.equals('CANCELADA').not()))
        .get();

    if (citasEnBloque.length >= maxCitas) {
      final disponibles = await _buscarProximosDisponibles(fechaHora, intervalo, maxCitas);
      return {
        'disponible': false,
        'error': 'Horario lleno',
        'nombres': citasEnBloque.map((c) => c.personaNombre).toList(),
        'sugerencias': disponibles,
      };
    }

    return {'disponible': true};
  }

  Future<List<DateTime>> _buscarProximosDisponibles(DateTime fechaHora, int intervalo, int maxCitas) async {
    final disponibles = <DateTime>[];
    final ahora = DateTime.now();
    
    var temp = DateTime(fechaHora.year, fechaHora.month, fechaHora.day, 9, 0, 0);
    
    while (temp.hour < 16 && disponibles.length < 5) {
      final finBloque = temp.add(Duration(minutes: intervalo));
      
      // Solo sugerir si el bloque no ha pasado
      if (finBloque.isAfter(ahora)) {
        final inicioSegundos = temp.millisecondsSinceEpoch ~/ 1000;
        final finSegundos = finBloque.millisecondsSinceEpoch ~/ 1000;
        
        final citasEnBloque = await (_db.select(_db.citas)
              ..where((t) => 
                  t.fechaHoraFirma.isBiggerOrEqualValue(inicioSegundos) &
                  t.fechaHoraFirma.isSmallerThanValue(finSegundos) &
                  t.isDelete.equals(false) &
                  t.estado.equals('CANCELADA').not()))
            .get();
            
        if (citasEnBloque.length < maxCitas) {
          disponibles.add(temp);
        }
      }
      temp = temp.add(Duration(minutes: intervalo));
    }
    
    return disponibles;
  }

  Future<int> crear({
    required String personaNombre,
    required String personaCorreo,
    required String? personaDpi,
    required String? personaTelefono,
    required DateTime fechaHoraFirma,
    String? categoriaMotivoReagenda,
    String? notas,
    required int creadaPor,
    String? numeroContrato,
    String? puesto,
    String? salario,
    String? ubicacion,
    String? ubicacionEspecifica,
    String? fechaInicio,
    String? fechaFin,
    bool enviarCorreo = true,
    bool esperarPostMortem = false,
  }) async {
    final uuid = const Uuid().v4();
    final token = const Uuid().v4().replaceAll('-', '');
    final fechaSegundos = fechaHoraFirma.millisecondsSinceEpoch ~/ 1000;

    if (_esClienteRemoto) {
      await _api!.crearCita({
        'uuidPublico': uuid,
        'personaNombre': personaNombre,
        'personaCorreo': personaCorreo,
        'personaDpi': personaDpi,
        'personaTelefono': personaTelefono,
        'fechaHoraFirma': fechaSegundos,
        'tokenConfirmacion': token,
        'creadaPor': creadaPor,
        'notas': notas,
      });
      return -1;
    }

    final id = await _db.into(_db.citas).insert(
      CitasCompanion.insert(
        uuidPublico: uuid,
        personaNombre: personaNombre,
        personaCorreo: personaCorreo,
        personaDpi: Value(personaDpi),
        personaTelefono: Value(personaTelefono),
        numeroContrato: Value(numeroContrato),
        puesto: Value(puesto),
        salario: Value(salario),
        ubicacion: Value(ubicacion),
        ubicacionEspecifica: Value(ubicacionEspecifica),
        fechaInicio: Value(fechaInicio),
        fechaFin: Value(fechaFin),
        fechaHoraFirma: fechaSegundos,
        estado: Value(CitaEstado.citaCreada.dbValue),
        tokenConfirmacion: Value(token),
        categoriaMotivoReagenda: Value(categoriaMotivoReagenda),
        notas: Value(notas),
        creadaPor: creadaPor,
        dateCreation: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        dateUpdated: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        isDelete: const Value(false),
      ),
    );

    final cfgRows = await _db.select(_db.configuracion).get();
    final cfg = {for (final r in cfgRows) r.clave: r.valor};

    final citaCompleta = await porId(id);
    if (citaCompleta != null && enviarCorreo && !esperarPostMortem) {
      await _encolarCorreoPrueba(cita: citaCompleta, cfg: cfg);
    }

    return id;
  }

  Future<void> _encolarCorreoPrueba({
    required Cita cita,
    required Map<String, String?> cfg,
    int? postMortemDocId,
  }) async {
    final servidorIp = cfg['servidor_ip'] ?? '';
    final puerto = cfg['servidor_puerto'] ?? '8080';
    final token = cita.tokenConfirmacion ?? '';
    final enlace = servidorIp.isEmpty
        ? ''
        : 'http://$servidorIp:$puerto/api/confirmar/$token';
    final plantilla = cfg['plantilla_prueba'] ?? '';
    final empresa = cfg['empresa_nombre'] ?? 'SGC';

    // Buscar el Post Mortem escaneado para adjuntarlo
    String? rutaPostMortem;
    
    if (postMortemDocId != null) {
      final doc = await (_db.select(_db.documentos)
            ..where((t) => t.id.equals(postMortemDocId)))
          .getSingleOrNull();
      rutaPostMortem = doc?.rutaArchivo;
    } else {
      final doc = await (_db.select(_db.documentos)
            ..where((t) => 
                t.citaId.equals(cita.id) & 
                t.tipo.equals('post_mortem_escaneo') & 
                t.isDelete.equals(false))
            ..limit(1))
          .getSingleOrNull();
      rutaPostMortem = doc?.rutaArchivo;
    }

    final adjuntos = <String>[];
    if (rutaPostMortem != null) {
      adjuntos.add(rutaPostMortem);
    }

    final cuerpo = EmailDispatcher.resolverPlantilla(
      plantilla: plantilla,
      cita: cita,
      config: cfg.cast<String, String>(),
      enlaceConfirmacion: enlace,
    );
    final repo = CorreosRepository(_db);
    await repo.encolar(
      citaId: cita.id,
      tipo: CorreoTipo.prueba,
      destinatario: cita.personaCorreo,
      asunto: EmailDispatcher.asuntoPara(CorreoTipo.prueba, empresa: empresa),
      cuerpoHtml: cuerpo,
      adjuntos: adjuntos,
    );
  }


  Future<void> esperarYEncolarCorreo(int citaId, {int? postMortemDocId}) async {
    final cita = await porId(citaId);
    if (cita == null) return;

    // Usamos Drift para verificar si el Post Mortem ya está en la DB
    final doc = await (_db.select(_db.documentos)
          ..where((t) => 
              t.citaId.equals(citaId) & 
              t.tipo.equals('post_mortem_escaneo') & 
              t.isDelete.equals(false))
          ..limit(1))
        .getSingleOrNull();

    // Si el documento no está, esperamos con un Completer + Drift Stream
    if (doc == null) {
      final completer = Completer<void>();
      
      final query = (_db.select(_db.documentos)
            ..where((t) => 
                t.citaId.equals(citaId) & 
                t.tipo.equals('post_mortem_escaneo') & 
                t.isDelete.equals(false))
            ..limit(1));

      final sub = query.watch().listen((docs) {
        if (docs.isNotEmpty && !completer.isCompleted) {
          completer.complete();
        }
      });

      try {
        await completer.future.timeout(const Duration(seconds: 30));
      } catch (_) {
        // Si no se sube el Post Mortem en 30s, encolamos sin adjunto
      } finally {
        await sub.cancel();
      }
    }

    // Finalmente, encolamos el correo (que buscará el Post Mortem si existe)
    final cfgRows = await _db.select(_db.configuracion).get();
    final cfg = {for (final r in cfgRows) r.clave: r.valor};
    await _encolarCorreoPrueba(cita: cita, cfg: cfg, postMortemDocId: postMortemDocId);
  }
  Future<void> reenviarCorreoPrueba(int citaId, {int? postMortemDocId}) async {
    final cita = await porId(citaId);
    if (cita == null) throw Exception('Cita no encontrada');

    final cfgRows = await _db.select(_db.configuracion).get();
    final cfg = {for (final r in cfgRows) r.clave: r.valor};

    await _encolarCorreoPrueba(cita: cita, cfg: cfg, postMortemDocId: postMortemDocId);
  }

  Future<void> actualizarCorreo(int citaId, String nuevoCorreo, int userId) async {
    if (_esClienteRemoto) {
      await _api!.actualizarCita(citaId, {'personaCorreo': nuevoCorreo, 'userUpdated': userId});
      return;
    }
    await (_db.update(_db.citas)..where((t) => t.id.equals(citaId))).write(
      CitasCompanion(
        personaCorreo: Value(nuevoCorreo),
        dateUpdated: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        userUpdated: Value(userId),
      ),
    );
  }

  Future<void> cambiarEstado({
    required int citaId,
    required CitaEstado nuevoEstado,
    required int userId,
  }) async {
    final citaAntes = await porId(citaId);
    final estadoAnterior = citaAntes != null ? CitaEstado.fromDb(citaAntes.estado) : CitaEstado.citaCreada;

    if (_esClienteRemoto) {
      await _api!.actualizarCita(citaId, {'estado': nuevoEstado.dbValue, 'userUpdated': userId});
    } else {
      await (_db.update(_db.citas)..where((t) => t.id.equals(citaId))).write(
        CitasCompanion(
          estado: Value(nuevoEstado.dbValue),
          dateUpdated: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
          userUpdated: Value(userId),
        ),
      );
    }

    await EventosRepository(_db).registrar(
      citaId: citaId,
      tipoEvento: 'cambio_estado',
      detalle: {
        'anterior': estadoAnterior.label,
        'nuevo': nuevoEstado.label,
      },
      userId: userId,
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

    final docs = await (_db.select(_db.documentos)..where((t) => t.citaId.equals(citaId) & t.isDelete.equals(false))).get();
    final adjuntos = <String>[];
    for (final d in docs) {
      if (d.tipo == 'contrato_firmado' || d.tipo == 'responsabilidad_firmado') {
        adjuntos.add(d.rutaArchivo);
      }
    }

    final plantilla = cfg['plantilla_final'] ?? '';
    final empresa = cfg['empresa_nombre'] ?? 'SGC';
    final cuerpo = EmailDispatcher.resolverPlantilla(plantilla: plantilla, cita: cita, config: cfg.cast<String, String>());
    
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
    
    final nuevaFechaStr = DateFormat('dd/MM/yyyy HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma * 1000),
    );

    final cuerpo = EmailDispatcher.resolverPlantilla(
      plantilla: plantilla,
      cita: cita,
      config: cfg.cast<String, String>(),
      motivo: cita.motivoUltimaReagenda ?? 'Reagendamiento de cita',
      nuevaFecha: nuevaFechaStr,
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

  Future<void> cambiarCheckPostMortem(int citaId, bool valor, int userId) async {
    await (_db.update(_db.citas)..where((t) => t.id.equals(citaId))).write(
      CitasCompanion(
        postMortemPresentado: Value(valor),
        dateUpdated: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        userUpdated: Value(userId),
      ),
    );
  }

  Future<void> cambiarCheckContraloria(int citaId, bool valor, int userId) async {
    await (_db.update(_db.citas)..where((t) => t.id.equals(citaId))).write(
      CitasCompanion(
        contraloriaPresentada: Value(valor),
        dateUpdated: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        userUpdated: Value(userId),
      ),
    );
  }

  Stream<int> watchTotalAgendadas() {
    return (_db.select(_db.citas)
          ..where((t) => 
              t.isDelete.equals(false) &
              t.estado.equals(CitaEstado.cancelada.dbValue).not() &
              t.estado.equals(CitaEstado.cerrada.dbValue).not()))
        .watch()
        .map((r) => r.length);
  }

  Stream<int> watchVencidas() {
    final ahoraSegundos = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (_db.select(_db.citas)
          ..where((t) => 
              t.fechaHoraFirma.isSmallerThanValue(ahoraSegundos) &
              t.isDelete.equals(false) &
              t.estado.equals(CitaEstado.cerrada.dbValue).not() &
              t.estado.equals(CitaEstado.cancelada.dbValue).not() &
              t.estado.equals(CitaEstado.vencida.dbValue).not()))
        .watch()
        .map((r) => r.length);
  }

  Stream<int> watchTotalPorEstado(CitaEstado estado) {
    return (_db.select(_db.citas)..where((t) => t.estado.equals(estado.dbValue) & t.isDelete.equals(false))).watch().map((r) => r.length);
  }

  Stream<List<Cita>> watchRecientes({int limit = 10}) {
    return (_db.select(_db.citas)..where((t) => t.isDelete.equals(false))..orderBy([(t) => OrderingTerm.desc(t.dateCreation)])..limit(limit)).watch();
  }

  Stream<List<Cita>> watchFirmasEnviadas({
    String sortColumn = 'fecha',
    bool ascending = false,
  }) {
    final q = _db.select(_db.citas)
      ..where((t) => 
          (t.estado.equals(CitaEstado.contratoEnviado.dbValue) | 
           t.estado.equals(CitaEstado.cerrada.dbValue)) &
          t.isDelete.equals(false));

    switch (sortColumn) {
      case 'nombre':
        q.orderBy([(t) => OrderingTerm(expression: t.personaNombre, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
      case 'dpi':
        q.orderBy([(t) => OrderingTerm(expression: t.personaDpi, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
      case 'correo':
        q.orderBy([(t) => OrderingTerm(expression: t.personaCorreo, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
      case 'estado':
        q.orderBy([(t) => OrderingTerm(expression: t.estado, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
      case 'fecha':
      default:
        q.orderBy([(t) => OrderingTerm(expression: t.fechaHoraFirma, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
    }

    return q.watch();
  }

  Future<List<Cita>> obtenerCitasPorFecha(DateTime inicio, DateTime fin) async {
    final inicioSegundos = inicio.millisecondsSinceEpoch ~/ 1000;
    final finSegundos = fin.millisecondsSinceEpoch ~/ 1000;
    return await (_db.select(_db.citas)
          ..where((t) => 
              t.fechaHoraFirma.isBiggerOrEqualValue(inicioSegundos) &
              t.fechaHoraFirma.isSmallerThanValue(finSegundos) &
              t.isDelete.equals(false)))
        .get();
  }

  Stream<List<Cita>> watchTodas() {
    return (_db.select(_db.citas)..where((t) => t.isDelete.equals(false))).watch();
  }

  Stream<CitasPage> watchPage({
    int page = 0,
    int pageSize = 20,
    CitaEstado? estadoFiltro,
    String search = '',
    String sortColumn = 'fecha',
    bool ascending = false,
  }) {
    final q = _db.select(_db.citas)..where((t) => t.isDelete.equals(false));

    q.where((t) => 
        t.estado.equals(CitaEstado.cerrada.dbValue).not() & 
        t.estado.equals(CitaEstado.cancelada.dbValue).not());

    if (estadoFiltro != null) {
      q.where((t) => t.estado.equals(estadoFiltro.dbValue));
    }
    if (search.isNotEmpty) {
      q.where((t) => t.personaNombre.like('%$search%'));
    }

    switch (sortColumn) {
      case 'nombre':
        q.orderBy([(t) => OrderingTerm(expression: t.personaNombre, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
      case 'dpi':
        q.orderBy([(t) => OrderingTerm(expression: t.personaDpi, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
      case 'correo':
        q.orderBy([(t) => OrderingTerm(expression: t.personaCorreo, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
      case 'telefono':
        q.orderBy([(t) => OrderingTerm(expression: t.personaTelefono, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
      case 'estado':
        q.orderBy([(t) => OrderingTerm(expression: t.estado, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
      case 'creada':
        q.orderBy([(t) => OrderingTerm(expression: t.dateCreation, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
      case 'fecha':
      default:
        q.orderBy([(t) => OrderingTerm(expression: t.fechaHoraFirma, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
        break;
    }

    q.limit(pageSize, offset: page * pageSize);

    return q.watch().map((rows) => CitasPage(rows: rows, totalFiltered: rows.length));
  }
}

final citasRepositoryProvider = Provider<CitasRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CitasRepository(db);
});

class CitasPage {
  final List<Cita> rows;
  final int totalFiltered;

  CitasPage({required this.rows, required this.totalFiltered});
}
