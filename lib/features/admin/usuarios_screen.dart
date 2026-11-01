import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_strings.dart';

class UsuariosScreen extends ConsumerWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Usuarios')),
        body: const Center(child: Text(AppStrings.noPermission)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: const Center(child: Text('Usuarios — Parte 4')),
    );
  }
}
