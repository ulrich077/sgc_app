import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StoredFile {
  final String rutaAbsoluta;
  final String nombre;
  final String hashSha256;
  final int tamanoBytes;
  final String? mimeType;

  const StoredFile({
    required this.rutaAbsoluta,
    required this.nombre,
    required this.hashSha256,
    required this.tamanoBytes,
    this.mimeType,
  });
}

class FileStorageService {
  /// Copia el archivo origen a la carpeta de la cita y calcula hash.
  Future<StoredFile> guardarEscaneo({
    required String origenPath,
    required int citaId,
    required String nombreOriginal,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final destinoDir = Directory(
        p.join(docsDir.path, 'escaneos', citaId.toString()));
    if (!await destinoDir.exists()) {
      await destinoDir.create(recursive: true);
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nombreSeguro = nombreOriginal.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    final destinoPath =
        p.join(destinoDir.path, '${timestamp}_$nombreSeguro');

    final origen = File(origenPath);
    final bytes = await origen.readAsBytes();
    final destino = File(destinoPath);
    await destino.writeAsBytes(bytes);

    final hash = sha256.convert(bytes).toString();
    final mime = _guessMime(nombreOriginal);

    return StoredFile(
      rutaAbsoluta: destinoPath,
      nombre: nombreOriginal,
      hashSha256: hash,
      tamanoBytes: bytes.length,
      mimeType: mime,
    );
  }

  Future<StoredFile> guardarBytes({
    required List<int> bytes,
    required int citaId,
    required String nombre,
    String? mimeType,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final destinoDir = Directory(
        p.join(docsDir.path, 'escaneos', citaId.toString()));
    if (!await destinoDir.exists()) {
      await destinoDir.create(recursive: true);
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nombreSeguro = nombre.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    final destinoPath =
        p.join(destinoDir.path, '${timestamp}_$nombreSeguro');
    final destino = File(destinoPath);
    await destino.writeAsBytes(bytes);
    final hash = sha256.convert(bytes).toString();
    return StoredFile(
      rutaAbsoluta: destinoPath,
      nombre: nombre,
      hashSha256: hash,
      tamanoBytes: bytes.length,
      mimeType: mimeType ?? _guessMime(nombre),
    );
  }

  String? _guessMime(String nombre) {
    final ext = p.extension(nombre).toLowerCase();
    switch (ext) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return null;
    }
  }
}
