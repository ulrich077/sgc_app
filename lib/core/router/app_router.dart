import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_state.dart';
import '../../core/layout/app_shell.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/admin/admin_settings_screen.dart';
import '../../features/admin/usuarios_screen.dart';
import '../../features/admin/auditoria_screen.dart';
import '../../features/citas/screens/cita_detalle_screen.dart';
import '../../features/citas/screens/citas_screen.dart';
import '../../features/citas/screens/kanban_screen.dart';
import '../../features/citas/screens/firmas_enviadas_screen.dart';
import '../../features/reportes/screens/reportes_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<AuthState>(ref.read(authProvider));
  ref.listen<AuthState>(authProvider, (_, next) {
    notifier.value = next;
  });
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = notifier.value;
      final loc = state.matchedLocation;

      if (auth.status == AuthStatus.loading) {
        return loc == '/splash' ? null : '/splash';
      }

      final loggedIn = auth.status == AuthStatus.authenticated;

      if (!loggedIn) {
        return loc == '/login' ? null : '/login';
      }

      if (loc == '/login' || loc == '/splash') {
        return auth.isAdmin ? '/admin-settings' : '/dashboard';
      }

      final isAdminRoute = loc.startsWith('/admin-settings') ||
          loc.startsWith('/usuarios') ||
          loc.startsWith('/auditoria');

      if (isAdminRoute && !auth.isAdmin) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // ENVOLVEMOS TODAS LAS RUTAS INTERNAS EN EL SHELL
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/admin-settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
          GoRoute(
            path: '/usuarios',
            builder: (context, state) => const UsuariosScreen(),
          ),
          GoRoute(
            path: '/auditoria',
            builder: (context, state) => const AuditoriaScreen(),
          ),
          GoRoute(
            path: '/citas',
            builder: (context, state) => const CitasScreen(),
          ),
          GoRoute(
            path: '/citas/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return CitaDetalleScreen(citaId: id);
            },
          ),
          GoRoute(
            path: '/kanban',
            builder: (context, state) => const KanbanScreen(),
          ),
          GoRoute(
            path: '/firmas-enviadas',
            builder: (context, state) => const FirmasEnviadasScreen(),
          ),
          GoRoute(
            path: '/reportes',
            builder: (context, state) => const ReportesScreen(),
          ),
        ],
      ),
    ],
  );
});
