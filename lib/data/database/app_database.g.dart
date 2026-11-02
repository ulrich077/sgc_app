// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RolesTable extends Roles with TableInfo<$RolesTable, Role> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombre, descripcion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Role> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Role map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Role(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
    );
  }

  @override
  $RolesTable createAlias(String alias) {
    return $RolesTable(attachedDatabase, alias);
  }
}

class Role extends DataClass implements Insertable<Role> {
  final int id;
  final String nombre;
  final String? descripcion;
  const Role({required this.id, required this.nombre, this.descripcion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    return map;
  }

  RolesCompanion toCompanion(bool nullToAbsent) {
    return RolesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
    );
  }

  factory Role.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Role(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'descripcion': serializer.toJson<String?>(descripcion),
    };
  }

  Role copyWith({
    int? id,
    String? nombre,
    Value<String?> descripcion = const Value.absent(),
  }) => Role(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
  );
  Role copyWithCompanion(RolesCompanion data) {
    return Role(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Role(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, descripcion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Role &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion);
}

class RolesCompanion extends UpdateCompanion<Role> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> descripcion;
  const RolesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
  });
  RolesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.descripcion = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Role> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? descripcion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
    });
  }

  RolesCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? descripcion,
  }) {
    return RolesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion')
          ..write(')'))
        .toString();
  }
}

class $UsuariosTable extends Usuarios with TableInfo<$UsuariosTable, Usuario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreCompletoMeta = const VerificationMeta(
    'nombreCompleto',
  );
  @override
  late final GeneratedColumn<String> nombreCompleto = GeneratedColumn<String>(
    'nombre_completo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolIdMeta = const VerificationMeta('rolId');
  @override
  late final GeneratedColumn<int> rolId = GeneratedColumn<int>(
    'rol_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES roles (id)',
    ),
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _userCreationMeta = const VerificationMeta(
    'userCreation',
  );
  @override
  late final GeneratedColumn<int> userCreation = GeneratedColumn<int>(
    'user_creation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCreationMeta = const VerificationMeta(
    'dateCreation',
  );
  @override
  late final GeneratedColumn<int> dateCreation = GeneratedColumn<int>(
    'date_creation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userUpdatedMeta = const VerificationMeta(
    'userUpdated',
  );
  @override
  late final GeneratedColumn<int> userUpdated = GeneratedColumn<int>(
    'user_updated',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<int> dateUpdated = GeneratedColumn<int>(
    'date_updated',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeleteMeta = const VerificationMeta(
    'isDelete',
  );
  @override
  late final GeneratedColumn<bool> isDelete = GeneratedColumn<bool>(
    'is_delete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_delete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    passwordHash,
    nombreCompleto,
    rolId,
    activo,
    userCreation,
    dateCreation,
    userUpdated,
    dateUpdated,
    isDelete,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Usuario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('nombre_completo')) {
      context.handle(
        _nombreCompletoMeta,
        nombreCompleto.isAcceptableOrUnknown(
          data['nombre_completo']!,
          _nombreCompletoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreCompletoMeta);
    }
    if (data.containsKey('rol_id')) {
      context.handle(
        _rolIdMeta,
        rolId.isAcceptableOrUnknown(data['rol_id']!, _rolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rolIdMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('user_creation')) {
      context.handle(
        _userCreationMeta,
        userCreation.isAcceptableOrUnknown(
          data['user_creation']!,
          _userCreationMeta,
        ),
      );
    }
    if (data.containsKey('date_creation')) {
      context.handle(
        _dateCreationMeta,
        dateCreation.isAcceptableOrUnknown(
          data['date_creation']!,
          _dateCreationMeta,
        ),
      );
    }
    if (data.containsKey('user_updated')) {
      context.handle(
        _userUpdatedMeta,
        userUpdated.isAcceptableOrUnknown(
          data['user_updated']!,
          _userUpdatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    }
    if (data.containsKey('is_delete')) {
      context.handle(
        _isDeleteMeta,
        isDelete.isAcceptableOrUnknown(data['is_delete']!, _isDeleteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Usuario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Usuario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      nombreCompleto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_completo'],
      )!,
      rolId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rol_id'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      userCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_creation'],
      ),
      dateCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_creation'],
      ),
      userUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_updated'],
      ),
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_updated'],
      ),
      isDelete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_delete'],
      )!,
    );
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }
}

class Usuario extends DataClass implements Insertable<Usuario> {
  final int id;
  final String username;
  final String passwordHash;
  final String nombreCompleto;
  final int rolId;
  final bool activo;
  final int? userCreation;
  final int? dateCreation;
  final int? userUpdated;
  final int? dateUpdated;
  final bool isDelete;
  const Usuario({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.nombreCompleto,
    required this.rolId,
    required this.activo,
    this.userCreation,
    this.dateCreation,
    this.userUpdated,
    this.dateUpdated,
    required this.isDelete,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<String>(passwordHash);
    map['nombre_completo'] = Variable<String>(nombreCompleto);
    map['rol_id'] = Variable<int>(rolId);
    map['activo'] = Variable<bool>(activo);
    if (!nullToAbsent || userCreation != null) {
      map['user_creation'] = Variable<int>(userCreation);
    }
    if (!nullToAbsent || dateCreation != null) {
      map['date_creation'] = Variable<int>(dateCreation);
    }
    if (!nullToAbsent || userUpdated != null) {
      map['user_updated'] = Variable<int>(userUpdated);
    }
    if (!nullToAbsent || dateUpdated != null) {
      map['date_updated'] = Variable<int>(dateUpdated);
    }
    map['is_delete'] = Variable<bool>(isDelete);
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(
      id: Value(id),
      username: Value(username),
      passwordHash: Value(passwordHash),
      nombreCompleto: Value(nombreCompleto),
      rolId: Value(rolId),
      activo: Value(activo),
      userCreation: userCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(userCreation),
      dateCreation: dateCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCreation),
      userUpdated: userUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(userUpdated),
      dateUpdated: dateUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(dateUpdated),
      isDelete: Value(isDelete),
    );
  }

  factory Usuario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Usuario(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      nombreCompleto: serializer.fromJson<String>(json['nombreCompleto']),
      rolId: serializer.fromJson<int>(json['rolId']),
      activo: serializer.fromJson<bool>(json['activo']),
      userCreation: serializer.fromJson<int?>(json['userCreation']),
      dateCreation: serializer.fromJson<int?>(json['dateCreation']),
      userUpdated: serializer.fromJson<int?>(json['userUpdated']),
      dateUpdated: serializer.fromJson<int?>(json['dateUpdated']),
      isDelete: serializer.fromJson<bool>(json['isDelete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'nombreCompleto': serializer.toJson<String>(nombreCompleto),
      'rolId': serializer.toJson<int>(rolId),
      'activo': serializer.toJson<bool>(activo),
      'userCreation': serializer.toJson<int?>(userCreation),
      'dateCreation': serializer.toJson<int?>(dateCreation),
      'userUpdated': serializer.toJson<int?>(userUpdated),
      'dateUpdated': serializer.toJson<int?>(dateUpdated),
      'isDelete': serializer.toJson<bool>(isDelete),
    };
  }

  Usuario copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? nombreCompleto,
    int? rolId,
    bool? activo,
    Value<int?> userCreation = const Value.absent(),
    Value<int?> dateCreation = const Value.absent(),
    Value<int?> userUpdated = const Value.absent(),
    Value<int?> dateUpdated = const Value.absent(),
    bool? isDelete,
  }) => Usuario(
    id: id ?? this.id,
    username: username ?? this.username,
    passwordHash: passwordHash ?? this.passwordHash,
    nombreCompleto: nombreCompleto ?? this.nombreCompleto,
    rolId: rolId ?? this.rolId,
    activo: activo ?? this.activo,
    userCreation: userCreation.present ? userCreation.value : this.userCreation,
    dateCreation: dateCreation.present ? dateCreation.value : this.dateCreation,
    userUpdated: userUpdated.present ? userUpdated.value : this.userUpdated,
    dateUpdated: dateUpdated.present ? dateUpdated.value : this.dateUpdated,
    isDelete: isDelete ?? this.isDelete,
  );
  Usuario copyWithCompanion(UsuariosCompanion data) {
    return Usuario(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      nombreCompleto: data.nombreCompleto.present
          ? data.nombreCompleto.value
          : this.nombreCompleto,
      rolId: data.rolId.present ? data.rolId.value : this.rolId,
      activo: data.activo.present ? data.activo.value : this.activo,
      userCreation: data.userCreation.present
          ? data.userCreation.value
          : this.userCreation,
      dateCreation: data.dateCreation.present
          ? data.dateCreation.value
          : this.dateCreation,
      userUpdated: data.userUpdated.present
          ? data.userUpdated.value
          : this.userUpdated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      isDelete: data.isDelete.present ? data.isDelete.value : this.isDelete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Usuario(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('nombreCompleto: $nombreCompleto, ')
          ..write('rolId: $rolId, ')
          ..write('activo: $activo, ')
          ..write('userCreation: $userCreation, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('userUpdated: $userUpdated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('isDelete: $isDelete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    passwordHash,
    nombreCompleto,
    rolId,
    activo,
    userCreation,
    dateCreation,
    userUpdated,
    dateUpdated,
    isDelete,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Usuario &&
          other.id == this.id &&
          other.username == this.username &&
          other.passwordHash == this.passwordHash &&
          other.nombreCompleto == this.nombreCompleto &&
          other.rolId == this.rolId &&
          other.activo == this.activo &&
          other.userCreation == this.userCreation &&
          other.dateCreation == this.dateCreation &&
          other.userUpdated == this.userUpdated &&
          other.dateUpdated == this.dateUpdated &&
          other.isDelete == this.isDelete);
}

class UsuariosCompanion extends UpdateCompanion<Usuario> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> passwordHash;
  final Value<String> nombreCompleto;
  final Value<int> rolId;
  final Value<bool> activo;
  final Value<int?> userCreation;
  final Value<int?> dateCreation;
  final Value<int?> userUpdated;
  final Value<int?> dateUpdated;
  final Value<bool> isDelete;
  const UsuariosCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.nombreCompleto = const Value.absent(),
    this.rolId = const Value.absent(),
    this.activo = const Value.absent(),
    this.userCreation = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.userUpdated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.isDelete = const Value.absent(),
  });
  UsuariosCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String passwordHash,
    required String nombreCompleto,
    required int rolId,
    this.activo = const Value.absent(),
    this.userCreation = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.userUpdated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.isDelete = const Value.absent(),
  }) : username = Value(username),
       passwordHash = Value(passwordHash),
       nombreCompleto = Value(nombreCompleto),
       rolId = Value(rolId);
  static Insertable<Usuario> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? passwordHash,
    Expression<String>? nombreCompleto,
    Expression<int>? rolId,
    Expression<bool>? activo,
    Expression<int>? userCreation,
    Expression<int>? dateCreation,
    Expression<int>? userUpdated,
    Expression<int>? dateUpdated,
    Expression<bool>? isDelete,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (nombreCompleto != null) 'nombre_completo': nombreCompleto,
      if (rolId != null) 'rol_id': rolId,
      if (activo != null) 'activo': activo,
      if (userCreation != null) 'user_creation': userCreation,
      if (dateCreation != null) 'date_creation': dateCreation,
      if (userUpdated != null) 'user_updated': userUpdated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (isDelete != null) 'is_delete': isDelete,
    });
  }

  UsuariosCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? passwordHash,
    Value<String>? nombreCompleto,
    Value<int>? rolId,
    Value<bool>? activo,
    Value<int?>? userCreation,
    Value<int?>? dateCreation,
    Value<int?>? userUpdated,
    Value<int?>? dateUpdated,
    Value<bool>? isDelete,
  }) {
    return UsuariosCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      rolId: rolId ?? this.rolId,
      activo: activo ?? this.activo,
      userCreation: userCreation ?? this.userCreation,
      dateCreation: dateCreation ?? this.dateCreation,
      userUpdated: userUpdated ?? this.userUpdated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      isDelete: isDelete ?? this.isDelete,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (nombreCompleto.present) {
      map['nombre_completo'] = Variable<String>(nombreCompleto.value);
    }
    if (rolId.present) {
      map['rol_id'] = Variable<int>(rolId.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (userCreation.present) {
      map['user_creation'] = Variable<int>(userCreation.value);
    }
    if (dateCreation.present) {
      map['date_creation'] = Variable<int>(dateCreation.value);
    }
    if (userUpdated.present) {
      map['user_updated'] = Variable<int>(userUpdated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<int>(dateUpdated.value);
    }
    if (isDelete.present) {
      map['is_delete'] = Variable<bool>(isDelete.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('nombreCompleto: $nombreCompleto, ')
          ..write('rolId: $rolId, ')
          ..write('activo: $activo, ')
          ..write('userCreation: $userCreation, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('userUpdated: $userUpdated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('isDelete: $isDelete')
          ..write(')'))
        .toString();
  }
}

class $PermisosTable extends Permisos with TableInfo<$PermisosTable, Permiso> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PermisosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rolIdMeta = const VerificationMeta('rolId');
  @override
  late final GeneratedColumn<int> rolId = GeneratedColumn<int>(
    'rol_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES roles (id)',
    ),
  );
  static const VerificationMeta _moduloMeta = const VerificationMeta('modulo');
  @override
  late final GeneratedColumn<String> modulo = GeneratedColumn<String>(
    'modulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accionMeta = const VerificationMeta('accion');
  @override
  late final GeneratedColumn<String> accion = GeneratedColumn<String>(
    'accion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, rolId, modulo, accion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'permisos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Permiso> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rol_id')) {
      context.handle(
        _rolIdMeta,
        rolId.isAcceptableOrUnknown(data['rol_id']!, _rolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rolIdMeta);
    }
    if (data.containsKey('modulo')) {
      context.handle(
        _moduloMeta,
        modulo.isAcceptableOrUnknown(data['modulo']!, _moduloMeta),
      );
    } else if (isInserting) {
      context.missing(_moduloMeta);
    }
    if (data.containsKey('accion')) {
      context.handle(
        _accionMeta,
        accion.isAcceptableOrUnknown(data['accion']!, _accionMeta),
      );
    } else if (isInserting) {
      context.missing(_accionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Permiso map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Permiso(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rolId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rol_id'],
      )!,
      modulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modulo'],
      )!,
      accion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accion'],
      )!,
    );
  }

  @override
  $PermisosTable createAlias(String alias) {
    return $PermisosTable(attachedDatabase, alias);
  }
}

class Permiso extends DataClass implements Insertable<Permiso> {
  final int id;
  final int rolId;
  final String modulo;
  final String accion;
  const Permiso({
    required this.id,
    required this.rolId,
    required this.modulo,
    required this.accion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rol_id'] = Variable<int>(rolId);
    map['modulo'] = Variable<String>(modulo);
    map['accion'] = Variable<String>(accion);
    return map;
  }

  PermisosCompanion toCompanion(bool nullToAbsent) {
    return PermisosCompanion(
      id: Value(id),
      rolId: Value(rolId),
      modulo: Value(modulo),
      accion: Value(accion),
    );
  }

  factory Permiso.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Permiso(
      id: serializer.fromJson<int>(json['id']),
      rolId: serializer.fromJson<int>(json['rolId']),
      modulo: serializer.fromJson<String>(json['modulo']),
      accion: serializer.fromJson<String>(json['accion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rolId': serializer.toJson<int>(rolId),
      'modulo': serializer.toJson<String>(modulo),
      'accion': serializer.toJson<String>(accion),
    };
  }

  Permiso copyWith({int? id, int? rolId, String? modulo, String? accion}) =>
      Permiso(
        id: id ?? this.id,
        rolId: rolId ?? this.rolId,
        modulo: modulo ?? this.modulo,
        accion: accion ?? this.accion,
      );
  Permiso copyWithCompanion(PermisosCompanion data) {
    return Permiso(
      id: data.id.present ? data.id.value : this.id,
      rolId: data.rolId.present ? data.rolId.value : this.rolId,
      modulo: data.modulo.present ? data.modulo.value : this.modulo,
      accion: data.accion.present ? data.accion.value : this.accion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Permiso(')
          ..write('id: $id, ')
          ..write('rolId: $rolId, ')
          ..write('modulo: $modulo, ')
          ..write('accion: $accion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rolId, modulo, accion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Permiso &&
          other.id == this.id &&
          other.rolId == this.rolId &&
          other.modulo == this.modulo &&
          other.accion == this.accion);
}

class PermisosCompanion extends UpdateCompanion<Permiso> {
  final Value<int> id;
  final Value<int> rolId;
  final Value<String> modulo;
  final Value<String> accion;
  const PermisosCompanion({
    this.id = const Value.absent(),
    this.rolId = const Value.absent(),
    this.modulo = const Value.absent(),
    this.accion = const Value.absent(),
  });
  PermisosCompanion.insert({
    this.id = const Value.absent(),
    required int rolId,
    required String modulo,
    required String accion,
  }) : rolId = Value(rolId),
       modulo = Value(modulo),
       accion = Value(accion);
  static Insertable<Permiso> custom({
    Expression<int>? id,
    Expression<int>? rolId,
    Expression<String>? modulo,
    Expression<String>? accion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rolId != null) 'rol_id': rolId,
      if (modulo != null) 'modulo': modulo,
      if (accion != null) 'accion': accion,
    });
  }

  PermisosCompanion copyWith({
    Value<int>? id,
    Value<int>? rolId,
    Value<String>? modulo,
    Value<String>? accion,
  }) {
    return PermisosCompanion(
      id: id ?? this.id,
      rolId: rolId ?? this.rolId,
      modulo: modulo ?? this.modulo,
      accion: accion ?? this.accion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rolId.present) {
      map['rol_id'] = Variable<int>(rolId.value);
    }
    if (modulo.present) {
      map['modulo'] = Variable<String>(modulo.value);
    }
    if (accion.present) {
      map['accion'] = Variable<String>(accion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PermisosCompanion(')
          ..write('id: $id, ')
          ..write('rolId: $rolId, ')
          ..write('modulo: $modulo, ')
          ..write('accion: $accion')
          ..write(')'))
        .toString();
  }
}

class $ConfiguracionTable extends Configuracion
    with TableInfo<$ConfiguracionTable, ConfiguracionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, clave, valor, tipo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuracion';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfiguracionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConfiguracionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfiguracionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      ),
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      ),
    );
  }

  @override
  $ConfiguracionTable createAlias(String alias) {
    return $ConfiguracionTable(attachedDatabase, alias);
  }
}

class ConfiguracionData extends DataClass
    implements Insertable<ConfiguracionData> {
  final int id;
  final String clave;
  final String? valor;
  final String? tipo;
  const ConfiguracionData({
    required this.id,
    required this.clave,
    this.valor,
    this.tipo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['clave'] = Variable<String>(clave);
    if (!nullToAbsent || valor != null) {
      map['valor'] = Variable<String>(valor);
    }
    if (!nullToAbsent || tipo != null) {
      map['tipo'] = Variable<String>(tipo);
    }
    return map;
  }

  ConfiguracionCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracionCompanion(
      id: Value(id),
      clave: Value(clave),
      valor: valor == null && nullToAbsent
          ? const Value.absent()
          : Value(valor),
      tipo: tipo == null && nullToAbsent ? const Value.absent() : Value(tipo),
    );
  }

  factory ConfiguracionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfiguracionData(
      id: serializer.fromJson<int>(json['id']),
      clave: serializer.fromJson<String>(json['clave']),
      valor: serializer.fromJson<String?>(json['valor']),
      tipo: serializer.fromJson<String?>(json['tipo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clave': serializer.toJson<String>(clave),
      'valor': serializer.toJson<String?>(valor),
      'tipo': serializer.toJson<String?>(tipo),
    };
  }

  ConfiguracionData copyWith({
    int? id,
    String? clave,
    Value<String?> valor = const Value.absent(),
    Value<String?> tipo = const Value.absent(),
  }) => ConfiguracionData(
    id: id ?? this.id,
    clave: clave ?? this.clave,
    valor: valor.present ? valor.value : this.valor,
    tipo: tipo.present ? tipo.value : this.tipo,
  );
  ConfiguracionData copyWithCompanion(ConfiguracionCompanion data) {
    return ConfiguracionData(
      id: data.id.present ? data.id.value : this.id,
      clave: data.clave.present ? data.clave.value : this.clave,
      valor: data.valor.present ? data.valor.value : this.valor,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionData(')
          ..write('id: $id, ')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, clave, valor, tipo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfiguracionData &&
          other.id == this.id &&
          other.clave == this.clave &&
          other.valor == this.valor &&
          other.tipo == this.tipo);
}

class ConfiguracionCompanion extends UpdateCompanion<ConfiguracionData> {
  final Value<int> id;
  final Value<String> clave;
  final Value<String?> valor;
  final Value<String?> tipo;
  const ConfiguracionCompanion({
    this.id = const Value.absent(),
    this.clave = const Value.absent(),
    this.valor = const Value.absent(),
    this.tipo = const Value.absent(),
  });
  ConfiguracionCompanion.insert({
    this.id = const Value.absent(),
    required String clave,
    this.valor = const Value.absent(),
    this.tipo = const Value.absent(),
  }) : clave = Value(clave);
  static Insertable<ConfiguracionData> custom({
    Expression<int>? id,
    Expression<String>? clave,
    Expression<String>? valor,
    Expression<String>? tipo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clave != null) 'clave': clave,
      if (valor != null) 'valor': valor,
      if (tipo != null) 'tipo': tipo,
    });
  }

  ConfiguracionCompanion copyWith({
    Value<int>? id,
    Value<String>? clave,
    Value<String?>? valor,
    Value<String?>? tipo,
  }) {
    return ConfiguracionCompanion(
      id: id ?? this.id,
      clave: clave ?? this.clave,
      valor: valor ?? this.valor,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionCompanion(')
          ..write('id: $id, ')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }
}

class $CitasTable extends Citas with TableInfo<$CitasTable, Cita> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CitasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidPublicoMeta = const VerificationMeta(
    'uuidPublico',
  );
  @override
  late final GeneratedColumn<String> uuidPublico = GeneratedColumn<String>(
    'uuid_publico',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _personaNombreMeta = const VerificationMeta(
    'personaNombre',
  );
  @override
  late final GeneratedColumn<String> personaNombre = GeneratedColumn<String>(
    'persona_nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personaDpiMeta = const VerificationMeta(
    'personaDpi',
  );
  @override
  late final GeneratedColumn<String> personaDpi = GeneratedColumn<String>(
    'persona_dpi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personaCorreoMeta = const VerificationMeta(
    'personaCorreo',
  );
  @override
  late final GeneratedColumn<String> personaCorreo = GeneratedColumn<String>(
    'persona_correo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personaTelefonoMeta = const VerificationMeta(
    'personaTelefono',
  );
  @override
  late final GeneratedColumn<String> personaTelefono = GeneratedColumn<String>(
    'persona_telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numeroContratoMeta = const VerificationMeta(
    'numeroContrato',
  );
  @override
  late final GeneratedColumn<String> numeroContrato = GeneratedColumn<String>(
    'numero_contrato',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _puestoMeta = const VerificationMeta('puesto');
  @override
  late final GeneratedColumn<String> puesto = GeneratedColumn<String>(
    'puesto',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salarioMeta = const VerificationMeta(
    'salario',
  );
  @override
  late final GeneratedColumn<String> salario = GeneratedColumn<String>(
    'salario',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ubicacionMeta = const VerificationMeta(
    'ubicacion',
  );
  @override
  late final GeneratedColumn<String> ubicacion = GeneratedColumn<String>(
    'ubicacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ubicacionEspecificaMeta =
      const VerificationMeta('ubicacionEspecifica');
  @override
  late final GeneratedColumn<String> ubicacionEspecifica =
      GeneratedColumn<String>(
        'ubicacion_especifica',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fechaInicioMeta = const VerificationMeta(
    'fechaInicio',
  );
  @override
  late final GeneratedColumn<String> fechaInicio = GeneratedColumn<String>(
    'fecha_inicio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaFinMeta = const VerificationMeta(
    'fechaFin',
  );
  @override
  late final GeneratedColumn<String> fechaFin = GeneratedColumn<String>(
    'fecha_fin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaHoraFirmaMeta = const VerificationMeta(
    'fechaHoraFirma',
  );
  @override
  late final GeneratedColumn<int> fechaHoraFirma = GeneratedColumn<int>(
    'fecha_hora_firma',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CITA_CREADA'),
  );
  static const VerificationMeta _tokenConfirmacionMeta = const VerificationMeta(
    'tokenConfirmacion',
  );
  @override
  late final GeneratedColumn<String> tokenConfirmacion =
      GeneratedColumn<String>(
        'token_confirmacion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tokenExpiraMeta = const VerificationMeta(
    'tokenExpira',
  );
  @override
  late final GeneratedColumn<int> tokenExpira = GeneratedColumn<int>(
    'token_expira',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmadoRecibidoAtMeta =
      const VerificationMeta('confirmadoRecibidoAt');
  @override
  late final GeneratedColumn<int> confirmadoRecibidoAt = GeneratedColumn<int>(
    'confirmado_recibido_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reagendadaVecesMeta = const VerificationMeta(
    'reagendadaVeces',
  );
  @override
  late final GeneratedColumn<int> reagendadaVeces = GeneratedColumn<int>(
    'reagendada_veces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _motivoUltimaReagendaMeta =
      const VerificationMeta('motivoUltimaReagenda');
  @override
  late final GeneratedColumn<String> motivoUltimaReagenda =
      GeneratedColumn<String>(
        'motivo_ultima_reagenda',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _categoriaMotivoReagendaMeta =
      const VerificationMeta('categoriaMotivoReagenda');
  @override
  late final GeneratedColumn<String> categoriaMotivoReagenda =
      GeneratedColumn<String>(
        'categoria_motivo_reagenda',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _postMortemPresentadoMeta =
      const VerificationMeta('postMortemPresentado');
  @override
  late final GeneratedColumn<bool> postMortemPresentado = GeneratedColumn<bool>(
    'post_mortem_presentado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("post_mortem_presentado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _contraloriaPresentadaMeta =
      const VerificationMeta('contraloriaPresentada');
  @override
  late final GeneratedColumn<bool> contraloriaPresentada =
      GeneratedColumn<bool>(
        'contraloria_presentada',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("contraloria_presentada" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _probidadAperturadaAtMeta =
      const VerificationMeta('probidadAperturadaAt');
  @override
  late final GeneratedColumn<int> probidadAperturadaAt = GeneratedColumn<int>(
    'probidad_aperturada_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadaPorMeta = const VerificationMeta(
    'creadaPor',
  );
  @override
  late final GeneratedColumn<int> creadaPor = GeneratedColumn<int>(
    'creada_por',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _userCreationMeta = const VerificationMeta(
    'userCreation',
  );
  @override
  late final GeneratedColumn<int> userCreation = GeneratedColumn<int>(
    'user_creation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCreationMeta = const VerificationMeta(
    'dateCreation',
  );
  @override
  late final GeneratedColumn<int> dateCreation = GeneratedColumn<int>(
    'date_creation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userUpdatedMeta = const VerificationMeta(
    'userUpdated',
  );
  @override
  late final GeneratedColumn<int> userUpdated = GeneratedColumn<int>(
    'user_updated',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateUpdatedMeta = const VerificationMeta(
    'dateUpdated',
  );
  @override
  late final GeneratedColumn<int> dateUpdated = GeneratedColumn<int>(
    'date_updated',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeleteMeta = const VerificationMeta(
    'isDelete',
  );
  @override
  late final GeneratedColumn<bool> isDelete = GeneratedColumn<bool>(
    'is_delete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_delete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuidPublico,
    personaNombre,
    personaDpi,
    personaCorreo,
    personaTelefono,
    numeroContrato,
    puesto,
    salario,
    ubicacion,
    ubicacionEspecifica,
    fechaInicio,
    fechaFin,
    fechaHoraFirma,
    estado,
    tokenConfirmacion,
    tokenExpira,
    confirmadoRecibidoAt,
    reagendadaVeces,
    motivoUltimaReagenda,
    categoriaMotivoReagenda,
    postMortemPresentado,
    contraloriaPresentada,
    probidadAperturadaAt,
    notas,
    creadaPor,
    userCreation,
    dateCreation,
    userUpdated,
    dateUpdated,
    isDelete,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'citas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cita> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid_publico')) {
      context.handle(
        _uuidPublicoMeta,
        uuidPublico.isAcceptableOrUnknown(
          data['uuid_publico']!,
          _uuidPublicoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidPublicoMeta);
    }
    if (data.containsKey('persona_nombre')) {
      context.handle(
        _personaNombreMeta,
        personaNombre.isAcceptableOrUnknown(
          data['persona_nombre']!,
          _personaNombreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_personaNombreMeta);
    }
    if (data.containsKey('persona_dpi')) {
      context.handle(
        _personaDpiMeta,
        personaDpi.isAcceptableOrUnknown(data['persona_dpi']!, _personaDpiMeta),
      );
    }
    if (data.containsKey('persona_correo')) {
      context.handle(
        _personaCorreoMeta,
        personaCorreo.isAcceptableOrUnknown(
          data['persona_correo']!,
          _personaCorreoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_personaCorreoMeta);
    }
    if (data.containsKey('persona_telefono')) {
      context.handle(
        _personaTelefonoMeta,
        personaTelefono.isAcceptableOrUnknown(
          data['persona_telefono']!,
          _personaTelefonoMeta,
        ),
      );
    }
    if (data.containsKey('numero_contrato')) {
      context.handle(
        _numeroContratoMeta,
        numeroContrato.isAcceptableOrUnknown(
          data['numero_contrato']!,
          _numeroContratoMeta,
        ),
      );
    }
    if (data.containsKey('puesto')) {
      context.handle(
        _puestoMeta,
        puesto.isAcceptableOrUnknown(data['puesto']!, _puestoMeta),
      );
    }
    if (data.containsKey('salario')) {
      context.handle(
        _salarioMeta,
        salario.isAcceptableOrUnknown(data['salario']!, _salarioMeta),
      );
    }
    if (data.containsKey('ubicacion')) {
      context.handle(
        _ubicacionMeta,
        ubicacion.isAcceptableOrUnknown(data['ubicacion']!, _ubicacionMeta),
      );
    }
    if (data.containsKey('ubicacion_especifica')) {
      context.handle(
        _ubicacionEspecificaMeta,
        ubicacionEspecifica.isAcceptableOrUnknown(
          data['ubicacion_especifica']!,
          _ubicacionEspecificaMeta,
        ),
      );
    }
    if (data.containsKey('fecha_inicio')) {
      context.handle(
        _fechaInicioMeta,
        fechaInicio.isAcceptableOrUnknown(
          data['fecha_inicio']!,
          _fechaInicioMeta,
        ),
      );
    }
    if (data.containsKey('fecha_fin')) {
      context.handle(
        _fechaFinMeta,
        fechaFin.isAcceptableOrUnknown(data['fecha_fin']!, _fechaFinMeta),
      );
    }
    if (data.containsKey('fecha_hora_firma')) {
      context.handle(
        _fechaHoraFirmaMeta,
        fechaHoraFirma.isAcceptableOrUnknown(
          data['fecha_hora_firma']!,
          _fechaHoraFirmaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaHoraFirmaMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('token_confirmacion')) {
      context.handle(
        _tokenConfirmacionMeta,
        tokenConfirmacion.isAcceptableOrUnknown(
          data['token_confirmacion']!,
          _tokenConfirmacionMeta,
        ),
      );
    }
    if (data.containsKey('token_expira')) {
      context.handle(
        _tokenExpiraMeta,
        tokenExpira.isAcceptableOrUnknown(
          data['token_expira']!,
          _tokenExpiraMeta,
        ),
      );
    }
    if (data.containsKey('confirmado_recibido_at')) {
      context.handle(
        _confirmadoRecibidoAtMeta,
        confirmadoRecibidoAt.isAcceptableOrUnknown(
          data['confirmado_recibido_at']!,
          _confirmadoRecibidoAtMeta,
        ),
      );
    }
    if (data.containsKey('reagendada_veces')) {
      context.handle(
        _reagendadaVecesMeta,
        reagendadaVeces.isAcceptableOrUnknown(
          data['reagendada_veces']!,
          _reagendadaVecesMeta,
        ),
      );
    }
    if (data.containsKey('motivo_ultima_reagenda')) {
      context.handle(
        _motivoUltimaReagendaMeta,
        motivoUltimaReagenda.isAcceptableOrUnknown(
          data['motivo_ultima_reagenda']!,
          _motivoUltimaReagendaMeta,
        ),
      );
    }
    if (data.containsKey('categoria_motivo_reagenda')) {
      context.handle(
        _categoriaMotivoReagendaMeta,
        categoriaMotivoReagenda.isAcceptableOrUnknown(
          data['categoria_motivo_reagenda']!,
          _categoriaMotivoReagendaMeta,
        ),
      );
    }
    if (data.containsKey('post_mortem_presentado')) {
      context.handle(
        _postMortemPresentadoMeta,
        postMortemPresentado.isAcceptableOrUnknown(
          data['post_mortem_presentado']!,
          _postMortemPresentadoMeta,
        ),
      );
    }
    if (data.containsKey('contraloria_presentada')) {
      context.handle(
        _contraloriaPresentadaMeta,
        contraloriaPresentada.isAcceptableOrUnknown(
          data['contraloria_presentada']!,
          _contraloriaPresentadaMeta,
        ),
      );
    }
    if (data.containsKey('probidad_aperturada_at')) {
      context.handle(
        _probidadAperturadaAtMeta,
        probidadAperturadaAt.isAcceptableOrUnknown(
          data['probidad_aperturada_at']!,
          _probidadAperturadaAtMeta,
        ),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('creada_por')) {
      context.handle(
        _creadaPorMeta,
        creadaPor.isAcceptableOrUnknown(data['creada_por']!, _creadaPorMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaPorMeta);
    }
    if (data.containsKey('user_creation')) {
      context.handle(
        _userCreationMeta,
        userCreation.isAcceptableOrUnknown(
          data['user_creation']!,
          _userCreationMeta,
        ),
      );
    }
    if (data.containsKey('date_creation')) {
      context.handle(
        _dateCreationMeta,
        dateCreation.isAcceptableOrUnknown(
          data['date_creation']!,
          _dateCreationMeta,
        ),
      );
    }
    if (data.containsKey('user_updated')) {
      context.handle(
        _userUpdatedMeta,
        userUpdated.isAcceptableOrUnknown(
          data['user_updated']!,
          _userUpdatedMeta,
        ),
      );
    }
    if (data.containsKey('date_updated')) {
      context.handle(
        _dateUpdatedMeta,
        dateUpdated.isAcceptableOrUnknown(
          data['date_updated']!,
          _dateUpdatedMeta,
        ),
      );
    }
    if (data.containsKey('is_delete')) {
      context.handle(
        _isDeleteMeta,
        isDelete.isAcceptableOrUnknown(data['is_delete']!, _isDeleteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cita map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cita(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuidPublico: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_publico'],
      )!,
      personaNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_nombre'],
      )!,
      personaDpi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_dpi'],
      ),
      personaCorreo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_correo'],
      )!,
      personaTelefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_telefono'],
      ),
      numeroContrato: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numero_contrato'],
      ),
      puesto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}puesto'],
      ),
      salario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salario'],
      ),
      ubicacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ubicacion'],
      ),
      ubicacionEspecifica: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ubicacion_especifica'],
      ),
      fechaInicio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha_inicio'],
      ),
      fechaFin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha_fin'],
      ),
      fechaHoraFirma: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_hora_firma'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      tokenConfirmacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_confirmacion'],
      ),
      tokenExpira: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token_expira'],
      ),
      confirmadoRecibidoAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confirmado_recibido_at'],
      ),
      reagendadaVeces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reagendada_veces'],
      )!,
      motivoUltimaReagenda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo_ultima_reagenda'],
      ),
      categoriaMotivoReagenda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria_motivo_reagenda'],
      ),
      postMortemPresentado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}post_mortem_presentado'],
      )!,
      contraloriaPresentada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}contraloria_presentada'],
      )!,
      probidadAperturadaAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}probidad_aperturada_at'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      creadaPor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creada_por'],
      )!,
      userCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_creation'],
      ),
      dateCreation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_creation'],
      ),
      userUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_updated'],
      ),
      dateUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_updated'],
      ),
      isDelete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_delete'],
      )!,
    );
  }

  @override
  $CitasTable createAlias(String alias) {
    return $CitasTable(attachedDatabase, alias);
  }
}

class Cita extends DataClass implements Insertable<Cita> {
  final int id;
  final String uuidPublico;
  final String personaNombre;
  final String? personaDpi;
  final String personaCorreo;
  final String? personaTelefono;
  final String? numeroContrato;
  final String? puesto;
  final String? salario;
  final String? ubicacion;
  final String? ubicacionEspecifica;
  final String? fechaInicio;
  final String? fechaFin;
  final int fechaHoraFirma;
  final String estado;
  final String? tokenConfirmacion;
  final int? tokenExpira;
  final int? confirmadoRecibidoAt;
  final int reagendadaVeces;
  final String? motivoUltimaReagenda;
  final String? categoriaMotivoReagenda;
  final bool postMortemPresentado;
  final bool contraloriaPresentada;
  final int? probidadAperturadaAt;
  final String? notas;
  final int creadaPor;
  final int? userCreation;
  final int? dateCreation;
  final int? userUpdated;
  final int? dateUpdated;
  final bool isDelete;
  const Cita({
    required this.id,
    required this.uuidPublico,
    required this.personaNombre,
    this.personaDpi,
    required this.personaCorreo,
    this.personaTelefono,
    this.numeroContrato,
    this.puesto,
    this.salario,
    this.ubicacion,
    this.ubicacionEspecifica,
    this.fechaInicio,
    this.fechaFin,
    required this.fechaHoraFirma,
    required this.estado,
    this.tokenConfirmacion,
    this.tokenExpira,
    this.confirmadoRecibidoAt,
    required this.reagendadaVeces,
    this.motivoUltimaReagenda,
    this.categoriaMotivoReagenda,
    required this.postMortemPresentado,
    required this.contraloriaPresentada,
    this.probidadAperturadaAt,
    this.notas,
    required this.creadaPor,
    this.userCreation,
    this.dateCreation,
    this.userUpdated,
    this.dateUpdated,
    required this.isDelete,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid_publico'] = Variable<String>(uuidPublico);
    map['persona_nombre'] = Variable<String>(personaNombre);
    if (!nullToAbsent || personaDpi != null) {
      map['persona_dpi'] = Variable<String>(personaDpi);
    }
    map['persona_correo'] = Variable<String>(personaCorreo);
    if (!nullToAbsent || personaTelefono != null) {
      map['persona_telefono'] = Variable<String>(personaTelefono);
    }
    if (!nullToAbsent || numeroContrato != null) {
      map['numero_contrato'] = Variable<String>(numeroContrato);
    }
    if (!nullToAbsent || puesto != null) {
      map['puesto'] = Variable<String>(puesto);
    }
    if (!nullToAbsent || salario != null) {
      map['salario'] = Variable<String>(salario);
    }
    if (!nullToAbsent || ubicacion != null) {
      map['ubicacion'] = Variable<String>(ubicacion);
    }
    if (!nullToAbsent || ubicacionEspecifica != null) {
      map['ubicacion_especifica'] = Variable<String>(ubicacionEspecifica);
    }
    if (!nullToAbsent || fechaInicio != null) {
      map['fecha_inicio'] = Variable<String>(fechaInicio);
    }
    if (!nullToAbsent || fechaFin != null) {
      map['fecha_fin'] = Variable<String>(fechaFin);
    }
    map['fecha_hora_firma'] = Variable<int>(fechaHoraFirma);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || tokenConfirmacion != null) {
      map['token_confirmacion'] = Variable<String>(tokenConfirmacion);
    }
    if (!nullToAbsent || tokenExpira != null) {
      map['token_expira'] = Variable<int>(tokenExpira);
    }
    if (!nullToAbsent || confirmadoRecibidoAt != null) {
      map['confirmado_recibido_at'] = Variable<int>(confirmadoRecibidoAt);
    }
    map['reagendada_veces'] = Variable<int>(reagendadaVeces);
    if (!nullToAbsent || motivoUltimaReagenda != null) {
      map['motivo_ultima_reagenda'] = Variable<String>(motivoUltimaReagenda);
    }
    if (!nullToAbsent || categoriaMotivoReagenda != null) {
      map['categoria_motivo_reagenda'] = Variable<String>(
        categoriaMotivoReagenda,
      );
    }
    map['post_mortem_presentado'] = Variable<bool>(postMortemPresentado);
    map['contraloria_presentada'] = Variable<bool>(contraloriaPresentada);
    if (!nullToAbsent || probidadAperturadaAt != null) {
      map['probidad_aperturada_at'] = Variable<int>(probidadAperturadaAt);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    map['creada_por'] = Variable<int>(creadaPor);
    if (!nullToAbsent || userCreation != null) {
      map['user_creation'] = Variable<int>(userCreation);
    }
    if (!nullToAbsent || dateCreation != null) {
      map['date_creation'] = Variable<int>(dateCreation);
    }
    if (!nullToAbsent || userUpdated != null) {
      map['user_updated'] = Variable<int>(userUpdated);
    }
    if (!nullToAbsent || dateUpdated != null) {
      map['date_updated'] = Variable<int>(dateUpdated);
    }
    map['is_delete'] = Variable<bool>(isDelete);
    return map;
  }

  CitasCompanion toCompanion(bool nullToAbsent) {
    return CitasCompanion(
      id: Value(id),
      uuidPublico: Value(uuidPublico),
      personaNombre: Value(personaNombre),
      personaDpi: personaDpi == null && nullToAbsent
          ? const Value.absent()
          : Value(personaDpi),
      personaCorreo: Value(personaCorreo),
      personaTelefono: personaTelefono == null && nullToAbsent
          ? const Value.absent()
          : Value(personaTelefono),
      numeroContrato: numeroContrato == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroContrato),
      puesto: puesto == null && nullToAbsent
          ? const Value.absent()
          : Value(puesto),
      salario: salario == null && nullToAbsent
          ? const Value.absent()
          : Value(salario),
      ubicacion: ubicacion == null && nullToAbsent
          ? const Value.absent()
          : Value(ubicacion),
      ubicacionEspecifica: ubicacionEspecifica == null && nullToAbsent
          ? const Value.absent()
          : Value(ubicacionEspecifica),
      fechaInicio: fechaInicio == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaInicio),
      fechaFin: fechaFin == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaFin),
      fechaHoraFirma: Value(fechaHoraFirma),
      estado: Value(estado),
      tokenConfirmacion: tokenConfirmacion == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenConfirmacion),
      tokenExpira: tokenExpira == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenExpira),
      confirmadoRecibidoAt: confirmadoRecibidoAt == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmadoRecibidoAt),
      reagendadaVeces: Value(reagendadaVeces),
      motivoUltimaReagenda: motivoUltimaReagenda == null && nullToAbsent
          ? const Value.absent()
          : Value(motivoUltimaReagenda),
      categoriaMotivoReagenda: categoriaMotivoReagenda == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaMotivoReagenda),
      postMortemPresentado: Value(postMortemPresentado),
      contraloriaPresentada: Value(contraloriaPresentada),
      probidadAperturadaAt: probidadAperturadaAt == null && nullToAbsent
          ? const Value.absent()
          : Value(probidadAperturadaAt),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      creadaPor: Value(creadaPor),
      userCreation: userCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(userCreation),
      dateCreation: dateCreation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCreation),
      userUpdated: userUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(userUpdated),
      dateUpdated: dateUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(dateUpdated),
      isDelete: Value(isDelete),
    );
  }

  factory Cita.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cita(
      id: serializer.fromJson<int>(json['id']),
      uuidPublico: serializer.fromJson<String>(json['uuidPublico']),
      personaNombre: serializer.fromJson<String>(json['personaNombre']),
      personaDpi: serializer.fromJson<String?>(json['personaDpi']),
      personaCorreo: serializer.fromJson<String>(json['personaCorreo']),
      personaTelefono: serializer.fromJson<String?>(json['personaTelefono']),
      numeroContrato: serializer.fromJson<String?>(json['numeroContrato']),
      puesto: serializer.fromJson<String?>(json['puesto']),
      salario: serializer.fromJson<String?>(json['salario']),
      ubicacion: serializer.fromJson<String?>(json['ubicacion']),
      ubicacionEspecifica: serializer.fromJson<String?>(
        json['ubicacionEspecifica'],
      ),
      fechaInicio: serializer.fromJson<String?>(json['fechaInicio']),
      fechaFin: serializer.fromJson<String?>(json['fechaFin']),
      fechaHoraFirma: serializer.fromJson<int>(json['fechaHoraFirma']),
      estado: serializer.fromJson<String>(json['estado']),
      tokenConfirmacion: serializer.fromJson<String?>(
        json['tokenConfirmacion'],
      ),
      tokenExpira: serializer.fromJson<int?>(json['tokenExpira']),
      confirmadoRecibidoAt: serializer.fromJson<int?>(
        json['confirmadoRecibidoAt'],
      ),
      reagendadaVeces: serializer.fromJson<int>(json['reagendadaVeces']),
      motivoUltimaReagenda: serializer.fromJson<String?>(
        json['motivoUltimaReagenda'],
      ),
      categoriaMotivoReagenda: serializer.fromJson<String?>(
        json['categoriaMotivoReagenda'],
      ),
      postMortemPresentado: serializer.fromJson<bool>(
        json['postMortemPresentado'],
      ),
      contraloriaPresentada: serializer.fromJson<bool>(
        json['contraloriaPresentada'],
      ),
      probidadAperturadaAt: serializer.fromJson<int?>(
        json['probidadAperturadaAt'],
      ),
      notas: serializer.fromJson<String?>(json['notas']),
      creadaPor: serializer.fromJson<int>(json['creadaPor']),
      userCreation: serializer.fromJson<int?>(json['userCreation']),
      dateCreation: serializer.fromJson<int?>(json['dateCreation']),
      userUpdated: serializer.fromJson<int?>(json['userUpdated']),
      dateUpdated: serializer.fromJson<int?>(json['dateUpdated']),
      isDelete: serializer.fromJson<bool>(json['isDelete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuidPublico': serializer.toJson<String>(uuidPublico),
      'personaNombre': serializer.toJson<String>(personaNombre),
      'personaDpi': serializer.toJson<String?>(personaDpi),
      'personaCorreo': serializer.toJson<String>(personaCorreo),
      'personaTelefono': serializer.toJson<String?>(personaTelefono),
      'numeroContrato': serializer.toJson<String?>(numeroContrato),
      'puesto': serializer.toJson<String?>(puesto),
      'salario': serializer.toJson<String?>(salario),
      'ubicacion': serializer.toJson<String?>(ubicacion),
      'ubicacionEspecifica': serializer.toJson<String?>(ubicacionEspecifica),
      'fechaInicio': serializer.toJson<String?>(fechaInicio),
      'fechaFin': serializer.toJson<String?>(fechaFin),
      'fechaHoraFirma': serializer.toJson<int>(fechaHoraFirma),
      'estado': serializer.toJson<String>(estado),
      'tokenConfirmacion': serializer.toJson<String?>(tokenConfirmacion),
      'tokenExpira': serializer.toJson<int?>(tokenExpira),
      'confirmadoRecibidoAt': serializer.toJson<int?>(confirmadoRecibidoAt),
      'reagendadaVeces': serializer.toJson<int>(reagendadaVeces),
      'motivoUltimaReagenda': serializer.toJson<String?>(motivoUltimaReagenda),
      'categoriaMotivoReagenda': serializer.toJson<String?>(
        categoriaMotivoReagenda,
      ),
      'postMortemPresentado': serializer.toJson<bool>(postMortemPresentado),
      'contraloriaPresentada': serializer.toJson<bool>(contraloriaPresentada),
      'probidadAperturadaAt': serializer.toJson<int?>(probidadAperturadaAt),
      'notas': serializer.toJson<String?>(notas),
      'creadaPor': serializer.toJson<int>(creadaPor),
      'userCreation': serializer.toJson<int?>(userCreation),
      'dateCreation': serializer.toJson<int?>(dateCreation),
      'userUpdated': serializer.toJson<int?>(userUpdated),
      'dateUpdated': serializer.toJson<int?>(dateUpdated),
      'isDelete': serializer.toJson<bool>(isDelete),
    };
  }

  Cita copyWith({
    int? id,
    String? uuidPublico,
    String? personaNombre,
    Value<String?> personaDpi = const Value.absent(),
    String? personaCorreo,
    Value<String?> personaTelefono = const Value.absent(),
    Value<String?> numeroContrato = const Value.absent(),
    Value<String?> puesto = const Value.absent(),
    Value<String?> salario = const Value.absent(),
    Value<String?> ubicacion = const Value.absent(),
    Value<String?> ubicacionEspecifica = const Value.absent(),
    Value<String?> fechaInicio = const Value.absent(),
    Value<String?> fechaFin = const Value.absent(),
    int? fechaHoraFirma,
    String? estado,
    Value<String?> tokenConfirmacion = const Value.absent(),
    Value<int?> tokenExpira = const Value.absent(),
    Value<int?> confirmadoRecibidoAt = const Value.absent(),
    int? reagendadaVeces,
    Value<String?> motivoUltimaReagenda = const Value.absent(),
    Value<String?> categoriaMotivoReagenda = const Value.absent(),
    bool? postMortemPresentado,
    bool? contraloriaPresentada,
    Value<int?> probidadAperturadaAt = const Value.absent(),
    Value<String?> notas = const Value.absent(),
    int? creadaPor,
    Value<int?> userCreation = const Value.absent(),
    Value<int?> dateCreation = const Value.absent(),
    Value<int?> userUpdated = const Value.absent(),
    Value<int?> dateUpdated = const Value.absent(),
    bool? isDelete,
  }) => Cita(
    id: id ?? this.id,
    uuidPublico: uuidPublico ?? this.uuidPublico,
    personaNombre: personaNombre ?? this.personaNombre,
    personaDpi: personaDpi.present ? personaDpi.value : this.personaDpi,
    personaCorreo: personaCorreo ?? this.personaCorreo,
    personaTelefono: personaTelefono.present
        ? personaTelefono.value
        : this.personaTelefono,
    numeroContrato: numeroContrato.present
        ? numeroContrato.value
        : this.numeroContrato,
    puesto: puesto.present ? puesto.value : this.puesto,
    salario: salario.present ? salario.value : this.salario,
    ubicacion: ubicacion.present ? ubicacion.value : this.ubicacion,
    ubicacionEspecifica: ubicacionEspecifica.present
        ? ubicacionEspecifica.value
        : this.ubicacionEspecifica,
    fechaInicio: fechaInicio.present ? fechaInicio.value : this.fechaInicio,
    fechaFin: fechaFin.present ? fechaFin.value : this.fechaFin,
    fechaHoraFirma: fechaHoraFirma ?? this.fechaHoraFirma,
    estado: estado ?? this.estado,
    tokenConfirmacion: tokenConfirmacion.present
        ? tokenConfirmacion.value
        : this.tokenConfirmacion,
    tokenExpira: tokenExpira.present ? tokenExpira.value : this.tokenExpira,
    confirmadoRecibidoAt: confirmadoRecibidoAt.present
        ? confirmadoRecibidoAt.value
        : this.confirmadoRecibidoAt,
    reagendadaVeces: reagendadaVeces ?? this.reagendadaVeces,
    motivoUltimaReagenda: motivoUltimaReagenda.present
        ? motivoUltimaReagenda.value
        : this.motivoUltimaReagenda,
    categoriaMotivoReagenda: categoriaMotivoReagenda.present
        ? categoriaMotivoReagenda.value
        : this.categoriaMotivoReagenda,
    postMortemPresentado: postMortemPresentado ?? this.postMortemPresentado,
    contraloriaPresentada: contraloriaPresentada ?? this.contraloriaPresentada,
    probidadAperturadaAt: probidadAperturadaAt.present
        ? probidadAperturadaAt.value
        : this.probidadAperturadaAt,
    notas: notas.present ? notas.value : this.notas,
    creadaPor: creadaPor ?? this.creadaPor,
    userCreation: userCreation.present ? userCreation.value : this.userCreation,
    dateCreation: dateCreation.present ? dateCreation.value : this.dateCreation,
    userUpdated: userUpdated.present ? userUpdated.value : this.userUpdated,
    dateUpdated: dateUpdated.present ? dateUpdated.value : this.dateUpdated,
    isDelete: isDelete ?? this.isDelete,
  );
  Cita copyWithCompanion(CitasCompanion data) {
    return Cita(
      id: data.id.present ? data.id.value : this.id,
      uuidPublico: data.uuidPublico.present
          ? data.uuidPublico.value
          : this.uuidPublico,
      personaNombre: data.personaNombre.present
          ? data.personaNombre.value
          : this.personaNombre,
      personaDpi: data.personaDpi.present
          ? data.personaDpi.value
          : this.personaDpi,
      personaCorreo: data.personaCorreo.present
          ? data.personaCorreo.value
          : this.personaCorreo,
      personaTelefono: data.personaTelefono.present
          ? data.personaTelefono.value
          : this.personaTelefono,
      numeroContrato: data.numeroContrato.present
          ? data.numeroContrato.value
          : this.numeroContrato,
      puesto: data.puesto.present ? data.puesto.value : this.puesto,
      salario: data.salario.present ? data.salario.value : this.salario,
      ubicacion: data.ubicacion.present ? data.ubicacion.value : this.ubicacion,
      ubicacionEspecifica: data.ubicacionEspecifica.present
          ? data.ubicacionEspecifica.value
          : this.ubicacionEspecifica,
      fechaInicio: data.fechaInicio.present
          ? data.fechaInicio.value
          : this.fechaInicio,
      fechaFin: data.fechaFin.present ? data.fechaFin.value : this.fechaFin,
      fechaHoraFirma: data.fechaHoraFirma.present
          ? data.fechaHoraFirma.value
          : this.fechaHoraFirma,
      estado: data.estado.present ? data.estado.value : this.estado,
      tokenConfirmacion: data.tokenConfirmacion.present
          ? data.tokenConfirmacion.value
          : this.tokenConfirmacion,
      tokenExpira: data.tokenExpira.present
          ? data.tokenExpira.value
          : this.tokenExpira,
      confirmadoRecibidoAt: data.confirmadoRecibidoAt.present
          ? data.confirmadoRecibidoAt.value
          : this.confirmadoRecibidoAt,
      reagendadaVeces: data.reagendadaVeces.present
          ? data.reagendadaVeces.value
          : this.reagendadaVeces,
      motivoUltimaReagenda: data.motivoUltimaReagenda.present
          ? data.motivoUltimaReagenda.value
          : this.motivoUltimaReagenda,
      categoriaMotivoReagenda: data.categoriaMotivoReagenda.present
          ? data.categoriaMotivoReagenda.value
          : this.categoriaMotivoReagenda,
      postMortemPresentado: data.postMortemPresentado.present
          ? data.postMortemPresentado.value
          : this.postMortemPresentado,
      contraloriaPresentada: data.contraloriaPresentada.present
          ? data.contraloriaPresentada.value
          : this.contraloriaPresentada,
      probidadAperturadaAt: data.probidadAperturadaAt.present
          ? data.probidadAperturadaAt.value
          : this.probidadAperturadaAt,
      notas: data.notas.present ? data.notas.value : this.notas,
      creadaPor: data.creadaPor.present ? data.creadaPor.value : this.creadaPor,
      userCreation: data.userCreation.present
          ? data.userCreation.value
          : this.userCreation,
      dateCreation: data.dateCreation.present
          ? data.dateCreation.value
          : this.dateCreation,
      userUpdated: data.userUpdated.present
          ? data.userUpdated.value
          : this.userUpdated,
      dateUpdated: data.dateUpdated.present
          ? data.dateUpdated.value
          : this.dateUpdated,
      isDelete: data.isDelete.present ? data.isDelete.value : this.isDelete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cita(')
          ..write('id: $id, ')
          ..write('uuidPublico: $uuidPublico, ')
          ..write('personaNombre: $personaNombre, ')
          ..write('personaDpi: $personaDpi, ')
          ..write('personaCorreo: $personaCorreo, ')
          ..write('personaTelefono: $personaTelefono, ')
          ..write('numeroContrato: $numeroContrato, ')
          ..write('puesto: $puesto, ')
          ..write('salario: $salario, ')
          ..write('ubicacion: $ubicacion, ')
          ..write('ubicacionEspecifica: $ubicacionEspecifica, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaFin: $fechaFin, ')
          ..write('fechaHoraFirma: $fechaHoraFirma, ')
          ..write('estado: $estado, ')
          ..write('tokenConfirmacion: $tokenConfirmacion, ')
          ..write('tokenExpira: $tokenExpira, ')
          ..write('confirmadoRecibidoAt: $confirmadoRecibidoAt, ')
          ..write('reagendadaVeces: $reagendadaVeces, ')
          ..write('motivoUltimaReagenda: $motivoUltimaReagenda, ')
          ..write('categoriaMotivoReagenda: $categoriaMotivoReagenda, ')
          ..write('postMortemPresentado: $postMortemPresentado, ')
          ..write('contraloriaPresentada: $contraloriaPresentada, ')
          ..write('probidadAperturadaAt: $probidadAperturadaAt, ')
          ..write('notas: $notas, ')
          ..write('creadaPor: $creadaPor, ')
          ..write('userCreation: $userCreation, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('userUpdated: $userUpdated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('isDelete: $isDelete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    uuidPublico,
    personaNombre,
    personaDpi,
    personaCorreo,
    personaTelefono,
    numeroContrato,
    puesto,
    salario,
    ubicacion,
    ubicacionEspecifica,
    fechaInicio,
    fechaFin,
    fechaHoraFirma,
    estado,
    tokenConfirmacion,
    tokenExpira,
    confirmadoRecibidoAt,
    reagendadaVeces,
    motivoUltimaReagenda,
    categoriaMotivoReagenda,
    postMortemPresentado,
    contraloriaPresentada,
    probidadAperturadaAt,
    notas,
    creadaPor,
    userCreation,
    dateCreation,
    userUpdated,
    dateUpdated,
    isDelete,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cita &&
          other.id == this.id &&
          other.uuidPublico == this.uuidPublico &&
          other.personaNombre == this.personaNombre &&
          other.personaDpi == this.personaDpi &&
          other.personaCorreo == this.personaCorreo &&
          other.personaTelefono == this.personaTelefono &&
          other.numeroContrato == this.numeroContrato &&
          other.puesto == this.puesto &&
          other.salario == this.salario &&
          other.ubicacion == this.ubicacion &&
          other.ubicacionEspecifica == this.ubicacionEspecifica &&
          other.fechaInicio == this.fechaInicio &&
          other.fechaFin == this.fechaFin &&
          other.fechaHoraFirma == this.fechaHoraFirma &&
          other.estado == this.estado &&
          other.tokenConfirmacion == this.tokenConfirmacion &&
          other.tokenExpira == this.tokenExpira &&
          other.confirmadoRecibidoAt == this.confirmadoRecibidoAt &&
          other.reagendadaVeces == this.reagendadaVeces &&
          other.motivoUltimaReagenda == this.motivoUltimaReagenda &&
          other.categoriaMotivoReagenda == this.categoriaMotivoReagenda &&
          other.postMortemPresentado == this.postMortemPresentado &&
          other.contraloriaPresentada == this.contraloriaPresentada &&
          other.probidadAperturadaAt == this.probidadAperturadaAt &&
          other.notas == this.notas &&
          other.creadaPor == this.creadaPor &&
          other.userCreation == this.userCreation &&
          other.dateCreation == this.dateCreation &&
          other.userUpdated == this.userUpdated &&
          other.dateUpdated == this.dateUpdated &&
          other.isDelete == this.isDelete);
}

class CitasCompanion extends UpdateCompanion<Cita> {
  final Value<int> id;
  final Value<String> uuidPublico;
  final Value<String> personaNombre;
  final Value<String?> personaDpi;
  final Value<String> personaCorreo;
  final Value<String?> personaTelefono;
  final Value<String?> numeroContrato;
  final Value<String?> puesto;
  final Value<String?> salario;
  final Value<String?> ubicacion;
  final Value<String?> ubicacionEspecifica;
  final Value<String?> fechaInicio;
  final Value<String?> fechaFin;
  final Value<int> fechaHoraFirma;
  final Value<String> estado;
  final Value<String?> tokenConfirmacion;
  final Value<int?> tokenExpira;
  final Value<int?> confirmadoRecibidoAt;
  final Value<int> reagendadaVeces;
  final Value<String?> motivoUltimaReagenda;
  final Value<String?> categoriaMotivoReagenda;
  final Value<bool> postMortemPresentado;
  final Value<bool> contraloriaPresentada;
  final Value<int?> probidadAperturadaAt;
  final Value<String?> notas;
  final Value<int> creadaPor;
  final Value<int?> userCreation;
  final Value<int?> dateCreation;
  final Value<int?> userUpdated;
  final Value<int?> dateUpdated;
  final Value<bool> isDelete;
  const CitasCompanion({
    this.id = const Value.absent(),
    this.uuidPublico = const Value.absent(),
    this.personaNombre = const Value.absent(),
    this.personaDpi = const Value.absent(),
    this.personaCorreo = const Value.absent(),
    this.personaTelefono = const Value.absent(),
    this.numeroContrato = const Value.absent(),
    this.puesto = const Value.absent(),
    this.salario = const Value.absent(),
    this.ubicacion = const Value.absent(),
    this.ubicacionEspecifica = const Value.absent(),
    this.fechaInicio = const Value.absent(),
    this.fechaFin = const Value.absent(),
    this.fechaHoraFirma = const Value.absent(),
    this.estado = const Value.absent(),
    this.tokenConfirmacion = const Value.absent(),
    this.tokenExpira = const Value.absent(),
    this.confirmadoRecibidoAt = const Value.absent(),
    this.reagendadaVeces = const Value.absent(),
    this.motivoUltimaReagenda = const Value.absent(),
    this.categoriaMotivoReagenda = const Value.absent(),
    this.postMortemPresentado = const Value.absent(),
    this.contraloriaPresentada = const Value.absent(),
    this.probidadAperturadaAt = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadaPor = const Value.absent(),
    this.userCreation = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.userUpdated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.isDelete = const Value.absent(),
  });
  CitasCompanion.insert({
    this.id = const Value.absent(),
    required String uuidPublico,
    required String personaNombre,
    this.personaDpi = const Value.absent(),
    required String personaCorreo,
    this.personaTelefono = const Value.absent(),
    this.numeroContrato = const Value.absent(),
    this.puesto = const Value.absent(),
    this.salario = const Value.absent(),
    this.ubicacion = const Value.absent(),
    this.ubicacionEspecifica = const Value.absent(),
    this.fechaInicio = const Value.absent(),
    this.fechaFin = const Value.absent(),
    required int fechaHoraFirma,
    this.estado = const Value.absent(),
    this.tokenConfirmacion = const Value.absent(),
    this.tokenExpira = const Value.absent(),
    this.confirmadoRecibidoAt = const Value.absent(),
    this.reagendadaVeces = const Value.absent(),
    this.motivoUltimaReagenda = const Value.absent(),
    this.categoriaMotivoReagenda = const Value.absent(),
    this.postMortemPresentado = const Value.absent(),
    this.contraloriaPresentada = const Value.absent(),
    this.probidadAperturadaAt = const Value.absent(),
    this.notas = const Value.absent(),
    required int creadaPor,
    this.userCreation = const Value.absent(),
    this.dateCreation = const Value.absent(),
    this.userUpdated = const Value.absent(),
    this.dateUpdated = const Value.absent(),
    this.isDelete = const Value.absent(),
  }) : uuidPublico = Value(uuidPublico),
       personaNombre = Value(personaNombre),
       personaCorreo = Value(personaCorreo),
       fechaHoraFirma = Value(fechaHoraFirma),
       creadaPor = Value(creadaPor);
  static Insertable<Cita> custom({
    Expression<int>? id,
    Expression<String>? uuidPublico,
    Expression<String>? personaNombre,
    Expression<String>? personaDpi,
    Expression<String>? personaCorreo,
    Expression<String>? personaTelefono,
    Expression<String>? numeroContrato,
    Expression<String>? puesto,
    Expression<String>? salario,
    Expression<String>? ubicacion,
    Expression<String>? ubicacionEspecifica,
    Expression<String>? fechaInicio,
    Expression<String>? fechaFin,
    Expression<int>? fechaHoraFirma,
    Expression<String>? estado,
    Expression<String>? tokenConfirmacion,
    Expression<int>? tokenExpira,
    Expression<int>? confirmadoRecibidoAt,
    Expression<int>? reagendadaVeces,
    Expression<String>? motivoUltimaReagenda,
    Expression<String>? categoriaMotivoReagenda,
    Expression<bool>? postMortemPresentado,
    Expression<bool>? contraloriaPresentada,
    Expression<int>? probidadAperturadaAt,
    Expression<String>? notas,
    Expression<int>? creadaPor,
    Expression<int>? userCreation,
    Expression<int>? dateCreation,
    Expression<int>? userUpdated,
    Expression<int>? dateUpdated,
    Expression<bool>? isDelete,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuidPublico != null) 'uuid_publico': uuidPublico,
      if (personaNombre != null) 'persona_nombre': personaNombre,
      if (personaDpi != null) 'persona_dpi': personaDpi,
      if (personaCorreo != null) 'persona_correo': personaCorreo,
      if (personaTelefono != null) 'persona_telefono': personaTelefono,
      if (numeroContrato != null) 'numero_contrato': numeroContrato,
      if (puesto != null) 'puesto': puesto,
      if (salario != null) 'salario': salario,
      if (ubicacion != null) 'ubicacion': ubicacion,
      if (ubicacionEspecifica != null)
        'ubicacion_especifica': ubicacionEspecifica,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio,
      if (fechaFin != null) 'fecha_fin': fechaFin,
      if (fechaHoraFirma != null) 'fecha_hora_firma': fechaHoraFirma,
      if (estado != null) 'estado': estado,
      if (tokenConfirmacion != null) 'token_confirmacion': tokenConfirmacion,
      if (tokenExpira != null) 'token_expira': tokenExpira,
      if (confirmadoRecibidoAt != null)
        'confirmado_recibido_at': confirmadoRecibidoAt,
      if (reagendadaVeces != null) 'reagendada_veces': reagendadaVeces,
      if (motivoUltimaReagenda != null)
        'motivo_ultima_reagenda': motivoUltimaReagenda,
      if (categoriaMotivoReagenda != null)
        'categoria_motivo_reagenda': categoriaMotivoReagenda,
      if (postMortemPresentado != null)
        'post_mortem_presentado': postMortemPresentado,
      if (contraloriaPresentada != null)
        'contraloria_presentada': contraloriaPresentada,
      if (probidadAperturadaAt != null)
        'probidad_aperturada_at': probidadAperturadaAt,
      if (notas != null) 'notas': notas,
      if (creadaPor != null) 'creada_por': creadaPor,
      if (userCreation != null) 'user_creation': userCreation,
      if (dateCreation != null) 'date_creation': dateCreation,
      if (userUpdated != null) 'user_updated': userUpdated,
      if (dateUpdated != null) 'date_updated': dateUpdated,
      if (isDelete != null) 'is_delete': isDelete,
    });
  }

  CitasCompanion copyWith({
    Value<int>? id,
    Value<String>? uuidPublico,
    Value<String>? personaNombre,
    Value<String?>? personaDpi,
    Value<String>? personaCorreo,
    Value<String?>? personaTelefono,
    Value<String?>? numeroContrato,
    Value<String?>? puesto,
    Value<String?>? salario,
    Value<String?>? ubicacion,
    Value<String?>? ubicacionEspecifica,
    Value<String?>? fechaInicio,
    Value<String?>? fechaFin,
    Value<int>? fechaHoraFirma,
    Value<String>? estado,
    Value<String?>? tokenConfirmacion,
    Value<int?>? tokenExpira,
    Value<int?>? confirmadoRecibidoAt,
    Value<int>? reagendadaVeces,
    Value<String?>? motivoUltimaReagenda,
    Value<String?>? categoriaMotivoReagenda,
    Value<bool>? postMortemPresentado,
    Value<bool>? contraloriaPresentada,
    Value<int?>? probidadAperturadaAt,
    Value<String?>? notas,
    Value<int>? creadaPor,
    Value<int?>? userCreation,
    Value<int?>? dateCreation,
    Value<int?>? userUpdated,
    Value<int?>? dateUpdated,
    Value<bool>? isDelete,
  }) {
    return CitasCompanion(
      id: id ?? this.id,
      uuidPublico: uuidPublico ?? this.uuidPublico,
      personaNombre: personaNombre ?? this.personaNombre,
      personaDpi: personaDpi ?? this.personaDpi,
      personaCorreo: personaCorreo ?? this.personaCorreo,
      personaTelefono: personaTelefono ?? this.personaTelefono,
      numeroContrato: numeroContrato ?? this.numeroContrato,
      puesto: puesto ?? this.puesto,
      salario: salario ?? this.salario,
      ubicacion: ubicacion ?? this.ubicacion,
      ubicacionEspecifica: ubicacionEspecifica ?? this.ubicacionEspecifica,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      fechaHoraFirma: fechaHoraFirma ?? this.fechaHoraFirma,
      estado: estado ?? this.estado,
      tokenConfirmacion: tokenConfirmacion ?? this.tokenConfirmacion,
      tokenExpira: tokenExpira ?? this.tokenExpira,
      confirmadoRecibidoAt: confirmadoRecibidoAt ?? this.confirmadoRecibidoAt,
      reagendadaVeces: reagendadaVeces ?? this.reagendadaVeces,
      motivoUltimaReagenda: motivoUltimaReagenda ?? this.motivoUltimaReagenda,
      categoriaMotivoReagenda:
          categoriaMotivoReagenda ?? this.categoriaMotivoReagenda,
      postMortemPresentado: postMortemPresentado ?? this.postMortemPresentado,
      contraloriaPresentada:
          contraloriaPresentada ?? this.contraloriaPresentada,
      probidadAperturadaAt: probidadAperturadaAt ?? this.probidadAperturadaAt,
      notas: notas ?? this.notas,
      creadaPor: creadaPor ?? this.creadaPor,
      userCreation: userCreation ?? this.userCreation,
      dateCreation: dateCreation ?? this.dateCreation,
      userUpdated: userUpdated ?? this.userUpdated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      isDelete: isDelete ?? this.isDelete,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuidPublico.present) {
      map['uuid_publico'] = Variable<String>(uuidPublico.value);
    }
    if (personaNombre.present) {
      map['persona_nombre'] = Variable<String>(personaNombre.value);
    }
    if (personaDpi.present) {
      map['persona_dpi'] = Variable<String>(personaDpi.value);
    }
    if (personaCorreo.present) {
      map['persona_correo'] = Variable<String>(personaCorreo.value);
    }
    if (personaTelefono.present) {
      map['persona_telefono'] = Variable<String>(personaTelefono.value);
    }
    if (numeroContrato.present) {
      map['numero_contrato'] = Variable<String>(numeroContrato.value);
    }
    if (puesto.present) {
      map['puesto'] = Variable<String>(puesto.value);
    }
    if (salario.present) {
      map['salario'] = Variable<String>(salario.value);
    }
    if (ubicacion.present) {
      map['ubicacion'] = Variable<String>(ubicacion.value);
    }
    if (ubicacionEspecifica.present) {
      map['ubicacion_especifica'] = Variable<String>(ubicacionEspecifica.value);
    }
    if (fechaInicio.present) {
      map['fecha_inicio'] = Variable<String>(fechaInicio.value);
    }
    if (fechaFin.present) {
      map['fecha_fin'] = Variable<String>(fechaFin.value);
    }
    if (fechaHoraFirma.present) {
      map['fecha_hora_firma'] = Variable<int>(fechaHoraFirma.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (tokenConfirmacion.present) {
      map['token_confirmacion'] = Variable<String>(tokenConfirmacion.value);
    }
    if (tokenExpira.present) {
      map['token_expira'] = Variable<int>(tokenExpira.value);
    }
    if (confirmadoRecibidoAt.present) {
      map['confirmado_recibido_at'] = Variable<int>(confirmadoRecibidoAt.value);
    }
    if (reagendadaVeces.present) {
      map['reagendada_veces'] = Variable<int>(reagendadaVeces.value);
    }
    if (motivoUltimaReagenda.present) {
      map['motivo_ultima_reagenda'] = Variable<String>(
        motivoUltimaReagenda.value,
      );
    }
    if (categoriaMotivoReagenda.present) {
      map['categoria_motivo_reagenda'] = Variable<String>(
        categoriaMotivoReagenda.value,
      );
    }
    if (postMortemPresentado.present) {
      map['post_mortem_presentado'] = Variable<bool>(
        postMortemPresentado.value,
      );
    }
    if (contraloriaPresentada.present) {
      map['contraloria_presentada'] = Variable<bool>(
        contraloriaPresentada.value,
      );
    }
    if (probidadAperturadaAt.present) {
      map['probidad_aperturada_at'] = Variable<int>(probidadAperturadaAt.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (creadaPor.present) {
      map['creada_por'] = Variable<int>(creadaPor.value);
    }
    if (userCreation.present) {
      map['user_creation'] = Variable<int>(userCreation.value);
    }
    if (dateCreation.present) {
      map['date_creation'] = Variable<int>(dateCreation.value);
    }
    if (userUpdated.present) {
      map['user_updated'] = Variable<int>(userUpdated.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<int>(dateUpdated.value);
    }
    if (isDelete.present) {
      map['is_delete'] = Variable<bool>(isDelete.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CitasCompanion(')
          ..write('id: $id, ')
          ..write('uuidPublico: $uuidPublico, ')
          ..write('personaNombre: $personaNombre, ')
          ..write('personaDpi: $personaDpi, ')
          ..write('personaCorreo: $personaCorreo, ')
          ..write('personaTelefono: $personaTelefono, ')
          ..write('numeroContrato: $numeroContrato, ')
          ..write('puesto: $puesto, ')
          ..write('salario: $salario, ')
          ..write('ubicacion: $ubicacion, ')
          ..write('ubicacionEspecifica: $ubicacionEspecifica, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaFin: $fechaFin, ')
          ..write('fechaHoraFirma: $fechaHoraFirma, ')
          ..write('estado: $estado, ')
          ..write('tokenConfirmacion: $tokenConfirmacion, ')
          ..write('tokenExpira: $tokenExpira, ')
          ..write('confirmadoRecibidoAt: $confirmadoRecibidoAt, ')
          ..write('reagendadaVeces: $reagendadaVeces, ')
          ..write('motivoUltimaReagenda: $motivoUltimaReagenda, ')
          ..write('categoriaMotivoReagenda: $categoriaMotivoReagenda, ')
          ..write('postMortemPresentado: $postMortemPresentado, ')
          ..write('contraloriaPresentada: $contraloriaPresentada, ')
          ..write('probidadAperturadaAt: $probidadAperturadaAt, ')
          ..write('notas: $notas, ')
          ..write('creadaPor: $creadaPor, ')
          ..write('userCreation: $userCreation, ')
          ..write('dateCreation: $dateCreation, ')
          ..write('userUpdated: $userUpdated, ')
          ..write('dateUpdated: $dateUpdated, ')
          ..write('isDelete: $isDelete')
          ..write(')'))
        .toString();
  }
}

class $DocumentosTable extends Documentos
    with TableInfo<$DocumentosTable, Documento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _citaIdMeta = const VerificationMeta('citaId');
  @override
  late final GeneratedColumn<int> citaId = GeneratedColumn<int>(
    'cita_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES citas (id)',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rutaArchivoMeta = const VerificationMeta(
    'rutaArchivo',
  );
  @override
  late final GeneratedColumn<String> rutaArchivo = GeneratedColumn<String>(
    'ruta_archivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashSha256Meta = const VerificationMeta(
    'hashSha256',
  );
  @override
  late final GeneratedColumn<String> hashSha256 = GeneratedColumn<String>(
    'hash_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tamanoBytesMeta = const VerificationMeta(
    'tamanoBytes',
  );
  @override
  late final GeneratedColumn<int> tamanoBytes = GeneratedColumn<int>(
    'tamano_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subidoPorMeta = const VerificationMeta(
    'subidoPor',
  );
  @override
  late final GeneratedColumn<int> subidoPor = GeneratedColumn<int>(
    'subido_por',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _subidoAtMeta = const VerificationMeta(
    'subidoAt',
  );
  @override
  late final GeneratedColumn<int> subidoAt = GeneratedColumn<int>(
    'subido_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeleteMeta = const VerificationMeta(
    'isDelete',
  );
  @override
  late final GeneratedColumn<bool> isDelete = GeneratedColumn<bool>(
    'is_delete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_delete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    citaId,
    tipo,
    nombre,
    rutaArchivo,
    hashSha256,
    mimeType,
    tamanoBytes,
    subidoPor,
    subidoAt,
    isDelete,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Documento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cita_id')) {
      context.handle(
        _citaIdMeta,
        citaId.isAcceptableOrUnknown(data['cita_id']!, _citaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_citaIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('ruta_archivo')) {
      context.handle(
        _rutaArchivoMeta,
        rutaArchivo.isAcceptableOrUnknown(
          data['ruta_archivo']!,
          _rutaArchivoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rutaArchivoMeta);
    }
    if (data.containsKey('hash_sha256')) {
      context.handle(
        _hashSha256Meta,
        hashSha256.isAcceptableOrUnknown(data['hash_sha256']!, _hashSha256Meta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('tamano_bytes')) {
      context.handle(
        _tamanoBytesMeta,
        tamanoBytes.isAcceptableOrUnknown(
          data['tamano_bytes']!,
          _tamanoBytesMeta,
        ),
      );
    }
    if (data.containsKey('subido_por')) {
      context.handle(
        _subidoPorMeta,
        subidoPor.isAcceptableOrUnknown(data['subido_por']!, _subidoPorMeta),
      );
    } else if (isInserting) {
      context.missing(_subidoPorMeta);
    }
    if (data.containsKey('subido_at')) {
      context.handle(
        _subidoAtMeta,
        subidoAt.isAcceptableOrUnknown(data['subido_at']!, _subidoAtMeta),
      );
    } else if (isInserting) {
      context.missing(_subidoAtMeta);
    }
    if (data.containsKey('is_delete')) {
      context.handle(
        _isDeleteMeta,
        isDelete.isAcceptableOrUnknown(data['is_delete']!, _isDeleteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Documento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Documento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      citaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cita_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      rutaArchivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruta_archivo'],
      )!,
      hashSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash_sha256'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      tamanoBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tamano_bytes'],
      ),
      subidoPor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subido_por'],
      )!,
      subidoAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subido_at'],
      )!,
      isDelete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_delete'],
      )!,
    );
  }

  @override
  $DocumentosTable createAlias(String alias) {
    return $DocumentosTable(attachedDatabase, alias);
  }
}

class Documento extends DataClass implements Insertable<Documento> {
  final int id;
  final int citaId;
  final String tipo;
  final String nombre;
  final String rutaArchivo;
  final String? hashSha256;
  final String? mimeType;
  final int? tamanoBytes;
  final int subidoPor;
  final int subidoAt;
  final bool isDelete;
  const Documento({
    required this.id,
    required this.citaId,
    required this.tipo,
    required this.nombre,
    required this.rutaArchivo,
    this.hashSha256,
    this.mimeType,
    this.tamanoBytes,
    required this.subidoPor,
    required this.subidoAt,
    required this.isDelete,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cita_id'] = Variable<int>(citaId);
    map['tipo'] = Variable<String>(tipo);
    map['nombre'] = Variable<String>(nombre);
    map['ruta_archivo'] = Variable<String>(rutaArchivo);
    if (!nullToAbsent || hashSha256 != null) {
      map['hash_sha256'] = Variable<String>(hashSha256);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || tamanoBytes != null) {
      map['tamano_bytes'] = Variable<int>(tamanoBytes);
    }
    map['subido_por'] = Variable<int>(subidoPor);
    map['subido_at'] = Variable<int>(subidoAt);
    map['is_delete'] = Variable<bool>(isDelete);
    return map;
  }

  DocumentosCompanion toCompanion(bool nullToAbsent) {
    return DocumentosCompanion(
      id: Value(id),
      citaId: Value(citaId),
      tipo: Value(tipo),
      nombre: Value(nombre),
      rutaArchivo: Value(rutaArchivo),
      hashSha256: hashSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(hashSha256),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      tamanoBytes: tamanoBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(tamanoBytes),
      subidoPor: Value(subidoPor),
      subidoAt: Value(subidoAt),
      isDelete: Value(isDelete),
    );
  }

  factory Documento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Documento(
      id: serializer.fromJson<int>(json['id']),
      citaId: serializer.fromJson<int>(json['citaId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      rutaArchivo: serializer.fromJson<String>(json['rutaArchivo']),
      hashSha256: serializer.fromJson<String?>(json['hashSha256']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      tamanoBytes: serializer.fromJson<int?>(json['tamanoBytes']),
      subidoPor: serializer.fromJson<int>(json['subidoPor']),
      subidoAt: serializer.fromJson<int>(json['subidoAt']),
      isDelete: serializer.fromJson<bool>(json['isDelete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'citaId': serializer.toJson<int>(citaId),
      'tipo': serializer.toJson<String>(tipo),
      'nombre': serializer.toJson<String>(nombre),
      'rutaArchivo': serializer.toJson<String>(rutaArchivo),
      'hashSha256': serializer.toJson<String?>(hashSha256),
      'mimeType': serializer.toJson<String?>(mimeType),
      'tamanoBytes': serializer.toJson<int?>(tamanoBytes),
      'subidoPor': serializer.toJson<int>(subidoPor),
      'subidoAt': serializer.toJson<int>(subidoAt),
      'isDelete': serializer.toJson<bool>(isDelete),
    };
  }

  Documento copyWith({
    int? id,
    int? citaId,
    String? tipo,
    String? nombre,
    String? rutaArchivo,
    Value<String?> hashSha256 = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    Value<int?> tamanoBytes = const Value.absent(),
    int? subidoPor,
    int? subidoAt,
    bool? isDelete,
  }) => Documento(
    id: id ?? this.id,
    citaId: citaId ?? this.citaId,
    tipo: tipo ?? this.tipo,
    nombre: nombre ?? this.nombre,
    rutaArchivo: rutaArchivo ?? this.rutaArchivo,
    hashSha256: hashSha256.present ? hashSha256.value : this.hashSha256,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    tamanoBytes: tamanoBytes.present ? tamanoBytes.value : this.tamanoBytes,
    subidoPor: subidoPor ?? this.subidoPor,
    subidoAt: subidoAt ?? this.subidoAt,
    isDelete: isDelete ?? this.isDelete,
  );
  Documento copyWithCompanion(DocumentosCompanion data) {
    return Documento(
      id: data.id.present ? data.id.value : this.id,
      citaId: data.citaId.present ? data.citaId.value : this.citaId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      rutaArchivo: data.rutaArchivo.present
          ? data.rutaArchivo.value
          : this.rutaArchivo,
      hashSha256: data.hashSha256.present
          ? data.hashSha256.value
          : this.hashSha256,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      tamanoBytes: data.tamanoBytes.present
          ? data.tamanoBytes.value
          : this.tamanoBytes,
      subidoPor: data.subidoPor.present ? data.subidoPor.value : this.subidoPor,
      subidoAt: data.subidoAt.present ? data.subidoAt.value : this.subidoAt,
      isDelete: data.isDelete.present ? data.isDelete.value : this.isDelete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Documento(')
          ..write('id: $id, ')
          ..write('citaId: $citaId, ')
          ..write('tipo: $tipo, ')
          ..write('nombre: $nombre, ')
          ..write('rutaArchivo: $rutaArchivo, ')
          ..write('hashSha256: $hashSha256, ')
          ..write('mimeType: $mimeType, ')
          ..write('tamanoBytes: $tamanoBytes, ')
          ..write('subidoPor: $subidoPor, ')
          ..write('subidoAt: $subidoAt, ')
          ..write('isDelete: $isDelete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    citaId,
    tipo,
    nombre,
    rutaArchivo,
    hashSha256,
    mimeType,
    tamanoBytes,
    subidoPor,
    subidoAt,
    isDelete,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Documento &&
          other.id == this.id &&
          other.citaId == this.citaId &&
          other.tipo == this.tipo &&
          other.nombre == this.nombre &&
          other.rutaArchivo == this.rutaArchivo &&
          other.hashSha256 == this.hashSha256 &&
          other.mimeType == this.mimeType &&
          other.tamanoBytes == this.tamanoBytes &&
          other.subidoPor == this.subidoPor &&
          other.subidoAt == this.subidoAt &&
          other.isDelete == this.isDelete);
}

class DocumentosCompanion extends UpdateCompanion<Documento> {
  final Value<int> id;
  final Value<int> citaId;
  final Value<String> tipo;
  final Value<String> nombre;
  final Value<String> rutaArchivo;
  final Value<String?> hashSha256;
  final Value<String?> mimeType;
  final Value<int?> tamanoBytes;
  final Value<int> subidoPor;
  final Value<int> subidoAt;
  final Value<bool> isDelete;
  const DocumentosCompanion({
    this.id = const Value.absent(),
    this.citaId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.rutaArchivo = const Value.absent(),
    this.hashSha256 = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.tamanoBytes = const Value.absent(),
    this.subidoPor = const Value.absent(),
    this.subidoAt = const Value.absent(),
    this.isDelete = const Value.absent(),
  });
  DocumentosCompanion.insert({
    this.id = const Value.absent(),
    required int citaId,
    required String tipo,
    required String nombre,
    required String rutaArchivo,
    this.hashSha256 = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.tamanoBytes = const Value.absent(),
    required int subidoPor,
    required int subidoAt,
    this.isDelete = const Value.absent(),
  }) : citaId = Value(citaId),
       tipo = Value(tipo),
       nombre = Value(nombre),
       rutaArchivo = Value(rutaArchivo),
       subidoPor = Value(subidoPor),
       subidoAt = Value(subidoAt);
  static Insertable<Documento> custom({
    Expression<int>? id,
    Expression<int>? citaId,
    Expression<String>? tipo,
    Expression<String>? nombre,
    Expression<String>? rutaArchivo,
    Expression<String>? hashSha256,
    Expression<String>? mimeType,
    Expression<int>? tamanoBytes,
    Expression<int>? subidoPor,
    Expression<int>? subidoAt,
    Expression<bool>? isDelete,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (citaId != null) 'cita_id': citaId,
      if (tipo != null) 'tipo': tipo,
      if (nombre != null) 'nombre': nombre,
      if (rutaArchivo != null) 'ruta_archivo': rutaArchivo,
      if (hashSha256 != null) 'hash_sha256': hashSha256,
      if (mimeType != null) 'mime_type': mimeType,
      if (tamanoBytes != null) 'tamano_bytes': tamanoBytes,
      if (subidoPor != null) 'subido_por': subidoPor,
      if (subidoAt != null) 'subido_at': subidoAt,
      if (isDelete != null) 'is_delete': isDelete,
    });
  }

  DocumentosCompanion copyWith({
    Value<int>? id,
    Value<int>? citaId,
    Value<String>? tipo,
    Value<String>? nombre,
    Value<String>? rutaArchivo,
    Value<String?>? hashSha256,
    Value<String?>? mimeType,
    Value<int?>? tamanoBytes,
    Value<int>? subidoPor,
    Value<int>? subidoAt,
    Value<bool>? isDelete,
  }) {
    return DocumentosCompanion(
      id: id ?? this.id,
      citaId: citaId ?? this.citaId,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      rutaArchivo: rutaArchivo ?? this.rutaArchivo,
      hashSha256: hashSha256 ?? this.hashSha256,
      mimeType: mimeType ?? this.mimeType,
      tamanoBytes: tamanoBytes ?? this.tamanoBytes,
      subidoPor: subidoPor ?? this.subidoPor,
      subidoAt: subidoAt ?? this.subidoAt,
      isDelete: isDelete ?? this.isDelete,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (citaId.present) {
      map['cita_id'] = Variable<int>(citaId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (rutaArchivo.present) {
      map['ruta_archivo'] = Variable<String>(rutaArchivo.value);
    }
    if (hashSha256.present) {
      map['hash_sha256'] = Variable<String>(hashSha256.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (tamanoBytes.present) {
      map['tamano_bytes'] = Variable<int>(tamanoBytes.value);
    }
    if (subidoPor.present) {
      map['subido_por'] = Variable<int>(subidoPor.value);
    }
    if (subidoAt.present) {
      map['subido_at'] = Variable<int>(subidoAt.value);
    }
    if (isDelete.present) {
      map['is_delete'] = Variable<bool>(isDelete.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentosCompanion(')
          ..write('id: $id, ')
          ..write('citaId: $citaId, ')
          ..write('tipo: $tipo, ')
          ..write('nombre: $nombre, ')
          ..write('rutaArchivo: $rutaArchivo, ')
          ..write('hashSha256: $hashSha256, ')
          ..write('mimeType: $mimeType, ')
          ..write('tamanoBytes: $tamanoBytes, ')
          ..write('subidoPor: $subidoPor, ')
          ..write('subidoAt: $subidoAt, ')
          ..write('isDelete: $isDelete')
          ..write(')'))
        .toString();
  }
}

class $CorreosLogTable extends CorreosLog
    with TableInfo<$CorreosLogTable, CorreosLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CorreosLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _citaIdMeta = const VerificationMeta('citaId');
  @override
  late final GeneratedColumn<int> citaId = GeneratedColumn<int>(
    'cita_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES citas (id)',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinatarioMeta = const VerificationMeta(
    'destinatario',
  );
  @override
  late final GeneratedColumn<String> destinatario = GeneratedColumn<String>(
    'destinatario',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ccMeta = const VerificationMeta('cc');
  @override
  late final GeneratedColumn<String> cc = GeneratedColumn<String>(
    'cc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _asuntoMeta = const VerificationMeta('asunto');
  @override
  late final GeneratedColumn<String> asunto = GeneratedColumn<String>(
    'asunto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuerpoHtmlMeta = const VerificationMeta(
    'cuerpoHtml',
  );
  @override
  late final GeneratedColumn<String> cuerpoHtml = GeneratedColumn<String>(
    'cuerpo_html',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adjuntosJsonMeta = const VerificationMeta(
    'adjuntosJson',
  );
  @override
  late final GeneratedColumn<String> adjuntosJson = GeneratedColumn<String>(
    'adjuntos_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pendiente'),
  );
  static const VerificationMeta _intentosMeta = const VerificationMeta(
    'intentos',
  );
  @override
  late final GeneratedColumn<int> intentos = GeneratedColumn<int>(
    'intentos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _proximoIntentoAtMeta = const VerificationMeta(
    'proximoIntentoAt',
  );
  @override
  late final GeneratedColumn<int> proximoIntentoAt = GeneratedColumn<int>(
    'proximo_intento_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMensajeMeta = const VerificationMeta(
    'errorMensaje',
  );
  @override
  late final GeneratedColumn<String> errorMensaje = GeneratedColumn<String>(
    'error_mensaje',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _programadoAtMeta = const VerificationMeta(
    'programadoAt',
  );
  @override
  late final GeneratedColumn<int> programadoAt = GeneratedColumn<int>(
    'programado_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enviadoAtMeta = const VerificationMeta(
    'enviadoAt',
  );
  @override
  late final GeneratedColumn<int> enviadoAt = GeneratedColumn<int>(
    'enviado_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    citaId,
    tipo,
    destinatario,
    cc,
    asunto,
    cuerpoHtml,
    adjuntosJson,
    estado,
    intentos,
    proximoIntentoAt,
    errorMensaje,
    programadoAt,
    enviadoAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'correos_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<CorreosLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cita_id')) {
      context.handle(
        _citaIdMeta,
        citaId.isAcceptableOrUnknown(data['cita_id']!, _citaIdMeta),
      );
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('destinatario')) {
      context.handle(
        _destinatarioMeta,
        destinatario.isAcceptableOrUnknown(
          data['destinatario']!,
          _destinatarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinatarioMeta);
    }
    if (data.containsKey('cc')) {
      context.handle(_ccMeta, cc.isAcceptableOrUnknown(data['cc']!, _ccMeta));
    }
    if (data.containsKey('asunto')) {
      context.handle(
        _asuntoMeta,
        asunto.isAcceptableOrUnknown(data['asunto']!, _asuntoMeta),
      );
    } else if (isInserting) {
      context.missing(_asuntoMeta);
    }
    if (data.containsKey('cuerpo_html')) {
      context.handle(
        _cuerpoHtmlMeta,
        cuerpoHtml.isAcceptableOrUnknown(data['cuerpo_html']!, _cuerpoHtmlMeta),
      );
    }
    if (data.containsKey('adjuntos_json')) {
      context.handle(
        _adjuntosJsonMeta,
        adjuntosJson.isAcceptableOrUnknown(
          data['adjuntos_json']!,
          _adjuntosJsonMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('intentos')) {
      context.handle(
        _intentosMeta,
        intentos.isAcceptableOrUnknown(data['intentos']!, _intentosMeta),
      );
    }
    if (data.containsKey('proximo_intento_at')) {
      context.handle(
        _proximoIntentoAtMeta,
        proximoIntentoAt.isAcceptableOrUnknown(
          data['proximo_intento_at']!,
          _proximoIntentoAtMeta,
        ),
      );
    }
    if (data.containsKey('error_mensaje')) {
      context.handle(
        _errorMensajeMeta,
        errorMensaje.isAcceptableOrUnknown(
          data['error_mensaje']!,
          _errorMensajeMeta,
        ),
      );
    }
    if (data.containsKey('programado_at')) {
      context.handle(
        _programadoAtMeta,
        programadoAt.isAcceptableOrUnknown(
          data['programado_at']!,
          _programadoAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_programadoAtMeta);
    }
    if (data.containsKey('enviado_at')) {
      context.handle(
        _enviadoAtMeta,
        enviadoAt.isAcceptableOrUnknown(data['enviado_at']!, _enviadoAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CorreosLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CorreosLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      citaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cita_id'],
      ),
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      destinatario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destinatario'],
      )!,
      cc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cc'],
      ),
      asunto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asunto'],
      )!,
      cuerpoHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuerpo_html'],
      ),
      adjuntosJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjuntos_json'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      intentos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intentos'],
      )!,
      proximoIntentoAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}proximo_intento_at'],
      ),
      errorMensaje: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_mensaje'],
      ),
      programadoAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}programado_at'],
      )!,
      enviadoAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enviado_at'],
      ),
    );
  }

  @override
  $CorreosLogTable createAlias(String alias) {
    return $CorreosLogTable(attachedDatabase, alias);
  }
}

class CorreosLogData extends DataClass implements Insertable<CorreosLogData> {
  final int id;
  final int? citaId;
  final String tipo;
  final String destinatario;
  final String? cc;
  final String asunto;
  final String? cuerpoHtml;
  final String? adjuntosJson;
  final String estado;
  final int intentos;
  final int? proximoIntentoAt;
  final String? errorMensaje;
  final int programadoAt;
  final int? enviadoAt;
  const CorreosLogData({
    required this.id,
    this.citaId,
    required this.tipo,
    required this.destinatario,
    this.cc,
    required this.asunto,
    this.cuerpoHtml,
    this.adjuntosJson,
    required this.estado,
    required this.intentos,
    this.proximoIntentoAt,
    this.errorMensaje,
    required this.programadoAt,
    this.enviadoAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || citaId != null) {
      map['cita_id'] = Variable<int>(citaId);
    }
    map['tipo'] = Variable<String>(tipo);
    map['destinatario'] = Variable<String>(destinatario);
    if (!nullToAbsent || cc != null) {
      map['cc'] = Variable<String>(cc);
    }
    map['asunto'] = Variable<String>(asunto);
    if (!nullToAbsent || cuerpoHtml != null) {
      map['cuerpo_html'] = Variable<String>(cuerpoHtml);
    }
    if (!nullToAbsent || adjuntosJson != null) {
      map['adjuntos_json'] = Variable<String>(adjuntosJson);
    }
    map['estado'] = Variable<String>(estado);
    map['intentos'] = Variable<int>(intentos);
    if (!nullToAbsent || proximoIntentoAt != null) {
      map['proximo_intento_at'] = Variable<int>(proximoIntentoAt);
    }
    if (!nullToAbsent || errorMensaje != null) {
      map['error_mensaje'] = Variable<String>(errorMensaje);
    }
    map['programado_at'] = Variable<int>(programadoAt);
    if (!nullToAbsent || enviadoAt != null) {
      map['enviado_at'] = Variable<int>(enviadoAt);
    }
    return map;
  }

  CorreosLogCompanion toCompanion(bool nullToAbsent) {
    return CorreosLogCompanion(
      id: Value(id),
      citaId: citaId == null && nullToAbsent
          ? const Value.absent()
          : Value(citaId),
      tipo: Value(tipo),
      destinatario: Value(destinatario),
      cc: cc == null && nullToAbsent ? const Value.absent() : Value(cc),
      asunto: Value(asunto),
      cuerpoHtml: cuerpoHtml == null && nullToAbsent
          ? const Value.absent()
          : Value(cuerpoHtml),
      adjuntosJson: adjuntosJson == null && nullToAbsent
          ? const Value.absent()
          : Value(adjuntosJson),
      estado: Value(estado),
      intentos: Value(intentos),
      proximoIntentoAt: proximoIntentoAt == null && nullToAbsent
          ? const Value.absent()
          : Value(proximoIntentoAt),
      errorMensaje: errorMensaje == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMensaje),
      programadoAt: Value(programadoAt),
      enviadoAt: enviadoAt == null && nullToAbsent
          ? const Value.absent()
          : Value(enviadoAt),
    );
  }

  factory CorreosLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CorreosLogData(
      id: serializer.fromJson<int>(json['id']),
      citaId: serializer.fromJson<int?>(json['citaId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      destinatario: serializer.fromJson<String>(json['destinatario']),
      cc: serializer.fromJson<String?>(json['cc']),
      asunto: serializer.fromJson<String>(json['asunto']),
      cuerpoHtml: serializer.fromJson<String?>(json['cuerpoHtml']),
      adjuntosJson: serializer.fromJson<String?>(json['adjuntosJson']),
      estado: serializer.fromJson<String>(json['estado']),
      intentos: serializer.fromJson<int>(json['intentos']),
      proximoIntentoAt: serializer.fromJson<int?>(json['proximoIntentoAt']),
      errorMensaje: serializer.fromJson<String?>(json['errorMensaje']),
      programadoAt: serializer.fromJson<int>(json['programadoAt']),
      enviadoAt: serializer.fromJson<int?>(json['enviadoAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'citaId': serializer.toJson<int?>(citaId),
      'tipo': serializer.toJson<String>(tipo),
      'destinatario': serializer.toJson<String>(destinatario),
      'cc': serializer.toJson<String?>(cc),
      'asunto': serializer.toJson<String>(asunto),
      'cuerpoHtml': serializer.toJson<String?>(cuerpoHtml),
      'adjuntosJson': serializer.toJson<String?>(adjuntosJson),
      'estado': serializer.toJson<String>(estado),
      'intentos': serializer.toJson<int>(intentos),
      'proximoIntentoAt': serializer.toJson<int?>(proximoIntentoAt),
      'errorMensaje': serializer.toJson<String?>(errorMensaje),
      'programadoAt': serializer.toJson<int>(programadoAt),
      'enviadoAt': serializer.toJson<int?>(enviadoAt),
    };
  }

  CorreosLogData copyWith({
    int? id,
    Value<int?> citaId = const Value.absent(),
    String? tipo,
    String? destinatario,
    Value<String?> cc = const Value.absent(),
    String? asunto,
    Value<String?> cuerpoHtml = const Value.absent(),
    Value<String?> adjuntosJson = const Value.absent(),
    String? estado,
    int? intentos,
    Value<int?> proximoIntentoAt = const Value.absent(),
    Value<String?> errorMensaje = const Value.absent(),
    int? programadoAt,
    Value<int?> enviadoAt = const Value.absent(),
  }) => CorreosLogData(
    id: id ?? this.id,
    citaId: citaId.present ? citaId.value : this.citaId,
    tipo: tipo ?? this.tipo,
    destinatario: destinatario ?? this.destinatario,
    cc: cc.present ? cc.value : this.cc,
    asunto: asunto ?? this.asunto,
    cuerpoHtml: cuerpoHtml.present ? cuerpoHtml.value : this.cuerpoHtml,
    adjuntosJson: adjuntosJson.present ? adjuntosJson.value : this.adjuntosJson,
    estado: estado ?? this.estado,
    intentos: intentos ?? this.intentos,
    proximoIntentoAt: proximoIntentoAt.present
        ? proximoIntentoAt.value
        : this.proximoIntentoAt,
    errorMensaje: errorMensaje.present ? errorMensaje.value : this.errorMensaje,
    programadoAt: programadoAt ?? this.programadoAt,
    enviadoAt: enviadoAt.present ? enviadoAt.value : this.enviadoAt,
  );
  CorreosLogData copyWithCompanion(CorreosLogCompanion data) {
    return CorreosLogData(
      id: data.id.present ? data.id.value : this.id,
      citaId: data.citaId.present ? data.citaId.value : this.citaId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      destinatario: data.destinatario.present
          ? data.destinatario.value
          : this.destinatario,
      cc: data.cc.present ? data.cc.value : this.cc,
      asunto: data.asunto.present ? data.asunto.value : this.asunto,
      cuerpoHtml: data.cuerpoHtml.present
          ? data.cuerpoHtml.value
          : this.cuerpoHtml,
      adjuntosJson: data.adjuntosJson.present
          ? data.adjuntosJson.value
          : this.adjuntosJson,
      estado: data.estado.present ? data.estado.value : this.estado,
      intentos: data.intentos.present ? data.intentos.value : this.intentos,
      proximoIntentoAt: data.proximoIntentoAt.present
          ? data.proximoIntentoAt.value
          : this.proximoIntentoAt,
      errorMensaje: data.errorMensaje.present
          ? data.errorMensaje.value
          : this.errorMensaje,
      programadoAt: data.programadoAt.present
          ? data.programadoAt.value
          : this.programadoAt,
      enviadoAt: data.enviadoAt.present ? data.enviadoAt.value : this.enviadoAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CorreosLogData(')
          ..write('id: $id, ')
          ..write('citaId: $citaId, ')
          ..write('tipo: $tipo, ')
          ..write('destinatario: $destinatario, ')
          ..write('cc: $cc, ')
          ..write('asunto: $asunto, ')
          ..write('cuerpoHtml: $cuerpoHtml, ')
          ..write('adjuntosJson: $adjuntosJson, ')
          ..write('estado: $estado, ')
          ..write('intentos: $intentos, ')
          ..write('proximoIntentoAt: $proximoIntentoAt, ')
          ..write('errorMensaje: $errorMensaje, ')
          ..write('programadoAt: $programadoAt, ')
          ..write('enviadoAt: $enviadoAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    citaId,
    tipo,
    destinatario,
    cc,
    asunto,
    cuerpoHtml,
    adjuntosJson,
    estado,
    intentos,
    proximoIntentoAt,
    errorMensaje,
    programadoAt,
    enviadoAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CorreosLogData &&
          other.id == this.id &&
          other.citaId == this.citaId &&
          other.tipo == this.tipo &&
          other.destinatario == this.destinatario &&
          other.cc == this.cc &&
          other.asunto == this.asunto &&
          other.cuerpoHtml == this.cuerpoHtml &&
          other.adjuntosJson == this.adjuntosJson &&
          other.estado == this.estado &&
          other.intentos == this.intentos &&
          other.proximoIntentoAt == this.proximoIntentoAt &&
          other.errorMensaje == this.errorMensaje &&
          other.programadoAt == this.programadoAt &&
          other.enviadoAt == this.enviadoAt);
}

class CorreosLogCompanion extends UpdateCompanion<CorreosLogData> {
  final Value<int> id;
  final Value<int?> citaId;
  final Value<String> tipo;
  final Value<String> destinatario;
  final Value<String?> cc;
  final Value<String> asunto;
  final Value<String?> cuerpoHtml;
  final Value<String?> adjuntosJson;
  final Value<String> estado;
  final Value<int> intentos;
  final Value<int?> proximoIntentoAt;
  final Value<String?> errorMensaje;
  final Value<int> programadoAt;
  final Value<int?> enviadoAt;
  const CorreosLogCompanion({
    this.id = const Value.absent(),
    this.citaId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.destinatario = const Value.absent(),
    this.cc = const Value.absent(),
    this.asunto = const Value.absent(),
    this.cuerpoHtml = const Value.absent(),
    this.adjuntosJson = const Value.absent(),
    this.estado = const Value.absent(),
    this.intentos = const Value.absent(),
    this.proximoIntentoAt = const Value.absent(),
    this.errorMensaje = const Value.absent(),
    this.programadoAt = const Value.absent(),
    this.enviadoAt = const Value.absent(),
  });
  CorreosLogCompanion.insert({
    this.id = const Value.absent(),
    this.citaId = const Value.absent(),
    required String tipo,
    required String destinatario,
    this.cc = const Value.absent(),
    required String asunto,
    this.cuerpoHtml = const Value.absent(),
    this.adjuntosJson = const Value.absent(),
    this.estado = const Value.absent(),
    this.intentos = const Value.absent(),
    this.proximoIntentoAt = const Value.absent(),
    this.errorMensaje = const Value.absent(),
    required int programadoAt,
    this.enviadoAt = const Value.absent(),
  }) : tipo = Value(tipo),
       destinatario = Value(destinatario),
       asunto = Value(asunto),
       programadoAt = Value(programadoAt);
  static Insertable<CorreosLogData> custom({
    Expression<int>? id,
    Expression<int>? citaId,
    Expression<String>? tipo,
    Expression<String>? destinatario,
    Expression<String>? cc,
    Expression<String>? asunto,
    Expression<String>? cuerpoHtml,
    Expression<String>? adjuntosJson,
    Expression<String>? estado,
    Expression<int>? intentos,
    Expression<int>? proximoIntentoAt,
    Expression<String>? errorMensaje,
    Expression<int>? programadoAt,
    Expression<int>? enviadoAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (citaId != null) 'cita_id': citaId,
      if (tipo != null) 'tipo': tipo,
      if (destinatario != null) 'destinatario': destinatario,
      if (cc != null) 'cc': cc,
      if (asunto != null) 'asunto': asunto,
      if (cuerpoHtml != null) 'cuerpo_html': cuerpoHtml,
      if (adjuntosJson != null) 'adjuntos_json': adjuntosJson,
      if (estado != null) 'estado': estado,
      if (intentos != null) 'intentos': intentos,
      if (proximoIntentoAt != null) 'proximo_intento_at': proximoIntentoAt,
      if (errorMensaje != null) 'error_mensaje': errorMensaje,
      if (programadoAt != null) 'programado_at': programadoAt,
      if (enviadoAt != null) 'enviado_at': enviadoAt,
    });
  }

  CorreosLogCompanion copyWith({
    Value<int>? id,
    Value<int?>? citaId,
    Value<String>? tipo,
    Value<String>? destinatario,
    Value<String?>? cc,
    Value<String>? asunto,
    Value<String?>? cuerpoHtml,
    Value<String?>? adjuntosJson,
    Value<String>? estado,
    Value<int>? intentos,
    Value<int?>? proximoIntentoAt,
    Value<String?>? errorMensaje,
    Value<int>? programadoAt,
    Value<int?>? enviadoAt,
  }) {
    return CorreosLogCompanion(
      id: id ?? this.id,
      citaId: citaId ?? this.citaId,
      tipo: tipo ?? this.tipo,
      destinatario: destinatario ?? this.destinatario,
      cc: cc ?? this.cc,
      asunto: asunto ?? this.asunto,
      cuerpoHtml: cuerpoHtml ?? this.cuerpoHtml,
      adjuntosJson: adjuntosJson ?? this.adjuntosJson,
      estado: estado ?? this.estado,
      intentos: intentos ?? this.intentos,
      proximoIntentoAt: proximoIntentoAt ?? this.proximoIntentoAt,
      errorMensaje: errorMensaje ?? this.errorMensaje,
      programadoAt: programadoAt ?? this.programadoAt,
      enviadoAt: enviadoAt ?? this.enviadoAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (citaId.present) {
      map['cita_id'] = Variable<int>(citaId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (destinatario.present) {
      map['destinatario'] = Variable<String>(destinatario.value);
    }
    if (cc.present) {
      map['cc'] = Variable<String>(cc.value);
    }
    if (asunto.present) {
      map['asunto'] = Variable<String>(asunto.value);
    }
    if (cuerpoHtml.present) {
      map['cuerpo_html'] = Variable<String>(cuerpoHtml.value);
    }
    if (adjuntosJson.present) {
      map['adjuntos_json'] = Variable<String>(adjuntosJson.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (intentos.present) {
      map['intentos'] = Variable<int>(intentos.value);
    }
    if (proximoIntentoAt.present) {
      map['proximo_intento_at'] = Variable<int>(proximoIntentoAt.value);
    }
    if (errorMensaje.present) {
      map['error_mensaje'] = Variable<String>(errorMensaje.value);
    }
    if (programadoAt.present) {
      map['programado_at'] = Variable<int>(programadoAt.value);
    }
    if (enviadoAt.present) {
      map['enviado_at'] = Variable<int>(enviadoAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CorreosLogCompanion(')
          ..write('id: $id, ')
          ..write('citaId: $citaId, ')
          ..write('tipo: $tipo, ')
          ..write('destinatario: $destinatario, ')
          ..write('cc: $cc, ')
          ..write('asunto: $asunto, ')
          ..write('cuerpoHtml: $cuerpoHtml, ')
          ..write('adjuntosJson: $adjuntosJson, ')
          ..write('estado: $estado, ')
          ..write('intentos: $intentos, ')
          ..write('proximoIntentoAt: $proximoIntentoAt, ')
          ..write('errorMensaje: $errorMensaje, ')
          ..write('programadoAt: $programadoAt, ')
          ..write('enviadoAt: $enviadoAt')
          ..write(')'))
        .toString();
  }
}

class $EventosCitaTable extends EventosCita
    with TableInfo<$EventosCitaTable, EventosCitaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventosCitaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _citaIdMeta = const VerificationMeta('citaId');
  @override
  late final GeneratedColumn<int> citaId = GeneratedColumn<int>(
    'cita_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES citas (id)',
    ),
  );
  static const VerificationMeta _tipoEventoMeta = const VerificationMeta(
    'tipoEvento',
  );
  @override
  late final GeneratedColumn<String> tipoEvento = GeneratedColumn<String>(
    'tipo_evento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detalleJsonMeta = const VerificationMeta(
    'detalleJson',
  );
  @override
  late final GeneratedColumn<String> detalleJson = GeneratedColumn<String>(
    'detalle_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    citaId,
    tipoEvento,
    detalleJson,
    createdAt,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eventos_cita';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventosCitaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cita_id')) {
      context.handle(
        _citaIdMeta,
        citaId.isAcceptableOrUnknown(data['cita_id']!, _citaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_citaIdMeta);
    }
    if (data.containsKey('tipo_evento')) {
      context.handle(
        _tipoEventoMeta,
        tipoEvento.isAcceptableOrUnknown(data['tipo_evento']!, _tipoEventoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoEventoMeta);
    }
    if (data.containsKey('detalle_json')) {
      context.handle(
        _detalleJsonMeta,
        detalleJson.isAcceptableOrUnknown(
          data['detalle_json']!,
          _detalleJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventosCitaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventosCitaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      citaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cita_id'],
      )!,
      tipoEvento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_evento'],
      )!,
      detalleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detalle_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by'],
      ),
    );
  }

  @override
  $EventosCitaTable createAlias(String alias) {
    return $EventosCitaTable(attachedDatabase, alias);
  }
}

class EventosCitaData extends DataClass implements Insertable<EventosCitaData> {
  final int id;
  final int citaId;
  final String tipoEvento;
  final String? detalleJson;
  final int createdAt;
  final int? createdBy;
  const EventosCitaData({
    required this.id,
    required this.citaId,
    required this.tipoEvento,
    this.detalleJson,
    required this.createdAt,
    this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cita_id'] = Variable<int>(citaId);
    map['tipo_evento'] = Variable<String>(tipoEvento);
    if (!nullToAbsent || detalleJson != null) {
      map['detalle_json'] = Variable<String>(detalleJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<int>(createdBy);
    }
    return map;
  }

  EventosCitaCompanion toCompanion(bool nullToAbsent) {
    return EventosCitaCompanion(
      id: Value(id),
      citaId: Value(citaId),
      tipoEvento: Value(tipoEvento),
      detalleJson: detalleJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detalleJson),
      createdAt: Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
    );
  }

  factory EventosCitaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventosCitaData(
      id: serializer.fromJson<int>(json['id']),
      citaId: serializer.fromJson<int>(json['citaId']),
      tipoEvento: serializer.fromJson<String>(json['tipoEvento']),
      detalleJson: serializer.fromJson<String?>(json['detalleJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<int?>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'citaId': serializer.toJson<int>(citaId),
      'tipoEvento': serializer.toJson<String>(tipoEvento),
      'detalleJson': serializer.toJson<String?>(detalleJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'createdBy': serializer.toJson<int?>(createdBy),
    };
  }

  EventosCitaData copyWith({
    int? id,
    int? citaId,
    String? tipoEvento,
    Value<String?> detalleJson = const Value.absent(),
    int? createdAt,
    Value<int?> createdBy = const Value.absent(),
  }) => EventosCitaData(
    id: id ?? this.id,
    citaId: citaId ?? this.citaId,
    tipoEvento: tipoEvento ?? this.tipoEvento,
    detalleJson: detalleJson.present ? detalleJson.value : this.detalleJson,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
  );
  EventosCitaData copyWithCompanion(EventosCitaCompanion data) {
    return EventosCitaData(
      id: data.id.present ? data.id.value : this.id,
      citaId: data.citaId.present ? data.citaId.value : this.citaId,
      tipoEvento: data.tipoEvento.present
          ? data.tipoEvento.value
          : this.tipoEvento,
      detalleJson: data.detalleJson.present
          ? data.detalleJson.value
          : this.detalleJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventosCitaData(')
          ..write('id: $id, ')
          ..write('citaId: $citaId, ')
          ..write('tipoEvento: $tipoEvento, ')
          ..write('detalleJson: $detalleJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, citaId, tipoEvento, detalleJson, createdAt, createdBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventosCitaData &&
          other.id == this.id &&
          other.citaId == this.citaId &&
          other.tipoEvento == this.tipoEvento &&
          other.detalleJson == this.detalleJson &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy);
}

class EventosCitaCompanion extends UpdateCompanion<EventosCitaData> {
  final Value<int> id;
  final Value<int> citaId;
  final Value<String> tipoEvento;
  final Value<String?> detalleJson;
  final Value<int> createdAt;
  final Value<int?> createdBy;
  const EventosCitaCompanion({
    this.id = const Value.absent(),
    this.citaId = const Value.absent(),
    this.tipoEvento = const Value.absent(),
    this.detalleJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
  });
  EventosCitaCompanion.insert({
    this.id = const Value.absent(),
    required int citaId,
    required String tipoEvento,
    this.detalleJson = const Value.absent(),
    required int createdAt,
    this.createdBy = const Value.absent(),
  }) : citaId = Value(citaId),
       tipoEvento = Value(tipoEvento),
       createdAt = Value(createdAt);
  static Insertable<EventosCitaData> custom({
    Expression<int>? id,
    Expression<int>? citaId,
    Expression<String>? tipoEvento,
    Expression<String>? detalleJson,
    Expression<int>? createdAt,
    Expression<int>? createdBy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (citaId != null) 'cita_id': citaId,
      if (tipoEvento != null) 'tipo_evento': tipoEvento,
      if (detalleJson != null) 'detalle_json': detalleJson,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
    });
  }

  EventosCitaCompanion copyWith({
    Value<int>? id,
    Value<int>? citaId,
    Value<String>? tipoEvento,
    Value<String?>? detalleJson,
    Value<int>? createdAt,
    Value<int?>? createdBy,
  }) {
    return EventosCitaCompanion(
      id: id ?? this.id,
      citaId: citaId ?? this.citaId,
      tipoEvento: tipoEvento ?? this.tipoEvento,
      detalleJson: detalleJson ?? this.detalleJson,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (citaId.present) {
      map['cita_id'] = Variable<int>(citaId.value);
    }
    if (tipoEvento.present) {
      map['tipo_evento'] = Variable<String>(tipoEvento.value);
    }
    if (detalleJson.present) {
      map['detalle_json'] = Variable<String>(detalleJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventosCitaCompanion(')
          ..write('id: $id, ')
          ..write('citaId: $citaId, ')
          ..write('tipoEvento: $tipoEvento, ')
          ..write('detalleJson: $detalleJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }
}

class $AuditoriaTable extends Auditoria
    with TableInfo<$AuditoriaTable, AuditoriaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditoriaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _tablaMeta = const VerificationMeta('tabla');
  @override
  late final GeneratedColumn<String> tabla = GeneratedColumn<String>(
    'tabla',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registroIdMeta = const VerificationMeta(
    'registroId',
  );
  @override
  late final GeneratedColumn<int> registroId = GeneratedColumn<int>(
    'registro_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accionMeta = const VerificationMeta('accion');
  @override
  late final GeneratedColumn<String> accion = GeneratedColumn<String>(
    'accion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorAntesMeta = const VerificationMeta(
    'valorAntes',
  );
  @override
  late final GeneratedColumn<String> valorAntes = GeneratedColumn<String>(
    'valor_antes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valorDespuesMeta = const VerificationMeta(
    'valorDespues',
  );
  @override
  late final GeneratedColumn<String> valorDespues = GeneratedColumn<String>(
    'valor_despues',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
    'motivo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<int> fecha = GeneratedColumn<int>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    tabla,
    registroId,
    accion,
    valorAntes,
    valorDespues,
    motivo,
    fecha,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auditoria';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditoriaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('tabla')) {
      context.handle(
        _tablaMeta,
        tabla.isAcceptableOrUnknown(data['tabla']!, _tablaMeta),
      );
    } else if (isInserting) {
      context.missing(_tablaMeta);
    }
    if (data.containsKey('registro_id')) {
      context.handle(
        _registroIdMeta,
        registroId.isAcceptableOrUnknown(data['registro_id']!, _registroIdMeta),
      );
    }
    if (data.containsKey('accion')) {
      context.handle(
        _accionMeta,
        accion.isAcceptableOrUnknown(data['accion']!, _accionMeta),
      );
    } else if (isInserting) {
      context.missing(_accionMeta);
    }
    if (data.containsKey('valor_antes')) {
      context.handle(
        _valorAntesMeta,
        valorAntes.isAcceptableOrUnknown(data['valor_antes']!, _valorAntesMeta),
      );
    }
    if (data.containsKey('valor_despues')) {
      context.handle(
        _valorDespuesMeta,
        valorDespues.isAcceptableOrUnknown(
          data['valor_despues']!,
          _valorDespuesMeta,
        ),
      );
    }
    if (data.containsKey('motivo')) {
      context.handle(
        _motivoMeta,
        motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditoriaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditoriaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      tabla: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tabla'],
      )!,
      registroId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}registro_id'],
      ),
      accion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accion'],
      )!,
      valorAntes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor_antes'],
      ),
      valorDespues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor_despues'],
      ),
      motivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha'],
      )!,
    );
  }

  @override
  $AuditoriaTable createAlias(String alias) {
    return $AuditoriaTable(attachedDatabase, alias);
  }
}

class AuditoriaData extends DataClass implements Insertable<AuditoriaData> {
  final int id;
  final int? userId;
  final String tabla;
  final int? registroId;
  final String accion;
  final String? valorAntes;
  final String? valorDespues;
  final String? motivo;
  final int fecha;
  const AuditoriaData({
    required this.id,
    this.userId,
    required this.tabla,
    this.registroId,
    required this.accion,
    this.valorAntes,
    this.valorDespues,
    this.motivo,
    required this.fecha,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    map['tabla'] = Variable<String>(tabla);
    if (!nullToAbsent || registroId != null) {
      map['registro_id'] = Variable<int>(registroId);
    }
    map['accion'] = Variable<String>(accion);
    if (!nullToAbsent || valorAntes != null) {
      map['valor_antes'] = Variable<String>(valorAntes);
    }
    if (!nullToAbsent || valorDespues != null) {
      map['valor_despues'] = Variable<String>(valorDespues);
    }
    if (!nullToAbsent || motivo != null) {
      map['motivo'] = Variable<String>(motivo);
    }
    map['fecha'] = Variable<int>(fecha);
    return map;
  }

  AuditoriaCompanion toCompanion(bool nullToAbsent) {
    return AuditoriaCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      tabla: Value(tabla),
      registroId: registroId == null && nullToAbsent
          ? const Value.absent()
          : Value(registroId),
      accion: Value(accion),
      valorAntes: valorAntes == null && nullToAbsent
          ? const Value.absent()
          : Value(valorAntes),
      valorDespues: valorDespues == null && nullToAbsent
          ? const Value.absent()
          : Value(valorDespues),
      motivo: motivo == null && nullToAbsent
          ? const Value.absent()
          : Value(motivo),
      fecha: Value(fecha),
    );
  }

  factory AuditoriaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditoriaData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int?>(json['userId']),
      tabla: serializer.fromJson<String>(json['tabla']),
      registroId: serializer.fromJson<int?>(json['registroId']),
      accion: serializer.fromJson<String>(json['accion']),
      valorAntes: serializer.fromJson<String?>(json['valorAntes']),
      valorDespues: serializer.fromJson<String?>(json['valorDespues']),
      motivo: serializer.fromJson<String?>(json['motivo']),
      fecha: serializer.fromJson<int>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int?>(userId),
      'tabla': serializer.toJson<String>(tabla),
      'registroId': serializer.toJson<int?>(registroId),
      'accion': serializer.toJson<String>(accion),
      'valorAntes': serializer.toJson<String?>(valorAntes),
      'valorDespues': serializer.toJson<String?>(valorDespues),
      'motivo': serializer.toJson<String?>(motivo),
      'fecha': serializer.toJson<int>(fecha),
    };
  }

  AuditoriaData copyWith({
    int? id,
    Value<int?> userId = const Value.absent(),
    String? tabla,
    Value<int?> registroId = const Value.absent(),
    String? accion,
    Value<String?> valorAntes = const Value.absent(),
    Value<String?> valorDespues = const Value.absent(),
    Value<String?> motivo = const Value.absent(),
    int? fecha,
  }) => AuditoriaData(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    tabla: tabla ?? this.tabla,
    registroId: registroId.present ? registroId.value : this.registroId,
    accion: accion ?? this.accion,
    valorAntes: valorAntes.present ? valorAntes.value : this.valorAntes,
    valorDespues: valorDespues.present ? valorDespues.value : this.valorDespues,
    motivo: motivo.present ? motivo.value : this.motivo,
    fecha: fecha ?? this.fecha,
  );
  AuditoriaData copyWithCompanion(AuditoriaCompanion data) {
    return AuditoriaData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      tabla: data.tabla.present ? data.tabla.value : this.tabla,
      registroId: data.registroId.present
          ? data.registroId.value
          : this.registroId,
      accion: data.accion.present ? data.accion.value : this.accion,
      valorAntes: data.valorAntes.present
          ? data.valorAntes.value
          : this.valorAntes,
      valorDespues: data.valorDespues.present
          ? data.valorDespues.value
          : this.valorDespues,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditoriaData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tabla: $tabla, ')
          ..write('registroId: $registroId, ')
          ..write('accion: $accion, ')
          ..write('valorAntes: $valorAntes, ')
          ..write('valorDespues: $valorDespues, ')
          ..write('motivo: $motivo, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    tabla,
    registroId,
    accion,
    valorAntes,
    valorDespues,
    motivo,
    fecha,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditoriaData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.tabla == this.tabla &&
          other.registroId == this.registroId &&
          other.accion == this.accion &&
          other.valorAntes == this.valorAntes &&
          other.valorDespues == this.valorDespues &&
          other.motivo == this.motivo &&
          other.fecha == this.fecha);
}

class AuditoriaCompanion extends UpdateCompanion<AuditoriaData> {
  final Value<int> id;
  final Value<int?> userId;
  final Value<String> tabla;
  final Value<int?> registroId;
  final Value<String> accion;
  final Value<String?> valorAntes;
  final Value<String?> valorDespues;
  final Value<String?> motivo;
  final Value<int> fecha;
  const AuditoriaCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.tabla = const Value.absent(),
    this.registroId = const Value.absent(),
    this.accion = const Value.absent(),
    this.valorAntes = const Value.absent(),
    this.valorDespues = const Value.absent(),
    this.motivo = const Value.absent(),
    this.fecha = const Value.absent(),
  });
  AuditoriaCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required String tabla,
    this.registroId = const Value.absent(),
    required String accion,
    this.valorAntes = const Value.absent(),
    this.valorDespues = const Value.absent(),
    this.motivo = const Value.absent(),
    required int fecha,
  }) : tabla = Value(tabla),
       accion = Value(accion),
       fecha = Value(fecha);
  static Insertable<AuditoriaData> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? tabla,
    Expression<int>? registroId,
    Expression<String>? accion,
    Expression<String>? valorAntes,
    Expression<String>? valorDespues,
    Expression<String>? motivo,
    Expression<int>? fecha,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (tabla != null) 'tabla': tabla,
      if (registroId != null) 'registro_id': registroId,
      if (accion != null) 'accion': accion,
      if (valorAntes != null) 'valor_antes': valorAntes,
      if (valorDespues != null) 'valor_despues': valorDespues,
      if (motivo != null) 'motivo': motivo,
      if (fecha != null) 'fecha': fecha,
    });
  }

  AuditoriaCompanion copyWith({
    Value<int>? id,
    Value<int?>? userId,
    Value<String>? tabla,
    Value<int?>? registroId,
    Value<String>? accion,
    Value<String?>? valorAntes,
    Value<String?>? valorDespues,
    Value<String?>? motivo,
    Value<int>? fecha,
  }) {
    return AuditoriaCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tabla: tabla ?? this.tabla,
      registroId: registroId ?? this.registroId,
      accion: accion ?? this.accion,
      valorAntes: valorAntes ?? this.valorAntes,
      valorDespues: valorDespues ?? this.valorDespues,
      motivo: motivo ?? this.motivo,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (tabla.present) {
      map['tabla'] = Variable<String>(tabla.value);
    }
    if (registroId.present) {
      map['registro_id'] = Variable<int>(registroId.value);
    }
    if (accion.present) {
      map['accion'] = Variable<String>(accion.value);
    }
    if (valorAntes.present) {
      map['valor_antes'] = Variable<String>(valorAntes.value);
    }
    if (valorDespues.present) {
      map['valor_despues'] = Variable<String>(valorDespues.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<int>(fecha.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditoriaCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('tabla: $tabla, ')
          ..write('registroId: $registroId, ')
          ..write('accion: $accion, ')
          ..write('valorAntes: $valorAntes, ')
          ..write('valorDespues: $valorDespues, ')
          ..write('motivo: $motivo, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RolesTable roles = $RolesTable(this);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  late final $PermisosTable permisos = $PermisosTable(this);
  late final $ConfiguracionTable configuracion = $ConfiguracionTable(this);
  late final $CitasTable citas = $CitasTable(this);
  late final $DocumentosTable documentos = $DocumentosTable(this);
  late final $CorreosLogTable correosLog = $CorreosLogTable(this);
  late final $EventosCitaTable eventosCita = $EventosCitaTable(this);
  late final $AuditoriaTable auditoria = $AuditoriaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    roles,
    usuarios,
    permisos,
    configuracion,
    citas,
    documentos,
    correosLog,
    eventosCita,
    auditoria,
  ];
}

typedef $$RolesTableCreateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      required String nombre,
      Value<String?> descripcion,
    });
typedef $$RolesTableUpdateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String?> descripcion,
    });

final class $$RolesTableReferences
    extends BaseReferences<_$AppDatabase, $RolesTable, Role> {
  $$RolesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UsuariosTable, List<Usuario>> _usuariosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.usuarios,
    aliasName: 'roles__id__usuarios__rol_id',
  );

  $$UsuariosTableProcessedTableManager get usuariosRefs {
    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.rolId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_usuariosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PermisosTable, List<Permiso>> _permisosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.permisos,
    aliasName: 'roles__id__permisos__rol_id',
  );

  $$PermisosTableProcessedTableManager get permisosRefs {
    final manager = $$PermisosTableTableManager(
      $_db,
      $_db.permisos,
    ).filter((f) => f.rolId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_permisosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RolesTableFilterComposer extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> usuariosRefs(
    Expression<bool> Function($$UsuariosTableFilterComposer f) f,
  ) {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.rolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> permisosRefs(
    Expression<bool> Function($$PermisosTableFilterComposer f) f,
  ) {
    final $$PermisosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.permisos,
      getReferencedColumn: (t) => t.rolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PermisosTableFilterComposer(
            $db: $db,
            $table: $db.permisos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RolesTableOrderingComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  Expression<T> usuariosRefs<T extends Object>(
    Expression<T> Function($$UsuariosTableAnnotationComposer a) f,
  ) {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.rolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> permisosRefs<T extends Object>(
    Expression<T> Function($$PermisosTableAnnotationComposer a) f,
  ) {
    final $$PermisosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.permisos,
      getReferencedColumn: (t) => t.rolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PermisosTableAnnotationComposer(
            $db: $db,
            $table: $db.permisos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RolesTable,
          Role,
          $$RolesTableFilterComposer,
          $$RolesTableOrderingComposer,
          $$RolesTableAnnotationComposer,
          $$RolesTableCreateCompanionBuilder,
          $$RolesTableUpdateCompanionBuilder,
          (Role, $$RolesTableReferences),
          Role,
          PrefetchHooks Function({bool usuariosRefs, bool permisosRefs})
        > {
  $$RolesTableTableManager(_$AppDatabase db, $RolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
              }) => RolesCompanion(
                id: id,
                nombre: nombre,
                descripcion: descripcion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> descripcion = const Value.absent(),
              }) => RolesCompanion.insert(
                id: id,
                nombre: nombre,
                descripcion: descripcion,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RolesTable, Role>(table),
                  $$RolesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({usuariosRefs = false, permisosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (usuariosRefs) db.usuarios,
                    if (permisosRefs) db.permisos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (usuariosRefs)
                        await $_getPrefetchedDataByColumns<
                          Role,
                          $RolesTable,
                          Usuario,
                          $UsuariosTable
                        >(
                          currentTable: table,
                          referencedTable: $$RolesTableReferences
                              ._usuariosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RolesTableReferences(
                                db,
                                table,
                                p0,
                              ).usuariosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'rol_id',
                          typedResults: items,
                        ),
                      if (permisosRefs)
                        await $_getPrefetchedDataByColumns<
                          Role,
                          $RolesTable,
                          Permiso,
                          $PermisosTable
                        >(
                          currentTable: table,
                          referencedTable: $$RolesTableReferences
                              ._permisosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RolesTableReferences(
                                db,
                                table,
                                p0,
                              ).permisosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'rol_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RolesTable,
      Role,
      $$RolesTableFilterComposer,
      $$RolesTableOrderingComposer,
      $$RolesTableAnnotationComposer,
      $$RolesTableCreateCompanionBuilder,
      $$RolesTableUpdateCompanionBuilder,
      (Role, $$RolesTableReferences),
      Role,
      PrefetchHooks Function({bool usuariosRefs, bool permisosRefs})
    >;
typedef $$UsuariosTableCreateCompanionBuilder =
    UsuariosCompanion Function({
      Value<int> id,
      required String username,
      required String passwordHash,
      required String nombreCompleto,
      required int rolId,
      Value<bool> activo,
      Value<int?> userCreation,
      Value<int?> dateCreation,
      Value<int?> userUpdated,
      Value<int?> dateUpdated,
      Value<bool> isDelete,
    });
typedef $$UsuariosTableUpdateCompanionBuilder =
    UsuariosCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> passwordHash,
      Value<String> nombreCompleto,
      Value<int> rolId,
      Value<bool> activo,
      Value<int?> userCreation,
      Value<int?> dateCreation,
      Value<int?> userUpdated,
      Value<int?> dateUpdated,
      Value<bool> isDelete,
    });

final class $$UsuariosTableReferences
    extends BaseReferences<_$AppDatabase, $UsuariosTable, Usuario> {
  $$UsuariosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RolesTable _rolIdTable(_$AppDatabase db) =>
      db.roles.createAlias('usuarios__rol_id__roles__id');

  $$RolesTableProcessedTableManager get rolId {
    final $_column = $_itemColumn<int>('rol_id')!;

    final manager = $$RolesTableTableManager(
      $_db,
      $_db.roles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rolIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CitasTable, List<Cita>> _citasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.citas,
    aliasName: 'usuarios__id__citas__creada_por',
  );

  $$CitasTableProcessedTableManager get citasRefs {
    final manager = $$CitasTableTableManager(
      $_db,
      $_db.citas,
    ).filter((f) => f.creadaPor.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_citasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentosTable, List<Documento>>
  _documentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documentos,
    aliasName: 'usuarios__id__documentos__subido_por',
  );

  $$DocumentosTableProcessedTableManager get documentosRefs {
    final manager = $$DocumentosTableTableManager(
      $_db,
      $_db.documentos,
    ).filter((f) => f.subidoPor.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventosCitaTable, List<EventosCitaData>>
  _eventosCitaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventosCita,
    aliasName: 'usuarios__id__eventos_cita__created_by',
  );

  $$EventosCitaTableProcessedTableManager get eventosCitaRefs {
    final manager = $$EventosCitaTableTableManager(
      $_db,
      $_db.eventosCita,
    ).filter((f) => f.createdBy.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventosCitaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuditoriaTable, List<AuditoriaData>>
  _auditoriaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.auditoria,
    aliasName: 'usuarios__id__auditoria__user_id',
  );

  $$AuditoriaTableProcessedTableManager get auditoriaRefs {
    final manager = $$AuditoriaTableTableManager(
      $_db,
      $_db.auditoria,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditoriaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsuariosTableFilterComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreCompleto => $composableBuilder(
    column: $table.nombreCompleto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userCreation => $composableBuilder(
    column: $table.userCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userUpdated => $composableBuilder(
    column: $table.userUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDelete => $composableBuilder(
    column: $table.isDelete,
    builder: (column) => ColumnFilters(column),
  );

  $$RolesTableFilterComposer get rolId {
    final $$RolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rolId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableFilterComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> citasRefs(
    Expression<bool> Function($$CitasTableFilterComposer f) f,
  ) {
    final $$CitasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.creadaPor,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableFilterComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentosRefs(
    Expression<bool> Function($$DocumentosTableFilterComposer f) f,
  ) {
    final $$DocumentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentos,
      getReferencedColumn: (t) => t.subidoPor,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentosTableFilterComposer(
            $db: $db,
            $table: $db.documentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventosCitaRefs(
    Expression<bool> Function($$EventosCitaTableFilterComposer f) f,
  ) {
    final $$EventosCitaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventosCita,
      getReferencedColumn: (t) => t.createdBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosCitaTableFilterComposer(
            $db: $db,
            $table: $db.eventosCita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auditoriaRefs(
    Expression<bool> Function($$AuditoriaTableFilterComposer f) f,
  ) {
    final $$AuditoriaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditoria,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditoriaTableFilterComposer(
            $db: $db,
            $table: $db.auditoria,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsuariosTableOrderingComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreCompleto => $composableBuilder(
    column: $table.nombreCompleto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userCreation => $composableBuilder(
    column: $table.userCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userUpdated => $composableBuilder(
    column: $table.userUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDelete => $composableBuilder(
    column: $table.isDelete,
    builder: (column) => ColumnOrderings(column),
  );

  $$RolesTableOrderingComposer get rolId {
    final $$RolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rolId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableOrderingComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsuariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombreCompleto => $composableBuilder(
    column: $table.nombreCompleto,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<int> get userCreation => $composableBuilder(
    column: $table.userCreation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userUpdated => $composableBuilder(
    column: $table.userUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDelete =>
      $composableBuilder(column: $table.isDelete, builder: (column) => column);

  $$RolesTableAnnotationComposer get rolId {
    final $$RolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rolId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableAnnotationComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> citasRefs<T extends Object>(
    Expression<T> Function($$CitasTableAnnotationComposer a) f,
  ) {
    final $$CitasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.creadaPor,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableAnnotationComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentosRefs<T extends Object>(
    Expression<T> Function($$DocumentosTableAnnotationComposer a) f,
  ) {
    final $$DocumentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentos,
      getReferencedColumn: (t) => t.subidoPor,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentosTableAnnotationComposer(
            $db: $db,
            $table: $db.documentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventosCitaRefs<T extends Object>(
    Expression<T> Function($$EventosCitaTableAnnotationComposer a) f,
  ) {
    final $$EventosCitaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventosCita,
      getReferencedColumn: (t) => t.createdBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosCitaTableAnnotationComposer(
            $db: $db,
            $table: $db.eventosCita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> auditoriaRefs<T extends Object>(
    Expression<T> Function($$AuditoriaTableAnnotationComposer a) f,
  ) {
    final $$AuditoriaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditoria,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditoriaTableAnnotationComposer(
            $db: $db,
            $table: $db.auditoria,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsuariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsuariosTable,
          Usuario,
          $$UsuariosTableFilterComposer,
          $$UsuariosTableOrderingComposer,
          $$UsuariosTableAnnotationComposer,
          $$UsuariosTableCreateCompanionBuilder,
          $$UsuariosTableUpdateCompanionBuilder,
          (Usuario, $$UsuariosTableReferences),
          Usuario,
          PrefetchHooks Function({
            bool rolId,
            bool citasRefs,
            bool documentosRefs,
            bool eventosCitaRefs,
            bool auditoriaRefs,
          })
        > {
  $$UsuariosTableTableManager(_$AppDatabase db, $UsuariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> nombreCompleto = const Value.absent(),
                Value<int> rolId = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<int?> userCreation = const Value.absent(),
                Value<int?> dateCreation = const Value.absent(),
                Value<int?> userUpdated = const Value.absent(),
                Value<int?> dateUpdated = const Value.absent(),
                Value<bool> isDelete = const Value.absent(),
              }) => UsuariosCompanion(
                id: id,
                username: username,
                passwordHash: passwordHash,
                nombreCompleto: nombreCompleto,
                rolId: rolId,
                activo: activo,
                userCreation: userCreation,
                dateCreation: dateCreation,
                userUpdated: userUpdated,
                dateUpdated: dateUpdated,
                isDelete: isDelete,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String passwordHash,
                required String nombreCompleto,
                required int rolId,
                Value<bool> activo = const Value.absent(),
                Value<int?> userCreation = const Value.absent(),
                Value<int?> dateCreation = const Value.absent(),
                Value<int?> userUpdated = const Value.absent(),
                Value<int?> dateUpdated = const Value.absent(),
                Value<bool> isDelete = const Value.absent(),
              }) => UsuariosCompanion.insert(
                id: id,
                username: username,
                passwordHash: passwordHash,
                nombreCompleto: nombreCompleto,
                rolId: rolId,
                activo: activo,
                userCreation: userCreation,
                dateCreation: dateCreation,
                userUpdated: userUpdated,
                dateUpdated: dateUpdated,
                isDelete: isDelete,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsuariosTable, Usuario>(table),
                  $$UsuariosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                rolId = false,
                citasRefs = false,
                documentosRefs = false,
                eventosCitaRefs = false,
                auditoriaRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (citasRefs) db.citas,
                    if (documentosRefs) db.documentos,
                    if (eventosCitaRefs) db.eventosCita,
                    if (auditoriaRefs) db.auditoria,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (rolId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.rolId,
                                    referencedTable: $$UsuariosTableReferences
                                        ._rolIdTable(db),
                                    referencedColumn: $$UsuariosTableReferences
                                        ._rolIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (citasRefs)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          Cita,
                          $CitasTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._citasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).citasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'creada_por',
                          typedResults: items,
                        ),
                      if (documentosRefs)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          Documento,
                          $DocumentosTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._documentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).documentosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'subido_por',
                          typedResults: items,
                        ),
                      if (eventosCitaRefs)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          EventosCitaData,
                          $EventosCitaTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._eventosCitaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).eventosCitaRefs,
                          currentColumn: 'id',
                          referencedColumn: 'created_by',
                          typedResults: items,
                        ),
                      if (auditoriaRefs)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          AuditoriaData,
                          $AuditoriaTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._auditoriaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).auditoriaRefs,
                          currentColumn: 'id',
                          referencedColumn: 'user_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsuariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsuariosTable,
      Usuario,
      $$UsuariosTableFilterComposer,
      $$UsuariosTableOrderingComposer,
      $$UsuariosTableAnnotationComposer,
      $$UsuariosTableCreateCompanionBuilder,
      $$UsuariosTableUpdateCompanionBuilder,
      (Usuario, $$UsuariosTableReferences),
      Usuario,
      PrefetchHooks Function({
        bool rolId,
        bool citasRefs,
        bool documentosRefs,
        bool eventosCitaRefs,
        bool auditoriaRefs,
      })
    >;
typedef $$PermisosTableCreateCompanionBuilder =
    PermisosCompanion Function({
      Value<int> id,
      required int rolId,
      required String modulo,
      required String accion,
    });
typedef $$PermisosTableUpdateCompanionBuilder =
    PermisosCompanion Function({
      Value<int> id,
      Value<int> rolId,
      Value<String> modulo,
      Value<String> accion,
    });

final class $$PermisosTableReferences
    extends BaseReferences<_$AppDatabase, $PermisosTable, Permiso> {
  $$PermisosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RolesTable _rolIdTable(_$AppDatabase db) =>
      db.roles.createAlias('permisos__rol_id__roles__id');

  $$RolesTableProcessedTableManager get rolId {
    final $_column = $_itemColumn<int>('rol_id')!;

    final manager = $$RolesTableTableManager(
      $_db,
      $_db.roles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rolIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PermisosTableFilterComposer
    extends Composer<_$AppDatabase, $PermisosTable> {
  $$PermisosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modulo => $composableBuilder(
    column: $table.modulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnFilters(column),
  );

  $$RolesTableFilterComposer get rolId {
    final $$RolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rolId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableFilterComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PermisosTableOrderingComposer
    extends Composer<_$AppDatabase, $PermisosTable> {
  $$PermisosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modulo => $composableBuilder(
    column: $table.modulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnOrderings(column),
  );

  $$RolesTableOrderingComposer get rolId {
    final $$RolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rolId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableOrderingComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PermisosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PermisosTable> {
  $$PermisosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modulo =>
      $composableBuilder(column: $table.modulo, builder: (column) => column);

  GeneratedColumn<String> get accion =>
      $composableBuilder(column: $table.accion, builder: (column) => column);

  $$RolesTableAnnotationComposer get rolId {
    final $$RolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rolId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableAnnotationComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PermisosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PermisosTable,
          Permiso,
          $$PermisosTableFilterComposer,
          $$PermisosTableOrderingComposer,
          $$PermisosTableAnnotationComposer,
          $$PermisosTableCreateCompanionBuilder,
          $$PermisosTableUpdateCompanionBuilder,
          (Permiso, $$PermisosTableReferences),
          Permiso,
          PrefetchHooks Function({bool rolId})
        > {
  $$PermisosTableTableManager(_$AppDatabase db, $PermisosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PermisosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PermisosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PermisosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rolId = const Value.absent(),
                Value<String> modulo = const Value.absent(),
                Value<String> accion = const Value.absent(),
              }) => PermisosCompanion(
                id: id,
                rolId: rolId,
                modulo: modulo,
                accion: accion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rolId,
                required String modulo,
                required String accion,
              }) => PermisosCompanion.insert(
                id: id,
                rolId: rolId,
                modulo: modulo,
                accion: accion,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PermisosTable, Permiso>(table),
                  $$PermisosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rolId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rolId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rolId,
                                referencedTable: $$PermisosTableReferences
                                    ._rolIdTable(db),
                                referencedColumn: $$PermisosTableReferences
                                    ._rolIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PermisosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PermisosTable,
      Permiso,
      $$PermisosTableFilterComposer,
      $$PermisosTableOrderingComposer,
      $$PermisosTableAnnotationComposer,
      $$PermisosTableCreateCompanionBuilder,
      $$PermisosTableUpdateCompanionBuilder,
      (Permiso, $$PermisosTableReferences),
      Permiso,
      PrefetchHooks Function({bool rolId})
    >;
typedef $$ConfiguracionTableCreateCompanionBuilder =
    ConfiguracionCompanion Function({
      Value<int> id,
      required String clave,
      Value<String?> valor,
      Value<String?> tipo,
    });
typedef $$ConfiguracionTableUpdateCompanionBuilder =
    ConfiguracionCompanion Function({
      Value<int> id,
      Value<String> clave,
      Value<String?> valor,
      Value<String?> tipo,
    });

class $$ConfiguracionTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracionTable> {
  $$ConfiguracionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfiguracionTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracionTable> {
  $$ConfiguracionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfiguracionTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracionTable> {
  $$ConfiguracionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);
}

class $$ConfiguracionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfiguracionTable,
          ConfiguracionData,
          $$ConfiguracionTableFilterComposer,
          $$ConfiguracionTableOrderingComposer,
          $$ConfiguracionTableAnnotationComposer,
          $$ConfiguracionTableCreateCompanionBuilder,
          $$ConfiguracionTableUpdateCompanionBuilder,
          (
            ConfiguracionData,
            BaseReferences<
              _$AppDatabase,
              $ConfiguracionTable,
              ConfiguracionData
            >,
          ),
          ConfiguracionData,
          PrefetchHooks Function()
        > {
  $$ConfiguracionTableTableManager(_$AppDatabase db, $ConfiguracionTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfiguracionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfiguracionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clave = const Value.absent(),
                Value<String?> valor = const Value.absent(),
                Value<String?> tipo = const Value.absent(),
              }) => ConfiguracionCompanion(
                id: id,
                clave: clave,
                valor: valor,
                tipo: tipo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clave,
                Value<String?> valor = const Value.absent(),
                Value<String?> tipo = const Value.absent(),
              }) => ConfiguracionCompanion.insert(
                id: id,
                clave: clave,
                valor: valor,
                tipo: tipo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfiguracionTable, ConfiguracionData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ConfiguracionTable,
                    ConfiguracionData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfiguracionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfiguracionTable,
      ConfiguracionData,
      $$ConfiguracionTableFilterComposer,
      $$ConfiguracionTableOrderingComposer,
      $$ConfiguracionTableAnnotationComposer,
      $$ConfiguracionTableCreateCompanionBuilder,
      $$ConfiguracionTableUpdateCompanionBuilder,
      (
        ConfiguracionData,
        BaseReferences<_$AppDatabase, $ConfiguracionTable, ConfiguracionData>,
      ),
      ConfiguracionData,
      PrefetchHooks Function()
    >;
typedef $$CitasTableCreateCompanionBuilder =
    CitasCompanion Function({
      Value<int> id,
      required String uuidPublico,
      required String personaNombre,
      Value<String?> personaDpi,
      required String personaCorreo,
      Value<String?> personaTelefono,
      Value<String?> numeroContrato,
      Value<String?> puesto,
      Value<String?> salario,
      Value<String?> ubicacion,
      Value<String?> ubicacionEspecifica,
      Value<String?> fechaInicio,
      Value<String?> fechaFin,
      required int fechaHoraFirma,
      Value<String> estado,
      Value<String?> tokenConfirmacion,
      Value<int?> tokenExpira,
      Value<int?> confirmadoRecibidoAt,
      Value<int> reagendadaVeces,
      Value<String?> motivoUltimaReagenda,
      Value<String?> categoriaMotivoReagenda,
      Value<bool> postMortemPresentado,
      Value<bool> contraloriaPresentada,
      Value<int?> probidadAperturadaAt,
      Value<String?> notas,
      required int creadaPor,
      Value<int?> userCreation,
      Value<int?> dateCreation,
      Value<int?> userUpdated,
      Value<int?> dateUpdated,
      Value<bool> isDelete,
    });
typedef $$CitasTableUpdateCompanionBuilder =
    CitasCompanion Function({
      Value<int> id,
      Value<String> uuidPublico,
      Value<String> personaNombre,
      Value<String?> personaDpi,
      Value<String> personaCorreo,
      Value<String?> personaTelefono,
      Value<String?> numeroContrato,
      Value<String?> puesto,
      Value<String?> salario,
      Value<String?> ubicacion,
      Value<String?> ubicacionEspecifica,
      Value<String?> fechaInicio,
      Value<String?> fechaFin,
      Value<int> fechaHoraFirma,
      Value<String> estado,
      Value<String?> tokenConfirmacion,
      Value<int?> tokenExpira,
      Value<int?> confirmadoRecibidoAt,
      Value<int> reagendadaVeces,
      Value<String?> motivoUltimaReagenda,
      Value<String?> categoriaMotivoReagenda,
      Value<bool> postMortemPresentado,
      Value<bool> contraloriaPresentada,
      Value<int?> probidadAperturadaAt,
      Value<String?> notas,
      Value<int> creadaPor,
      Value<int?> userCreation,
      Value<int?> dateCreation,
      Value<int?> userUpdated,
      Value<int?> dateUpdated,
      Value<bool> isDelete,
    });

final class $$CitasTableReferences
    extends BaseReferences<_$AppDatabase, $CitasTable, Cita> {
  $$CitasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsuariosTable _creadaPorTable(_$AppDatabase db) =>
      db.usuarios.createAlias('citas__creada_por__usuarios__id');

  $$UsuariosTableProcessedTableManager get creadaPor {
    final $_column = $_itemColumn<int>('creada_por')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_creadaPorTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DocumentosTable, List<Documento>>
  _documentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documentos,
    aliasName: 'citas__id__documentos__cita_id',
  );

  $$DocumentosTableProcessedTableManager get documentosRefs {
    final manager = $$DocumentosTableTableManager(
      $_db,
      $_db.documentos,
    ).filter((f) => f.citaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CorreosLogTable, List<CorreosLogData>>
  _correosLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.correosLog,
    aliasName: 'citas__id__correos_log__cita_id',
  );

  $$CorreosLogTableProcessedTableManager get correosLogRefs {
    final manager = $$CorreosLogTableTableManager(
      $_db,
      $_db.correosLog,
    ).filter((f) => f.citaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_correosLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventosCitaTable, List<EventosCitaData>>
  _eventosCitaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventosCita,
    aliasName: 'citas__id__eventos_cita__cita_id',
  );

  $$EventosCitaTableProcessedTableManager get eventosCitaRefs {
    final manager = $$EventosCitaTableTableManager(
      $_db,
      $_db.eventosCita,
    ).filter((f) => f.citaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventosCitaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CitasTableFilterComposer extends Composer<_$AppDatabase, $CitasTable> {
  $$CitasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidPublico => $composableBuilder(
    column: $table.uuidPublico,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personaNombre => $composableBuilder(
    column: $table.personaNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personaDpi => $composableBuilder(
    column: $table.personaDpi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personaCorreo => $composableBuilder(
    column: $table.personaCorreo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personaTelefono => $composableBuilder(
    column: $table.personaTelefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numeroContrato => $composableBuilder(
    column: $table.numeroContrato,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puesto => $composableBuilder(
    column: $table.puesto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salario => $composableBuilder(
    column: $table.salario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ubicacion => $composableBuilder(
    column: $table.ubicacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ubicacionEspecifica => $composableBuilder(
    column: $table.ubicacionEspecifica,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fechaFin => $composableBuilder(
    column: $table.fechaFin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaHoraFirma => $composableBuilder(
    column: $table.fechaHoraFirma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenConfirmacion => $composableBuilder(
    column: $table.tokenConfirmacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokenExpira => $composableBuilder(
    column: $table.tokenExpira,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confirmadoRecibidoAt => $composableBuilder(
    column: $table.confirmadoRecibidoAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reagendadaVeces => $composableBuilder(
    column: $table.reagendadaVeces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivoUltimaReagenda => $composableBuilder(
    column: $table.motivoUltimaReagenda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoriaMotivoReagenda => $composableBuilder(
    column: $table.categoriaMotivoReagenda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get postMortemPresentado => $composableBuilder(
    column: $table.postMortemPresentado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get contraloriaPresentada => $composableBuilder(
    column: $table.contraloriaPresentada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get probidadAperturadaAt => $composableBuilder(
    column: $table.probidadAperturadaAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userCreation => $composableBuilder(
    column: $table.userCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userUpdated => $composableBuilder(
    column: $table.userUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDelete => $composableBuilder(
    column: $table.isDelete,
    builder: (column) => ColumnFilters(column),
  );

  $$UsuariosTableFilterComposer get creadaPor {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creadaPor,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> documentosRefs(
    Expression<bool> Function($$DocumentosTableFilterComposer f) f,
  ) {
    final $$DocumentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentos,
      getReferencedColumn: (t) => t.citaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentosTableFilterComposer(
            $db: $db,
            $table: $db.documentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> correosLogRefs(
    Expression<bool> Function($$CorreosLogTableFilterComposer f) f,
  ) {
    final $$CorreosLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.correosLog,
      getReferencedColumn: (t) => t.citaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorreosLogTableFilterComposer(
            $db: $db,
            $table: $db.correosLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventosCitaRefs(
    Expression<bool> Function($$EventosCitaTableFilterComposer f) f,
  ) {
    final $$EventosCitaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventosCita,
      getReferencedColumn: (t) => t.citaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosCitaTableFilterComposer(
            $db: $db,
            $table: $db.eventosCita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CitasTableOrderingComposer
    extends Composer<_$AppDatabase, $CitasTable> {
  $$CitasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidPublico => $composableBuilder(
    column: $table.uuidPublico,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personaNombre => $composableBuilder(
    column: $table.personaNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personaDpi => $composableBuilder(
    column: $table.personaDpi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personaCorreo => $composableBuilder(
    column: $table.personaCorreo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personaTelefono => $composableBuilder(
    column: $table.personaTelefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numeroContrato => $composableBuilder(
    column: $table.numeroContrato,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puesto => $composableBuilder(
    column: $table.puesto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salario => $composableBuilder(
    column: $table.salario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ubicacion => $composableBuilder(
    column: $table.ubicacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ubicacionEspecifica => $composableBuilder(
    column: $table.ubicacionEspecifica,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fechaFin => $composableBuilder(
    column: $table.fechaFin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaHoraFirma => $composableBuilder(
    column: $table.fechaHoraFirma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenConfirmacion => $composableBuilder(
    column: $table.tokenConfirmacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokenExpira => $composableBuilder(
    column: $table.tokenExpira,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmadoRecibidoAt => $composableBuilder(
    column: $table.confirmadoRecibidoAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reagendadaVeces => $composableBuilder(
    column: $table.reagendadaVeces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivoUltimaReagenda => $composableBuilder(
    column: $table.motivoUltimaReagenda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoriaMotivoReagenda => $composableBuilder(
    column: $table.categoriaMotivoReagenda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get postMortemPresentado => $composableBuilder(
    column: $table.postMortemPresentado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get contraloriaPresentada => $composableBuilder(
    column: $table.contraloriaPresentada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get probidadAperturadaAt => $composableBuilder(
    column: $table.probidadAperturadaAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userCreation => $composableBuilder(
    column: $table.userCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userUpdated => $composableBuilder(
    column: $table.userUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDelete => $composableBuilder(
    column: $table.isDelete,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsuariosTableOrderingComposer get creadaPor {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creadaPor,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CitasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CitasTable> {
  $$CitasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuidPublico => $composableBuilder(
    column: $table.uuidPublico,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personaNombre => $composableBuilder(
    column: $table.personaNombre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personaDpi => $composableBuilder(
    column: $table.personaDpi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personaCorreo => $composableBuilder(
    column: $table.personaCorreo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personaTelefono => $composableBuilder(
    column: $table.personaTelefono,
    builder: (column) => column,
  );

  GeneratedColumn<String> get numeroContrato => $composableBuilder(
    column: $table.numeroContrato,
    builder: (column) => column,
  );

  GeneratedColumn<String> get puesto =>
      $composableBuilder(column: $table.puesto, builder: (column) => column);

  GeneratedColumn<String> get salario =>
      $composableBuilder(column: $table.salario, builder: (column) => column);

  GeneratedColumn<String> get ubicacion =>
      $composableBuilder(column: $table.ubicacion, builder: (column) => column);

  GeneratedColumn<String> get ubicacionEspecifica => $composableBuilder(
    column: $table.ubicacionEspecifica,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fechaFin =>
      $composableBuilder(column: $table.fechaFin, builder: (column) => column);

  GeneratedColumn<int> get fechaHoraFirma => $composableBuilder(
    column: $table.fechaHoraFirma,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get tokenConfirmacion => $composableBuilder(
    column: $table.tokenConfirmacion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tokenExpira => $composableBuilder(
    column: $table.tokenExpira,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confirmadoRecibidoAt => $composableBuilder(
    column: $table.confirmadoRecibidoAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reagendadaVeces => $composableBuilder(
    column: $table.reagendadaVeces,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motivoUltimaReagenda => $composableBuilder(
    column: $table.motivoUltimaReagenda,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoriaMotivoReagenda => $composableBuilder(
    column: $table.categoriaMotivoReagenda,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get postMortemPresentado => $composableBuilder(
    column: $table.postMortemPresentado,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get contraloriaPresentada => $composableBuilder(
    column: $table.contraloriaPresentada,
    builder: (column) => column,
  );

  GeneratedColumn<int> get probidadAperturadaAt => $composableBuilder(
    column: $table.probidadAperturadaAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<int> get userCreation => $composableBuilder(
    column: $table.userCreation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateCreation => $composableBuilder(
    column: $table.dateCreation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userUpdated => $composableBuilder(
    column: $table.userUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateUpdated => $composableBuilder(
    column: $table.dateUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDelete =>
      $composableBuilder(column: $table.isDelete, builder: (column) => column);

  $$UsuariosTableAnnotationComposer get creadaPor {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creadaPor,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> documentosRefs<T extends Object>(
    Expression<T> Function($$DocumentosTableAnnotationComposer a) f,
  ) {
    final $$DocumentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentos,
      getReferencedColumn: (t) => t.citaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentosTableAnnotationComposer(
            $db: $db,
            $table: $db.documentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> correosLogRefs<T extends Object>(
    Expression<T> Function($$CorreosLogTableAnnotationComposer a) f,
  ) {
    final $$CorreosLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.correosLog,
      getReferencedColumn: (t) => t.citaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorreosLogTableAnnotationComposer(
            $db: $db,
            $table: $db.correosLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventosCitaRefs<T extends Object>(
    Expression<T> Function($$EventosCitaTableAnnotationComposer a) f,
  ) {
    final $$EventosCitaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventosCita,
      getReferencedColumn: (t) => t.citaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosCitaTableAnnotationComposer(
            $db: $db,
            $table: $db.eventosCita,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CitasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CitasTable,
          Cita,
          $$CitasTableFilterComposer,
          $$CitasTableOrderingComposer,
          $$CitasTableAnnotationComposer,
          $$CitasTableCreateCompanionBuilder,
          $$CitasTableUpdateCompanionBuilder,
          (Cita, $$CitasTableReferences),
          Cita,
          PrefetchHooks Function({
            bool creadaPor,
            bool documentosRefs,
            bool correosLogRefs,
            bool eventosCitaRefs,
          })
        > {
  $$CitasTableTableManager(_$AppDatabase db, $CitasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CitasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CitasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CitasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuidPublico = const Value.absent(),
                Value<String> personaNombre = const Value.absent(),
                Value<String?> personaDpi = const Value.absent(),
                Value<String> personaCorreo = const Value.absent(),
                Value<String?> personaTelefono = const Value.absent(),
                Value<String?> numeroContrato = const Value.absent(),
                Value<String?> puesto = const Value.absent(),
                Value<String?> salario = const Value.absent(),
                Value<String?> ubicacion = const Value.absent(),
                Value<String?> ubicacionEspecifica = const Value.absent(),
                Value<String?> fechaInicio = const Value.absent(),
                Value<String?> fechaFin = const Value.absent(),
                Value<int> fechaHoraFirma = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> tokenConfirmacion = const Value.absent(),
                Value<int?> tokenExpira = const Value.absent(),
                Value<int?> confirmadoRecibidoAt = const Value.absent(),
                Value<int> reagendadaVeces = const Value.absent(),
                Value<String?> motivoUltimaReagenda = const Value.absent(),
                Value<String?> categoriaMotivoReagenda = const Value.absent(),
                Value<bool> postMortemPresentado = const Value.absent(),
                Value<bool> contraloriaPresentada = const Value.absent(),
                Value<int?> probidadAperturadaAt = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<int> creadaPor = const Value.absent(),
                Value<int?> userCreation = const Value.absent(),
                Value<int?> dateCreation = const Value.absent(),
                Value<int?> userUpdated = const Value.absent(),
                Value<int?> dateUpdated = const Value.absent(),
                Value<bool> isDelete = const Value.absent(),
              }) => CitasCompanion(
                id: id,
                uuidPublico: uuidPublico,
                personaNombre: personaNombre,
                personaDpi: personaDpi,
                personaCorreo: personaCorreo,
                personaTelefono: personaTelefono,
                numeroContrato: numeroContrato,
                puesto: puesto,
                salario: salario,
                ubicacion: ubicacion,
                ubicacionEspecifica: ubicacionEspecifica,
                fechaInicio: fechaInicio,
                fechaFin: fechaFin,
                fechaHoraFirma: fechaHoraFirma,
                estado: estado,
                tokenConfirmacion: tokenConfirmacion,
                tokenExpira: tokenExpira,
                confirmadoRecibidoAt: confirmadoRecibidoAt,
                reagendadaVeces: reagendadaVeces,
                motivoUltimaReagenda: motivoUltimaReagenda,
                categoriaMotivoReagenda: categoriaMotivoReagenda,
                postMortemPresentado: postMortemPresentado,
                contraloriaPresentada: contraloriaPresentada,
                probidadAperturadaAt: probidadAperturadaAt,
                notas: notas,
                creadaPor: creadaPor,
                userCreation: userCreation,
                dateCreation: dateCreation,
                userUpdated: userUpdated,
                dateUpdated: dateUpdated,
                isDelete: isDelete,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuidPublico,
                required String personaNombre,
                Value<String?> personaDpi = const Value.absent(),
                required String personaCorreo,
                Value<String?> personaTelefono = const Value.absent(),
                Value<String?> numeroContrato = const Value.absent(),
                Value<String?> puesto = const Value.absent(),
                Value<String?> salario = const Value.absent(),
                Value<String?> ubicacion = const Value.absent(),
                Value<String?> ubicacionEspecifica = const Value.absent(),
                Value<String?> fechaInicio = const Value.absent(),
                Value<String?> fechaFin = const Value.absent(),
                required int fechaHoraFirma,
                Value<String> estado = const Value.absent(),
                Value<String?> tokenConfirmacion = const Value.absent(),
                Value<int?> tokenExpira = const Value.absent(),
                Value<int?> confirmadoRecibidoAt = const Value.absent(),
                Value<int> reagendadaVeces = const Value.absent(),
                Value<String?> motivoUltimaReagenda = const Value.absent(),
                Value<String?> categoriaMotivoReagenda = const Value.absent(),
                Value<bool> postMortemPresentado = const Value.absent(),
                Value<bool> contraloriaPresentada = const Value.absent(),
                Value<int?> probidadAperturadaAt = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                required int creadaPor,
                Value<int?> userCreation = const Value.absent(),
                Value<int?> dateCreation = const Value.absent(),
                Value<int?> userUpdated = const Value.absent(),
                Value<int?> dateUpdated = const Value.absent(),
                Value<bool> isDelete = const Value.absent(),
              }) => CitasCompanion.insert(
                id: id,
                uuidPublico: uuidPublico,
                personaNombre: personaNombre,
                personaDpi: personaDpi,
                personaCorreo: personaCorreo,
                personaTelefono: personaTelefono,
                numeroContrato: numeroContrato,
                puesto: puesto,
                salario: salario,
                ubicacion: ubicacion,
                ubicacionEspecifica: ubicacionEspecifica,
                fechaInicio: fechaInicio,
                fechaFin: fechaFin,
                fechaHoraFirma: fechaHoraFirma,
                estado: estado,
                tokenConfirmacion: tokenConfirmacion,
                tokenExpira: tokenExpira,
                confirmadoRecibidoAt: confirmadoRecibidoAt,
                reagendadaVeces: reagendadaVeces,
                motivoUltimaReagenda: motivoUltimaReagenda,
                categoriaMotivoReagenda: categoriaMotivoReagenda,
                postMortemPresentado: postMortemPresentado,
                contraloriaPresentada: contraloriaPresentada,
                probidadAperturadaAt: probidadAperturadaAt,
                notas: notas,
                creadaPor: creadaPor,
                userCreation: userCreation,
                dateCreation: dateCreation,
                userUpdated: userUpdated,
                dateUpdated: dateUpdated,
                isDelete: isDelete,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CitasTable, Cita>(table),
                  $$CitasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                creadaPor = false,
                documentosRefs = false,
                correosLogRefs = false,
                eventosCitaRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (documentosRefs) db.documentos,
                    if (correosLogRefs) db.correosLog,
                    if (eventosCitaRefs) db.eventosCita,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (creadaPor) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.creadaPor,
                                    referencedTable: $$CitasTableReferences
                                        ._creadaPorTable(db),
                                    referencedColumn: $$CitasTableReferences
                                        ._creadaPorTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (documentosRefs)
                        await $_getPrefetchedDataByColumns<
                          Cita,
                          $CitasTable,
                          Documento,
                          $DocumentosTable
                        >(
                          currentTable: table,
                          referencedTable: $$CitasTableReferences
                              ._documentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CitasTableReferences(
                                db,
                                table,
                                p0,
                              ).documentosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cita_id',
                          typedResults: items,
                        ),
                      if (correosLogRefs)
                        await $_getPrefetchedDataByColumns<
                          Cita,
                          $CitasTable,
                          CorreosLogData,
                          $CorreosLogTable
                        >(
                          currentTable: table,
                          referencedTable: $$CitasTableReferences
                              ._correosLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CitasTableReferences(
                                db,
                                table,
                                p0,
                              ).correosLogRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cita_id',
                          typedResults: items,
                        ),
                      if (eventosCitaRefs)
                        await $_getPrefetchedDataByColumns<
                          Cita,
                          $CitasTable,
                          EventosCitaData,
                          $EventosCitaTable
                        >(
                          currentTable: table,
                          referencedTable: $$CitasTableReferences
                              ._eventosCitaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CitasTableReferences(
                                db,
                                table,
                                p0,
                              ).eventosCitaRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cita_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CitasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CitasTable,
      Cita,
      $$CitasTableFilterComposer,
      $$CitasTableOrderingComposer,
      $$CitasTableAnnotationComposer,
      $$CitasTableCreateCompanionBuilder,
      $$CitasTableUpdateCompanionBuilder,
      (Cita, $$CitasTableReferences),
      Cita,
      PrefetchHooks Function({
        bool creadaPor,
        bool documentosRefs,
        bool correosLogRefs,
        bool eventosCitaRefs,
      })
    >;
typedef $$DocumentosTableCreateCompanionBuilder =
    DocumentosCompanion Function({
      Value<int> id,
      required int citaId,
      required String tipo,
      required String nombre,
      required String rutaArchivo,
      Value<String?> hashSha256,
      Value<String?> mimeType,
      Value<int?> tamanoBytes,
      required int subidoPor,
      required int subidoAt,
      Value<bool> isDelete,
    });
typedef $$DocumentosTableUpdateCompanionBuilder =
    DocumentosCompanion Function({
      Value<int> id,
      Value<int> citaId,
      Value<String> tipo,
      Value<String> nombre,
      Value<String> rutaArchivo,
      Value<String?> hashSha256,
      Value<String?> mimeType,
      Value<int?> tamanoBytes,
      Value<int> subidoPor,
      Value<int> subidoAt,
      Value<bool> isDelete,
    });

final class $$DocumentosTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentosTable, Documento> {
  $$DocumentosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CitasTable _citaIdTable(_$AppDatabase db) =>
      db.citas.createAlias('documentos__cita_id__citas__id');

  $$CitasTableProcessedTableManager get citaId {
    final $_column = $_itemColumn<int>('cita_id')!;

    final manager = $$CitasTableTableManager(
      $_db,
      $_db.citas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_citaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _subidoPorTable(_$AppDatabase db) =>
      db.usuarios.createAlias('documentos__subido_por__usuarios__id');

  $$UsuariosTableProcessedTableManager get subidoPor {
    final $_column = $_itemColumn<int>('subido_por')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subidoPorTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentosTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentosTable> {
  $$DocumentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rutaArchivo => $composableBuilder(
    column: $table.rutaArchivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hashSha256 => $composableBuilder(
    column: $table.hashSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tamanoBytes => $composableBuilder(
    column: $table.tamanoBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subidoAt => $composableBuilder(
    column: $table.subidoAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDelete => $composableBuilder(
    column: $table.isDelete,
    builder: (column) => ColumnFilters(column),
  );

  $$CitasTableFilterComposer get citaId {
    final $$CitasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.citaId,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableFilterComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get subidoPor {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subidoPor,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentosTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentosTable> {
  $$DocumentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rutaArchivo => $composableBuilder(
    column: $table.rutaArchivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hashSha256 => $composableBuilder(
    column: $table.hashSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tamanoBytes => $composableBuilder(
    column: $table.tamanoBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subidoAt => $composableBuilder(
    column: $table.subidoAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDelete => $composableBuilder(
    column: $table.isDelete,
    builder: (column) => ColumnOrderings(column),
  );

  $$CitasTableOrderingComposer get citaId {
    final $$CitasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.citaId,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableOrderingComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get subidoPor {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subidoPor,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentosTable> {
  $$DocumentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get rutaArchivo => $composableBuilder(
    column: $table.rutaArchivo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hashSha256 => $composableBuilder(
    column: $table.hashSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get tamanoBytes => $composableBuilder(
    column: $table.tamanoBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get subidoAt =>
      $composableBuilder(column: $table.subidoAt, builder: (column) => column);

  GeneratedColumn<bool> get isDelete =>
      $composableBuilder(column: $table.isDelete, builder: (column) => column);

  $$CitasTableAnnotationComposer get citaId {
    final $$CitasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.citaId,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableAnnotationComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get subidoPor {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subidoPor,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentosTable,
          Documento,
          $$DocumentosTableFilterComposer,
          $$DocumentosTableOrderingComposer,
          $$DocumentosTableAnnotationComposer,
          $$DocumentosTableCreateCompanionBuilder,
          $$DocumentosTableUpdateCompanionBuilder,
          (Documento, $$DocumentosTableReferences),
          Documento,
          PrefetchHooks Function({bool citaId, bool subidoPor})
        > {
  $$DocumentosTableTableManager(_$AppDatabase db, $DocumentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> citaId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> rutaArchivo = const Value.absent(),
                Value<String?> hashSha256 = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> tamanoBytes = const Value.absent(),
                Value<int> subidoPor = const Value.absent(),
                Value<int> subidoAt = const Value.absent(),
                Value<bool> isDelete = const Value.absent(),
              }) => DocumentosCompanion(
                id: id,
                citaId: citaId,
                tipo: tipo,
                nombre: nombre,
                rutaArchivo: rutaArchivo,
                hashSha256: hashSha256,
                mimeType: mimeType,
                tamanoBytes: tamanoBytes,
                subidoPor: subidoPor,
                subidoAt: subidoAt,
                isDelete: isDelete,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int citaId,
                required String tipo,
                required String nombre,
                required String rutaArchivo,
                Value<String?> hashSha256 = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> tamanoBytes = const Value.absent(),
                required int subidoPor,
                required int subidoAt,
                Value<bool> isDelete = const Value.absent(),
              }) => DocumentosCompanion.insert(
                id: id,
                citaId: citaId,
                tipo: tipo,
                nombre: nombre,
                rutaArchivo: rutaArchivo,
                hashSha256: hashSha256,
                mimeType: mimeType,
                tamanoBytes: tamanoBytes,
                subidoPor: subidoPor,
                subidoAt: subidoAt,
                isDelete: isDelete,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentosTable, Documento>(table),
                  $$DocumentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({citaId = false, subidoPor = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (citaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.citaId,
                                referencedTable: $$DocumentosTableReferences
                                    ._citaIdTable(db),
                                referencedColumn: $$DocumentosTableReferences
                                    ._citaIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (subidoPor) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.subidoPor,
                                referencedTable: $$DocumentosTableReferences
                                    ._subidoPorTable(db),
                                referencedColumn: $$DocumentosTableReferences
                                    ._subidoPorTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DocumentosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentosTable,
      Documento,
      $$DocumentosTableFilterComposer,
      $$DocumentosTableOrderingComposer,
      $$DocumentosTableAnnotationComposer,
      $$DocumentosTableCreateCompanionBuilder,
      $$DocumentosTableUpdateCompanionBuilder,
      (Documento, $$DocumentosTableReferences),
      Documento,
      PrefetchHooks Function({bool citaId, bool subidoPor})
    >;
typedef $$CorreosLogTableCreateCompanionBuilder =
    CorreosLogCompanion Function({
      Value<int> id,
      Value<int?> citaId,
      required String tipo,
      required String destinatario,
      Value<String?> cc,
      required String asunto,
      Value<String?> cuerpoHtml,
      Value<String?> adjuntosJson,
      Value<String> estado,
      Value<int> intentos,
      Value<int?> proximoIntentoAt,
      Value<String?> errorMensaje,
      required int programadoAt,
      Value<int?> enviadoAt,
    });
typedef $$CorreosLogTableUpdateCompanionBuilder =
    CorreosLogCompanion Function({
      Value<int> id,
      Value<int?> citaId,
      Value<String> tipo,
      Value<String> destinatario,
      Value<String?> cc,
      Value<String> asunto,
      Value<String?> cuerpoHtml,
      Value<String?> adjuntosJson,
      Value<String> estado,
      Value<int> intentos,
      Value<int?> proximoIntentoAt,
      Value<String?> errorMensaje,
      Value<int> programadoAt,
      Value<int?> enviadoAt,
    });

final class $$CorreosLogTableReferences
    extends BaseReferences<_$AppDatabase, $CorreosLogTable, CorreosLogData> {
  $$CorreosLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CitasTable _citaIdTable(_$AppDatabase db) =>
      db.citas.createAlias('correos_log__cita_id__citas__id');

  $$CitasTableProcessedTableManager? get citaId {
    final $_column = $_itemColumn<int>('cita_id');
    if ($_column == null) return null;
    final manager = $$CitasTableTableManager(
      $_db,
      $_db.citas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_citaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CorreosLogTableFilterComposer
    extends Composer<_$AppDatabase, $CorreosLogTable> {
  $$CorreosLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinatario => $composableBuilder(
    column: $table.destinatario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cc => $composableBuilder(
    column: $table.cc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asunto => $composableBuilder(
    column: $table.asunto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cuerpoHtml => $composableBuilder(
    column: $table.cuerpoHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adjuntosJson => $composableBuilder(
    column: $table.adjuntosJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intentos => $composableBuilder(
    column: $table.intentos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get proximoIntentoAt => $composableBuilder(
    column: $table.proximoIntentoAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMensaje => $composableBuilder(
    column: $table.errorMensaje,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get programadoAt => $composableBuilder(
    column: $table.programadoAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enviadoAt => $composableBuilder(
    column: $table.enviadoAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CitasTableFilterComposer get citaId {
    final $$CitasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.citaId,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableFilterComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CorreosLogTableOrderingComposer
    extends Composer<_$AppDatabase, $CorreosLogTable> {
  $$CorreosLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinatario => $composableBuilder(
    column: $table.destinatario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cc => $composableBuilder(
    column: $table.cc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asunto => $composableBuilder(
    column: $table.asunto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cuerpoHtml => $composableBuilder(
    column: $table.cuerpoHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjuntosJson => $composableBuilder(
    column: $table.adjuntosJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intentos => $composableBuilder(
    column: $table.intentos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get proximoIntentoAt => $composableBuilder(
    column: $table.proximoIntentoAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMensaje => $composableBuilder(
    column: $table.errorMensaje,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get programadoAt => $composableBuilder(
    column: $table.programadoAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enviadoAt => $composableBuilder(
    column: $table.enviadoAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CitasTableOrderingComposer get citaId {
    final $$CitasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.citaId,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableOrderingComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CorreosLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $CorreosLogTable> {
  $$CorreosLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get destinatario => $composableBuilder(
    column: $table.destinatario,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cc =>
      $composableBuilder(column: $table.cc, builder: (column) => column);

  GeneratedColumn<String> get asunto =>
      $composableBuilder(column: $table.asunto, builder: (column) => column);

  GeneratedColumn<String> get cuerpoHtml => $composableBuilder(
    column: $table.cuerpoHtml,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adjuntosJson => $composableBuilder(
    column: $table.adjuntosJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get intentos =>
      $composableBuilder(column: $table.intentos, builder: (column) => column);

  GeneratedColumn<int> get proximoIntentoAt => $composableBuilder(
    column: $table.proximoIntentoAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMensaje => $composableBuilder(
    column: $table.errorMensaje,
    builder: (column) => column,
  );

  GeneratedColumn<int> get programadoAt => $composableBuilder(
    column: $table.programadoAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get enviadoAt =>
      $composableBuilder(column: $table.enviadoAt, builder: (column) => column);

  $$CitasTableAnnotationComposer get citaId {
    final $$CitasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.citaId,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableAnnotationComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CorreosLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CorreosLogTable,
          CorreosLogData,
          $$CorreosLogTableFilterComposer,
          $$CorreosLogTableOrderingComposer,
          $$CorreosLogTableAnnotationComposer,
          $$CorreosLogTableCreateCompanionBuilder,
          $$CorreosLogTableUpdateCompanionBuilder,
          (CorreosLogData, $$CorreosLogTableReferences),
          CorreosLogData,
          PrefetchHooks Function({bool citaId})
        > {
  $$CorreosLogTableTableManager(_$AppDatabase db, $CorreosLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CorreosLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CorreosLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CorreosLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> citaId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> destinatario = const Value.absent(),
                Value<String?> cc = const Value.absent(),
                Value<String> asunto = const Value.absent(),
                Value<String?> cuerpoHtml = const Value.absent(),
                Value<String?> adjuntosJson = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> intentos = const Value.absent(),
                Value<int?> proximoIntentoAt = const Value.absent(),
                Value<String?> errorMensaje = const Value.absent(),
                Value<int> programadoAt = const Value.absent(),
                Value<int?> enviadoAt = const Value.absent(),
              }) => CorreosLogCompanion(
                id: id,
                citaId: citaId,
                tipo: tipo,
                destinatario: destinatario,
                cc: cc,
                asunto: asunto,
                cuerpoHtml: cuerpoHtml,
                adjuntosJson: adjuntosJson,
                estado: estado,
                intentos: intentos,
                proximoIntentoAt: proximoIntentoAt,
                errorMensaje: errorMensaje,
                programadoAt: programadoAt,
                enviadoAt: enviadoAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> citaId = const Value.absent(),
                required String tipo,
                required String destinatario,
                Value<String?> cc = const Value.absent(),
                required String asunto,
                Value<String?> cuerpoHtml = const Value.absent(),
                Value<String?> adjuntosJson = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> intentos = const Value.absent(),
                Value<int?> proximoIntentoAt = const Value.absent(),
                Value<String?> errorMensaje = const Value.absent(),
                required int programadoAt,
                Value<int?> enviadoAt = const Value.absent(),
              }) => CorreosLogCompanion.insert(
                id: id,
                citaId: citaId,
                tipo: tipo,
                destinatario: destinatario,
                cc: cc,
                asunto: asunto,
                cuerpoHtml: cuerpoHtml,
                adjuntosJson: adjuntosJson,
                estado: estado,
                intentos: intentos,
                proximoIntentoAt: proximoIntentoAt,
                errorMensaje: errorMensaje,
                programadoAt: programadoAt,
                enviadoAt: enviadoAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CorreosLogTable, CorreosLogData>(table),
                  $$CorreosLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({citaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (citaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.citaId,
                                referencedTable: $$CorreosLogTableReferences
                                    ._citaIdTable(db),
                                referencedColumn: $$CorreosLogTableReferences
                                    ._citaIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CorreosLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CorreosLogTable,
      CorreosLogData,
      $$CorreosLogTableFilterComposer,
      $$CorreosLogTableOrderingComposer,
      $$CorreosLogTableAnnotationComposer,
      $$CorreosLogTableCreateCompanionBuilder,
      $$CorreosLogTableUpdateCompanionBuilder,
      (CorreosLogData, $$CorreosLogTableReferences),
      CorreosLogData,
      PrefetchHooks Function({bool citaId})
    >;
typedef $$EventosCitaTableCreateCompanionBuilder =
    EventosCitaCompanion Function({
      Value<int> id,
      required int citaId,
      required String tipoEvento,
      Value<String?> detalleJson,
      required int createdAt,
      Value<int?> createdBy,
    });
typedef $$EventosCitaTableUpdateCompanionBuilder =
    EventosCitaCompanion Function({
      Value<int> id,
      Value<int> citaId,
      Value<String> tipoEvento,
      Value<String?> detalleJson,
      Value<int> createdAt,
      Value<int?> createdBy,
    });

final class $$EventosCitaTableReferences
    extends BaseReferences<_$AppDatabase, $EventosCitaTable, EventosCitaData> {
  $$EventosCitaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CitasTable _citaIdTable(_$AppDatabase db) =>
      db.citas.createAlias('eventos_cita__cita_id__citas__id');

  $$CitasTableProcessedTableManager get citaId {
    final $_column = $_itemColumn<int>('cita_id')!;

    final manager = $$CitasTableTableManager(
      $_db,
      $_db.citas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_citaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _createdByTable(_$AppDatabase db) =>
      db.usuarios.createAlias('eventos_cita__created_by__usuarios__id');

  $$UsuariosTableProcessedTableManager? get createdBy {
    final $_column = $_itemColumn<int>('created_by');
    if ($_column == null) return null;
    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventosCitaTableFilterComposer
    extends Composer<_$AppDatabase, $EventosCitaTable> {
  $$EventosCitaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoEvento => $composableBuilder(
    column: $table.tipoEvento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detalleJson => $composableBuilder(
    column: $table.detalleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CitasTableFilterComposer get citaId {
    final $$CitasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.citaId,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableFilterComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get createdBy {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosCitaTableOrderingComposer
    extends Composer<_$AppDatabase, $EventosCitaTable> {
  $$EventosCitaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoEvento => $composableBuilder(
    column: $table.tipoEvento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detalleJson => $composableBuilder(
    column: $table.detalleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CitasTableOrderingComposer get citaId {
    final $$CitasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.citaId,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableOrderingComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get createdBy {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosCitaTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventosCitaTable> {
  $$EventosCitaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoEvento => $composableBuilder(
    column: $table.tipoEvento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detalleJson => $composableBuilder(
    column: $table.detalleJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CitasTableAnnotationComposer get citaId {
    final $$CitasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.citaId,
      referencedTable: $db.citas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CitasTableAnnotationComposer(
            $db: $db,
            $table: $db.citas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get createdBy {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosCitaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventosCitaTable,
          EventosCitaData,
          $$EventosCitaTableFilterComposer,
          $$EventosCitaTableOrderingComposer,
          $$EventosCitaTableAnnotationComposer,
          $$EventosCitaTableCreateCompanionBuilder,
          $$EventosCitaTableUpdateCompanionBuilder,
          (EventosCitaData, $$EventosCitaTableReferences),
          EventosCitaData,
          PrefetchHooks Function({bool citaId, bool createdBy})
        > {
  $$EventosCitaTableTableManager(_$AppDatabase db, $EventosCitaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventosCitaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventosCitaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventosCitaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> citaId = const Value.absent(),
                Value<String> tipoEvento = const Value.absent(),
                Value<String?> detalleJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> createdBy = const Value.absent(),
              }) => EventosCitaCompanion(
                id: id,
                citaId: citaId,
                tipoEvento: tipoEvento,
                detalleJson: detalleJson,
                createdAt: createdAt,
                createdBy: createdBy,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int citaId,
                required String tipoEvento,
                Value<String?> detalleJson = const Value.absent(),
                required int createdAt,
                Value<int?> createdBy = const Value.absent(),
              }) => EventosCitaCompanion.insert(
                id: id,
                citaId: citaId,
                tipoEvento: tipoEvento,
                detalleJson: detalleJson,
                createdAt: createdAt,
                createdBy: createdBy,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventosCitaTable, EventosCitaData>(table),
                  $$EventosCitaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({citaId = false, createdBy = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (citaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.citaId,
                                referencedTable: $$EventosCitaTableReferences
                                    ._citaIdTable(db),
                                referencedColumn: $$EventosCitaTableReferences
                                    ._citaIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (createdBy) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.createdBy,
                                referencedTable: $$EventosCitaTableReferences
                                    ._createdByTable(db),
                                referencedColumn: $$EventosCitaTableReferences
                                    ._createdByTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventosCitaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventosCitaTable,
      EventosCitaData,
      $$EventosCitaTableFilterComposer,
      $$EventosCitaTableOrderingComposer,
      $$EventosCitaTableAnnotationComposer,
      $$EventosCitaTableCreateCompanionBuilder,
      $$EventosCitaTableUpdateCompanionBuilder,
      (EventosCitaData, $$EventosCitaTableReferences),
      EventosCitaData,
      PrefetchHooks Function({bool citaId, bool createdBy})
    >;
typedef $$AuditoriaTableCreateCompanionBuilder =
    AuditoriaCompanion Function({
      Value<int> id,
      Value<int?> userId,
      required String tabla,
      Value<int?> registroId,
      required String accion,
      Value<String?> valorAntes,
      Value<String?> valorDespues,
      Value<String?> motivo,
      required int fecha,
    });
typedef $$AuditoriaTableUpdateCompanionBuilder =
    AuditoriaCompanion Function({
      Value<int> id,
      Value<int?> userId,
      Value<String> tabla,
      Value<int?> registroId,
      Value<String> accion,
      Value<String?> valorAntes,
      Value<String?> valorDespues,
      Value<String?> motivo,
      Value<int> fecha,
    });

final class $$AuditoriaTableReferences
    extends BaseReferences<_$AppDatabase, $AuditoriaTable, AuditoriaData> {
  $$AuditoriaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsuariosTable _userIdTable(_$AppDatabase db) =>
      db.usuarios.createAlias('auditoria__user_id__usuarios__id');

  $$UsuariosTableProcessedTableManager? get userId {
    final $_column = $_itemColumn<int>('user_id');
    if ($_column == null) return null;
    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AuditoriaTableFilterComposer
    extends Composer<_$AppDatabase, $AuditoriaTable> {
  $$AuditoriaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tabla => $composableBuilder(
    column: $table.tabla,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valorAntes => $composableBuilder(
    column: $table.valorAntes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valorDespues => $composableBuilder(
    column: $table.valorDespues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  $$UsuariosTableFilterComposer get userId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditoriaTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditoriaTable> {
  $$AuditoriaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tabla => $composableBuilder(
    column: $table.tabla,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valorAntes => $composableBuilder(
    column: $table.valorAntes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valorDespues => $composableBuilder(
    column: $table.valorDespues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsuariosTableOrderingComposer get userId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditoriaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditoriaTable> {
  $$AuditoriaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tabla =>
      $composableBuilder(column: $table.tabla, builder: (column) => column);

  GeneratedColumn<int> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accion =>
      $composableBuilder(column: $table.accion, builder: (column) => column);

  GeneratedColumn<String> get valorAntes => $composableBuilder(
    column: $table.valorAntes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valorDespues => $composableBuilder(
    column: $table.valorDespues,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<int> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  $$UsuariosTableAnnotationComposer get userId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditoriaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditoriaTable,
          AuditoriaData,
          $$AuditoriaTableFilterComposer,
          $$AuditoriaTableOrderingComposer,
          $$AuditoriaTableAnnotationComposer,
          $$AuditoriaTableCreateCompanionBuilder,
          $$AuditoriaTableUpdateCompanionBuilder,
          (AuditoriaData, $$AuditoriaTableReferences),
          AuditoriaData,
          PrefetchHooks Function({bool userId})
        > {
  $$AuditoriaTableTableManager(_$AppDatabase db, $AuditoriaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditoriaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditoriaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditoriaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String> tabla = const Value.absent(),
                Value<int?> registroId = const Value.absent(),
                Value<String> accion = const Value.absent(),
                Value<String?> valorAntes = const Value.absent(),
                Value<String?> valorDespues = const Value.absent(),
                Value<String?> motivo = const Value.absent(),
                Value<int> fecha = const Value.absent(),
              }) => AuditoriaCompanion(
                id: id,
                userId: userId,
                tabla: tabla,
                registroId: registroId,
                accion: accion,
                valorAntes: valorAntes,
                valorDespues: valorDespues,
                motivo: motivo,
                fecha: fecha,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                required String tabla,
                Value<int?> registroId = const Value.absent(),
                required String accion,
                Value<String?> valorAntes = const Value.absent(),
                Value<String?> valorDespues = const Value.absent(),
                Value<String?> motivo = const Value.absent(),
                required int fecha,
              }) => AuditoriaCompanion.insert(
                id: id,
                userId: userId,
                tabla: tabla,
                registroId: registroId,
                accion: accion,
                valorAntes: valorAntes,
                valorDespues: valorDespues,
                motivo: motivo,
                fecha: fecha,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditoriaTable, AuditoriaData>(table),
                  $$AuditoriaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$AuditoriaTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$AuditoriaTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AuditoriaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditoriaTable,
      AuditoriaData,
      $$AuditoriaTableFilterComposer,
      $$AuditoriaTableOrderingComposer,
      $$AuditoriaTableAnnotationComposer,
      $$AuditoriaTableCreateCompanionBuilder,
      $$AuditoriaTableUpdateCompanionBuilder,
      (AuditoriaData, $$AuditoriaTableReferences),
      AuditoriaData,
      PrefetchHooks Function({bool userId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db, _db.usuarios);
  $$PermisosTableTableManager get permisos =>
      $$PermisosTableTableManager(_db, _db.permisos);
  $$ConfiguracionTableTableManager get configuracion =>
      $$ConfiguracionTableTableManager(_db, _db.configuracion);
  $$CitasTableTableManager get citas =>
      $$CitasTableTableManager(_db, _db.citas);
  $$DocumentosTableTableManager get documentos =>
      $$DocumentosTableTableManager(_db, _db.documentos);
  $$CorreosLogTableTableManager get correosLog =>
      $$CorreosLogTableTableManager(_db, _db.correosLog);
  $$EventosCitaTableTableManager get eventosCita =>
      $$EventosCitaTableTableManager(_db, _db.eventosCita);
  $$AuditoriaTableTableManager get auditoria =>
      $$AuditoriaTableTableManager(_db, _db.auditoria);
}
