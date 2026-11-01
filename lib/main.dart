import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/providers/theme_colors_provider.dart';
import 'core/router/app_router.dart';

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
  }
}
