import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/database/app_database.dart';
import '../providers/database_provider.dart';
import 'auth_state.dart';

const _kStorageKeyUserId = 'sgc_user_id';

class AuthNotifier extends Notifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  AppDatabase get _db => ref.read(databaseProvider);

  @override
  AuthState build() {
    _restoreSession();
    return const AuthState.loading();
  }

  Future<void> _restoreSession() async {
    try {
      final raw = await _storage.read(key: _kStorageKeyUserId);
      if (raw == null) {
        state = const AuthState.unauthenticated();
        return;
      }
      final userId = int.tryParse(raw);
      if (userId == null) {
        await _storage.delete(key: _kStorageKeyUserId);
        state = const AuthState.unauthenticated();
        return;
      }
      final user = await (_db.select(_db.usuarios)
            ..where((t) => t.id.equals(userId) & t.isDelete.equals(false)))
          .getSingleOrNull();
      if (user == null || !user.activo) {
        await _storage.delete(key: _kStorageKeyUserId);
        state = const AuthState.unauthenticated();
        return;
      }
      final rol = await (_db.select(_db.roles)
            ..where((t) => t.id.equals(user.rolId)))
          .getSingleOrNull();
      if (rol == null) {
        state = const AuthState.unauthenticated();
        return;
      }
      state = AuthState.authenticated(
        userId: user.id,
        username: user.username,
        nombreCompleto: user.nombreCompleto,
        rolNombre: rol.nombre,
        rolId: rol.id,
      );
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<String?> login(String username, String password) async {
    final hash = sha256.convert(utf8.encode(password)).toString();
    final user = await (_db.select(_db.usuarios)
          ..where((t) =>
              t.username.equals(username) &
              t.passwordHash.equals(hash) &
              t.isDelete.equals(false)))
        .getSingleOrNull();

    if (user == null) return 'Usuario o contraseña incorrectos.';
    if (!user.activo) return 'Usuario inactivo. Contacta al administrador.';

    final rol = await (_db.select(_db.roles)
          ..where((t) => t.id.equals(user.rolId)))
        .getSingleOrNull();
    if (rol == null) return 'Rol no encontrado. Contacta al administrador.';

    await _storage.write(key: _kStorageKeyUserId, value: user.id.toString());
    state = AuthState.authenticated(
      userId: user.id,
      username: user.username,
      nombreCompleto: user.nombreCompleto,
      rolNombre: rol.nombre,
      rolId: rol.id,
    );
    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: _kStorageKeyUserId);
    state = const AuthState.unauthenticated();
  }

  Future<String?> cambiarPassword(String actual, String nueva) async {
    if (state.status != AuthStatus.authenticated) {
      return 'Sesión no válida.';
    }
    final actualHash = sha256.convert(utf8.encode(actual)).toString();
    final user = await (_db.select(_db.usuarios)
          ..where((t) => t.id.equals(state.userId!)))
        .getSingleOrNull();
    if (user == null) return 'Usuario no encontrado.';
    if (user.passwordHash != actualHash) return 'Contraseña actual incorrecta.';
    final nuevoHash = sha256.convert(utf8.encode(nueva)).toString();
    await (_db.update(_db.usuarios)..where((t) => t.id.equals(user.id)))
        .write(UsuariosCompanion(passwordHash: Value(nuevoHash)));
    return null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
