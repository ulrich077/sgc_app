import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Roles,
  Usuarios,
  Permisos,
  Configuracion,
  Citas,
  Documentos,
  CorreosLog,
  EventosCita,
  Auditoria,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'sgc_db'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedInicial();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await _ensureClave('color_primary', '#FF1A237E');
            await _ensureClave('color_secondary', '#FF3949AB');
          }
        },
      );

  Future<void> _ensureClave(String clave, String valorDefault) async {
    final existing = await (select(configuracion)
          ..where((t) => t.clave.equals(clave)))
        .getSingleOrNull();
    if (existing == null) {
      await into(configuracion).insert(ConfiguracionCompanion.insert(
        clave: clave,
        valor: Value(valorDefault),
        tipo: const Value('string'),
      ));
    }
  }

  Future<void> _seedInicial() async {
    final adminRolId = await into(roles).insert(
      RolesCompanion.insert(
        nombre: 'administrador',
        descripcion: const Value(
            'Gestión de usuarios, permisos, SMTP, plantillas, estadísticas'),
      ),
    );
    final operadorRolId = await into(roles).insert(
      RolesCompanion.insert(
        nombre: 'operador',
        descripcion: const Value(
            'Flujo operativo de citas, reagenda, escaneos, correos'),
      ),
    );

    const modulosAdmin = [
      'usuarios',
      'permisos',
      'configuracion',
      'auditoria',
      'estadisticas',
      'plantillas',
    ];
    const modulosOperador = [
      'citas',
      'documentos',
      'correos',
      'dashboard',
      'firmas_enviadas',
    ];
    for (final m in modulosAdmin) {
      await into(permisos).insert(PermisosCompanion.insert(
        rolId: adminRolId,
        modulo: m,
        accion: 'admin',
      ));
    }
    for (final m in modulosOperador) {
      await into(permisos).insert(PermisosCompanion.insert(
        rolId: operadorRolId,
        modulo: m,
        accion: 'editar',
      ));
    }

    final hash = sha256.convert(utf8.encode('hacker94')).toString();
    await into(usuarios).insert(UsuariosCompanion.insert(
      username: 'admin',
      passwordHash: hash,
      nombreCompleto: 'Administrador',
      rolId: adminRolId,
      dateCreation: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    const clavesDefault = <String, String>{
      'empresa_nombre': '',
      'empresa_nit': '',
      'empresa_logo_base64': '',
      'smtp_host': '',
      'smtp_port': '587',
      'smtp_user': '',
      'smtp_password': '',
      'correo_remitente': '',
      'correo_cc_final': '',
      'dias_limite_envio_contrato': '5',
      'dias_limite_cgc': '30',
      'dias_vencimiento_token': '30',
      'max_palabras_motivo_reagenda': '500',
      'min_palabras_motivo_reagenda': '50',
      'texto_legal_responsabilidad': '',
      'texto_legal_multa': '',
      'nombre_interno_post_mortem': 'Post Mortem',
      'nombre_oficial_post_mortem': 'Designación de Beneficiarios',
      'tamano_logo': 'mediano',
      'servidor_ip': '',
      'es_servidor': 'false',
      'impresora_ticket': '',
      'color_primary': '#FF1A237E',
      'color_secondary': '#FF3949AB',
    };
    for (final e in clavesDefault.entries) {
      await into(configuracion).insert(ConfiguracionCompanion.insert(
        clave: e.key,
        valor: Value(e.value),
        tipo: const Value('string'),
      ));
    }
  }
}
