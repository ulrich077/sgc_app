import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_state.dart';
import '../constants/app_sizes.dart';
import '../providers/theme_colors_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final colors = ref.watch(themeColorsProvider).maybeWhen(
          data: (c) => c,
          orElse: () => ThemeColors.defaults,
        );
    final items = _menuItems(auth);
    final currentPath = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          // MENÚ LATERAL PREMIUM
          Container(
            width: 250,
            color: colors.primary, // Fondo con el color primario
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg, AppSizes.xl, AppSizes.lg, AppSizes.lg),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1), // Un tono más oscuro
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.admin_panel_settings_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 28),
                          const SizedBox(width: AppSizes.sm),
                          const Text(
                            'SGC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        auth.nombreCompleto ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        auth.rolNombre ?? '',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // Lista de opciones
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm, vertical: AppSizes.md),
                    children: items.map((item) {
                      final selected = currentPath == item.path;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.xs),
                        // Envolvemos en Material para que las ondas de clic funcionen
                        child: Material(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSizes.md),
                          child: ListTile(
                            leading: Icon(
                              item.icon,
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.6),
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: selected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.md),
                            ),
                            onTap: () => context.go(item.path),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Botón de cerrar sesión
                Padding(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text('Cerrar sesión',
                          style: TextStyle(color: Colors.white)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.md),
                      ),
                      onTap: () => ref.read(authProvider.notifier).logout(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divisor
          VerticalDivider(
            width: 1,
            color: Colors.black.withValues(alpha: 0.1),
          ),
          // Contenido
          Expanded(child: child),
        ],
      ),
    );
  }

  List<_MenuItem> _menuItems(AuthState auth) {
    if (auth.isAdmin) {
      return const [
        _MenuItem('/dashboard', 'Dashboard', Icons.dashboard),
        _MenuItem('/citas', 'Citas', Icons.event_note),
        _MenuItem('/kanban', 'Kanban', Icons.view_kanban),
        _MenuItem('/firmas-enviadas', 'Firmas enviadas', Icons.mark_email_read),
        _MenuItem('/reportes', 'Reportes', Icons.bar_chart),
        _MenuItem('/admin-settings', 'Ajustes', Icons.tune),
        _MenuItem('/usuarios', 'Usuarios', Icons.people),
        _MenuItem('/auditoria', 'Auditoría', Icons.history),
      ];
    }
    return const [
      _MenuItem('/dashboard', 'Dashboard', Icons.dashboard),
      _MenuItem('/citas', 'Citas', Icons.event_note),
      _MenuItem('/kanban', 'Kanban', Icons.view_kanban),
      _MenuItem('/firmas-enviadas', 'Firmas enviadas', Icons.mark_email_read),
      _MenuItem('/reportes', 'Reportes', Icons.bar_chart),
    ];
  }
}

class _MenuItem {
  final String path;
  final String label;
  final IconData icon;
  const _MenuItem(this.path, this.label, this.icon);
}
