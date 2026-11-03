import 'dart:io';
import 'package:flutter/foundation.dart';

/// Utilidades para saber si el descubrimiento mDNS (Bonjour) está
/// disponible en la plataforma actual.
///
/// - macOS / iOS / Linux: mDNS es nativo → siempre disponible.
/// - Windows: requiere el servicio "Bonjour Service" instalado
///   (viene con iTunes o con "Bonjour Print Services" de Apple).
///   Si no está, `bonsoir` falla en silencio.
class BonjourHelper {
  BonjourHelper._();

  /// Devuelve `true` si el descubrimiento mDNS puede intentarse.
  /// En Windows consulta el servicio "Bonjour Service" con `sc query`.
  static Future<bool> disponible() async {
    if (!Platform.isWindows) return true;

    try {
      final result = await Process.run(
        'sc',
        ['query', 'Bonjour Service'],
        runInShell: true,
      );
      final out = '${result.stdout}\n${result.stderr}'.toUpperCase();
      final ok = result.exitCode == 0 &&
          out.contains('RUNNING') &&
          !out.contains('FAILED');
      if (!ok) {
        debugPrint('[Bonjour] Servicio no disponible en Windows.');
      }
      return ok;
    } catch (e) {
      debugPrint('[Bonjour] Error consultando servicio: $e');
      return false;
    }
  }

  /// Mensaje honesto para mostrar al usuario cuando no hay Bonjour.
  static String get mensajeNoDisponible =>
      'La búsqueda automática no está disponible en este equipo.\n'
      'En Windows requiere instalar "Bonjour Print Services" (gratis, de Apple).\n'
      'Mientras tanto, ingresa la IP del servidor manualmente.';
}
