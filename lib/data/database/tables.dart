import 'package:drift/drift.dart';

// ── roles ─────────────────────────────────────────────────────────────────
class Roles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();
}

// ── usuarios ──────────────────────────────────────────────────────────────
class Usuarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get nombreCompleto => text()();
  IntColumn get rolId => integer().references(Roles, #id)();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  IntColumn get userCreation => integer().nullable()();
  IntColumn get dateCreation => integer().nullable()();
  IntColumn get userUpdated => integer().nullable()();
  IntColumn get dateUpdated => integer().nullable()();
  BoolColumn get isDelete => boolean().withDefault(const Constant(false))();
}

// ── permisos ──────────────────────────────────────────────────────────────
class Permisos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rolId => integer().references(Roles, #id)();
  TextColumn get modulo => text()();
  TextColumn get accion => text()();
}

// ── configuracion ─────────────────────────────────────────────────────────
class Configuracion extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clave => text().unique()();
  TextColumn get valor => text().nullable()();
  TextColumn get tipo => text().nullable()();
}

// ── citas ─────────────────────────────────────────────────────────────────
class Citas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuidPublico => text().unique()();
  TextColumn get personaNombre => text()();
  TextColumn get personaDpi => text().nullable()();
  TextColumn get personaCorreo => text()();
  TextColumn get personaTelefono => text().nullable()();
  TextColumn get numeroContrato => text().nullable()();
  TextColumn get puesto => text().nullable()();
  TextColumn get salario => text().nullable()();
  TextColumn get ubicacion => text().nullable()();
  TextColumn get ubicacionEspecifica => text().nullable()();
  TextColumn get fechaInicio => text().nullable()();
  TextColumn get fechaFin => text().nullable()();
  IntColumn get fechaHoraFirma => integer()();
  TextColumn get estado =>
      text().withDefault(const Constant('CITA_CREADA'))();
  TextColumn get tokenConfirmacion => text().nullable()();
  IntColumn get tokenExpira => integer().nullable()();
  IntColumn get confirmadoRecibidoAt => integer().nullable()();
  IntColumn get reagendadaVeces =>
      integer().withDefault(const Constant(0))();
  TextColumn get motivoUltimaReagenda => text().nullable()();
  TextColumn get categoriaMotivoReagenda => text().nullable()();
  BoolColumn get postMortemPresentado =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get contraloriaPresentada =>
      boolean().withDefault(const Constant(false))();
  IntColumn get probidadAperturadaAt => integer().nullable()();
  TextColumn get notas => text().nullable()();
  IntColumn get creadaPor => integer().references(Usuarios, #id)();
  IntColumn get userCreation => integer().nullable()();
  IntColumn get dateCreation => integer().nullable()();
  IntColumn get userUpdated => integer().nullable()();
  IntColumn get dateUpdated => integer().nullable()();
  BoolColumn get isDelete => boolean().withDefault(const Constant(false))();
}

// ── documentos ────────────────────────────────────────────────────────────
class Documentos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get citaId => integer().references(Citas, #id)();
  TextColumn get tipo => text()();
  TextColumn get nombre => text()();
  TextColumn get rutaArchivo => text()();
  TextColumn get hashSha256 => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get tamanoBytes => integer().nullable()();
  IntColumn get subidoPor => integer().references(Usuarios, #id)();
  IntColumn get subidoAt => integer()();
  BoolColumn get isDelete => boolean().withDefault(const Constant(false))();
}

// ── correos_log ───────────────────────────────────────────────────────────
class CorreosLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get citaId => integer().nullable().references(Citas, #id)();
  TextColumn get tipo => text()();
  TextColumn get destinatario => text()();
  TextColumn get cc => text().nullable()();
  TextColumn get asunto => text()();
  TextColumn get cuerpoHtml => text().nullable()();
  TextColumn get adjuntosJson => text().nullable()();
  TextColumn get estado =>
      text().withDefault(const Constant('pendiente'))();
  IntColumn get intentos => integer().withDefault(const Constant(0))();
  IntColumn get proximoIntentoAt => integer().nullable()();
  TextColumn get errorMensaje => text().nullable()();
  IntColumn get programadoAt => integer()();
  IntColumn get enviadoAt => integer().nullable()();
}

// ── eventos_cita ──────────────────────────────────────────────────────────
class EventosCita extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get citaId => integer().references(Citas, #id)();
  TextColumn get tipoEvento => text()();
  TextColumn get detalleJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get createdBy => integer().nullable().references(Usuarios, #id)();
}

// ── auditoria ─────────────────────────────────────────────────────────────
class Auditoria extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().nullable().references(Usuarios, #id)();
  TextColumn get tabla => text()();
  IntColumn get registroId => integer().nullable()();
  TextColumn get accion => text()();
  TextColumn get valorAntes => text().nullable()();
  TextColumn get valorDespues => text().nullable()();
  TextColumn get motivo => text().nullable()();
  IntColumn get fecha => integer()();
}
