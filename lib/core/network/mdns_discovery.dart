import 'dart:async';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'bonjour_helper.dart';

class MdnsDiscovery {
  MdnsDiscovery._();

  static const String _serviceType = '_sgc._tcp';

  /// Busca el servidor SGC en la red local vía mDNS (Bonjour).
  ///
  /// Devuelve la IP (string) o `null` si:
  /// - no hay Bonjour disponible (Windows sin Bonjour),
  /// - no se encontró el servicio en [timeout],
  /// - todas las IPs encontradas son inválidas (loopback, link-local).
  static Future<String?> buscarServidor({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    // En Windows sin Bonjour, ni siquiera intentamos: falla en silencio.
    if (!await BonjourHelper.disponible()) {
      debugPrint('[mDNS] Bonjour no disponible en esta plataforma.');
      return null;
    }

    final completer = Completer<String?>();
    BonsoirDiscovery? discovery;
    StreamSubscription<BonsoirDiscoveryEvent>? sub;
    Timer? timer;

    Future<void> limpiar() async {
      timer?.cancel();
      timer = null;
      await sub?.cancel();
      sub = null;
      try {
        await discovery?.stop();
      } catch (_) {}
      discovery = null;
    }

    try {
      final d = BonsoirDiscovery(type: _serviceType);
      discovery = d;
      await d.initialize();

      sub = d.eventStream!.listen(
        (event) async {
          if (event is BonsoirDiscoveryServiceFoundEvent) {
            debugPrint('[mDNS] Encontrado: ${event.service.name}');
            try {
              await event.service.resolve(d.serviceResolver);
            } catch (e) {
              debugPrint('[mDNS] Error resolviendo: $e');
            }
          } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
            final service = event.service;
            debugPrint(
                '[mDNS] Resuelto: ${service.name} -> ${service.hostAddresses}');

            // Filtrar IPs válidas de LAN; descartar loopback y link-local.
            final ipValida = service.hostAddresses
                .map(_limpiarIp)
                .where(_esIpDeLan)
                .cast<String?>()
                .firstWhere((ip) => ip != null, orElse: () => null);

            if (ipValida != null && !completer.isCompleted) {
              debugPrint('[mDNS] IP válida elegida: $ipValida');
              completer.complete(ipValida);
            }
          }
        },
        onError: (Object e, StackTrace st) {
          debugPrint('[mDNS] Stream error: $e');
          if (!completer.isCompleted) completer.complete(null);
        },
      );

      await d.start();

      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          debugPrint('[mDNS] Timeout (${timeout.inSeconds}s) sin respuesta.');
          completer.complete(null);
        }
      });

      return await completer.future;
    } catch (e, st) {
      debugPrint('[mDNS] Fatal: $e\n$st');
      if (!completer.isCompleted) completer.complete(null);
      return completer.future;
    } finally {
      await limpiar();
    }
  }

  /// Quita sufijos raros (`%en0`) y espacios que a veces trae bonsoir.
  static String _limpiarIp(String raw) {
    final s = raw.trim();
    final i = s.indexOf('%');
    return i >= 0 ? s.substring(0, i) : s;
  }

  /// Verdadero solo para IPv4 de LAN privada:
  /// 10.x.x.x, 172.16-31.x.x, 192.168.x.x.
  /// Descarta 127.x, 169.254.x, 0.x, y cualquier IPv6.
  static bool _esIpDeLan(String ip) {
    final partes = ip.split('.');
    if (partes.length != 4) return false;
    final nums = <int>[];
    for (final p in partes) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
      nums.add(n);
    }
    final a = nums[0], b = nums[1];
    if (a == 10) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    if (a == 192 && b == 168) return true;
    return false;
  }
}
