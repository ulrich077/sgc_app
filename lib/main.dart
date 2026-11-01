import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/providers/database_provider.dart';
import 'core/providers/theme_colors_provider.dart';
import 'core/router/app_router.dart';
import 'features/wizard/primer_arranque_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SgcApp()));
}

class SgcApp extends ConsumerWidget {
  const SgcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final colorsAsync = ref.watch(themeColorsProvider);
    final colors = colorsAsync.maybeWhen(
      data: (c) => c,
      orElse: () => ThemeColors.defaults,
    );

    final wizardAsync = ref.watch(_wizardGateProvider);

    return wizardAsync.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('Error: $e'))),
      ),
      data: (completado) {
        if (!completado) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: PrimerArranqueScreen(),
          );
        }
        return MaterialApp.router(
          title: AppStrings.appFullName,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: colors.primary,
              secondary: colors.secondary,
            ),
            scaffoldBackgroundColor: AppColors.background,
          ),
        );
      },
    );
  }
}

final _wizardGateProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final row = await (db.select(db.configuracion)
        ..where((t) => t.clave.equals('wizard_completado')))
      .getSingleOrNull();
  return row?.valor == 'true';
});
