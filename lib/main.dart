import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_colors_provider.dart';
import 'core/providers/database_provider.dart';
import 'server/sgc_server.dart';
import 'server/email_queue_worker.dart';

// Variables globales para las instancias del servidor y worker
SgcServer? globalServerInstance;
EmailQueueWorker? globalWorkerInstance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('es_ES', null);

  runApp(
    const ProviderScope(
      child: ServerBootGate(),
    ),
  );
}

class ServerBootGate extends ConsumerStatefulWidget {
  const ServerBootGate({super.key});

  @override
  ConsumerState<ServerBootGate> createState() => _ServerBootGateState();
}

class _ServerBootGateState extends ConsumerState<ServerBootGate> {
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final db = ref.read(databaseProvider);
      final config = await (db.select(db.configuracion)..where((t) => t.clave.equals('es_servidor'))).getSingleOrNull();
      
      final isServer = config?.valor == 'true';

      if (isServer) {
        debugPrint('🚀 Iniciando SGC en modo SERVIDOR...');
        final server = SgcServer(db);
        await server.start(host: '0.0.0.0', port: 8080);
        
        final worker = EmailQueueWorker(db);
        worker.start(intervalo: const Duration(seconds: 5));
        
        globalServerInstance = server;
        globalWorkerInstance = worker;
        
        debugPrint('✅ Servidor y Worker de correos iniciados.');
      } else {
        debugPrint('💻 Iniciando SGC en modo CLIENTE...');
      }
    } catch (e) {
      debugPrint('❌ Error al iniciar el servidor: $e');
    } finally {
      if (mounted) setState(() => _booting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return const SgcApp();
  }
}

class SgcApp extends ConsumerWidget {
  const SgcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColorsAsync = ref.watch(themeColorsProvider);
    final router = ref.watch(routerProvider);

    return themeColorsAsync.when(
      loading: () => const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator()))),
      error: (e, _) => MaterialApp(home: Scaffold(body: Center(child: Text('Error: $e')))),
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
          // AGREGAMOS LOS DELEGADOS Y EL IDIOMA
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],
          locale: const Locale('es', 'ES'),
        );
      },
    );
  }
}
