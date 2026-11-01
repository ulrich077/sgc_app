import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_state.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../widgets/responsive.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isMobile = Responsive.isMobile(context);

    final items = _menuItems(auth);
    final currentPath = GoRouterState.of(context).matchedLocation;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SGC'),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: _SidebarContent(
            items: items,
            currentPath: currentPath,
            auth: auth,
          ),
        ),
        body: child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: _SidebarContent(
              items: items,
              currentPath: currentPath,
              auth: auth,
            ),
          ),
          const VerticalDivider(width: 1),
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

class _SidebarContent extends ConsumerWidget {
  final List<_MenuItem> items;
  final String currentPath;
  final AuthState auth;

  const _SidebarContent({
    required this.items,
    required this.currentPath,
    required this.auth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            color: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SGC',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSizes.xs),
                Text(
                  auth.nombreCompleto ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  auth.rolNombre ?? '',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: items.map((item) {
                final selected = currentPath == item.path ||
                    currentPath.startsWith('${item.path}/');
                return ListTile(
                  leading: Icon(item.icon,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  selected: selected,
                  selectedTileColor:
                      AppColors.primary.withValues(alpha: 0.08),
                  onTap: () {
                    if (Responsive.isMobile(context)) {
                      Navigator.of(context).pop();
                    }
                    if (currentPath != item.path) {
                      context.go(item.path);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text('Cerrar sesión',
                style: TextStyle(color: AppColors.danger)),
            onTap: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
