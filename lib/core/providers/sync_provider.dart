import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/network_config.dart';
import '../network/websocket_sync_service.dart';
import 'database_provider.dart';

final apiClientProvider = FutureProvider<ApiClient?>((ref) async {
  final cfg = await ref.watch(networkConfigProvider.future);
  if (!cfg.configurado) return null;
  return ApiClient(cfg);
});

final syncServiceProvider = FutureProvider<WebSocketSyncService?>((ref) async {
  final cfg = await ref.watch(networkConfigProvider.future);
  if (cfg.esServidor) return null;
  final api = await ref.watch(apiClientProvider.future);
  if (api == null) return null;
  final svc = WebSocketSyncService(
    config: cfg,
    db: ref.watch(databaseProvider),
    api: api,
  );
  svc.start();
  ref.onDispose(svc.dispose);
  return svc;
});
