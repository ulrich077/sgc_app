import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_colors_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar los datos de idioma para el calendario y las fechas
  await initializeDateFormatting('es_ES', null);

  runApp(
    const ProviderScope(
      child: SgcApp(),
    ),
  );
}

class SgcApp extends ConsumerWidget {
  const SgcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColorsAsync = ref.watch(themeColorsProvider);
    // Aquí usamos el provider del router que ya tenías
    final router = ref.watch(routerProvider); 

    return themeColorsAsync.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $e'))),
      ),
      data: (colors) {
        return MaterialApp.router(
          title: 'SGC',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: colors.primary,
              primary: colors.primary,
              secondary: colors.secondary,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          ),
          routerConfig: router,
        );
      },
    );
  }
}
