import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_page_header.dart';

class AuditoriaScreen extends ConsumerWidget {
  const AuditoriaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Auditoría')),
        body: const Center(child: Text(AppStrings.noPermission)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Auditoría')),
      body: ListView(
        children: const [
          AppPageHeader(
            title: 'Auditoría',
            subtitle: 'Registro inmutable de acciones',
          ),
          Padding(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Center(child: Text('Auditoría — Fase 6')),
          ),
        ],
      ),
    );
  }
}
