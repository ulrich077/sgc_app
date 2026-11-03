import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CertService {
  CertService._();

  static const String _carpetaCerts = 'certs';
  static const String _nombreCert = 'sgc_cert.pem';
  static const String _nombreKey = 'sgc_key.pem';
  static const int _diasValidez = 3650;

  static Future<Directory> _carpeta() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/$_carpetaCerts');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<bool> existe() async {
    final dir = await _carpeta();
    return File('${dir.path}/$_nombreCert').existsSync() &&
        File('${dir.path}/$_nombreKey').existsSync();
  }

  static Future<String?> rutaCert() async {
    final dir = await _carpeta();
    final f = File('${dir.path}/$_nombreCert');
    return f.existsSync() ? f.path : null;
  }

  static Future<String?> rutaKey() async {
    final dir = await _carpeta();
    final f = File('${dir.path}/$_nombreKey');
    return f.existsSync() ? f.path : null;
  }

  static Future<void> generar() async {
    final dir = await _carpeta();
    final certFile = File('${dir.path}/$_nombreCert');
    final keyFile = File('${dir.path}/$_nombreKey');

    final keyPair = CryptoUtils.generateRSAKeyPair();
    final privateKey = keyPair.privateKey as RSAPrivateKey;
    final publicKey = keyPair.publicKey as RSAPublicKey;

    final attrs = <String, String>{
      'CN': 'SGC-Server',
      'O': 'Congreso',
      'C': 'GT',
    };

    final sans = <String>['localhost', '127.0.0.1'];
    final ip = await _ipLan();
    if (ip != null && !sans.contains(ip)) sans.add(ip);

    final csr = X509Utils.generateRsaCsrPem(attrs, privateKey, publicKey, san: sans);
    final certPem = X509Utils.generateSelfSignedCertificate(
      privateKey, csr, _diasValidez, sans: sans,
    );

    await certFile.writeAsString(certPem);
    await keyFile.writeAsString(CryptoUtils.encodeRSAPrivateKeyToPem(privateKey));

    debugPrint('[CertService] Certificado generado en ${dir.path}');
    debugPrint('[CertService] SANs: $sans');
  }

  static Future<void> borrar() async {
    final dir = await _carpeta();
    for (final f in [
      File('${dir.path}/$_nombreCert'),
      File('${dir.path}/$_nombreKey'),
    ]) {
      if (f.existsSync()) await f.delete();
    }
  }

  static Future<String?> _ipLan() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (_esIpDeLan(addr.address)) return addr.address;
        }
      }
    } catch (e) {
      debugPrint('[CertService] Error IP LAN: $e');
    }
    return null;
  }

  static bool _esIpDeLan(String ip) {
    final p = ip.split('.');
    if (p.length != 4) return false;
    final nums = p.map(int.tryParse).toList();
    if (nums.any((n) => n == null)) return false;
    final a = nums[0]!, b = nums[1]!;
    if (a == 10) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    if (a == 192 && b == 168) return true;
    return false;
  }

  /// Devuelve informacion del certificado actual (o null si no existe).
  static Future<({String rutaCert, DateTime generadoEn, DateTime validoHasta})?>
      info() async {
    final dir = await _carpeta();
    final certFile = File('${dir.path}/$_nombreCert');
    if (!certFile.existsSync()) return null;

    final stat = certFile.statSync();
    DateTime? validoHasta;
    try {
      final pem = await certFile.readAsString();
      final data = X509Utils.x509CertificateFromPem(pem);
      validoHasta = data.tbsCertificate?.validity.notAfter;
    } catch (e) {
      debugPrint('[CertService] Error parseando cert: $e');
    }

    return (
      rutaCert: certFile.path,
      generadoEn: stat.modified,
      validoHasta: validoHasta ?? stat.modified.add(const Duration(days: 3650)),
    );
  }
}
