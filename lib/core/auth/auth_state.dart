import 'package:flutter/foundation.dart';

enum AuthStatus { loading, unauthenticated, authenticated }

@immutable
class AuthState {
  final AuthStatus status;
  final int? userId;
  final String? username;
  final String? nombreCompleto;
  final String? rolNombre;
  final int? rolId;

  const AuthState({
    this.status = AuthStatus.loading,
    this.userId,
    this.username,
    this.nombreCompleto,
    this.rolNombre,
    this.rolId,
  });

  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.unauthenticated()
      : this(status: AuthStatus.unauthenticated);

  const AuthState.authenticated({
    required int userId,
    required String username,
    required String nombreCompleto,
    required String rolNombre,
    required int rolId,
  }) : this(
          status: AuthStatus.authenticated,
          userId: userId,
          username: username,
          nombreCompleto: nombreCompleto,
          rolNombre: rolNombre,
          rolId: rolId,
        );

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAdmin => rolNombre == 'administrador';
  bool get isOperador => rolNombre == 'operador';

  AuthState copyWith({
    AuthStatus? status,
    int? userId,
    String? username,
    String? nombreCompleto,
    String? rolNombre,
    int? rolId,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      rolNombre: rolNombre ?? this.rolNombre,
      rolId: rolId ?? this.rolId,
    );
  }
}
