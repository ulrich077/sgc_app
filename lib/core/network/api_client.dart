import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'network_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final NetworkConfig config;
  final http.Client _client;

  ApiClient(this.config)
      : _client = IOClient(
          HttpClient()
            ..badCertificateCallback = (cert, host, port) => true,
        );

  Future<Map<String, dynamic>> _get(String path) async {
    final res = await _client.get(Uri.parse('${config.baseHttp}$path'));
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<dynamic> _getList(String path) async {
    final res = await _client.get(Uri.parse('${config.baseHttp}$path'));
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final res = await _client.post(
      Uri.parse('${config.baseHttp}$path'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _patch(
      String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse('${config.baseHttp}$path'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> health() => _get('/api/health');

  Future<List<dynamic>> listarCitas() async =>
      await _getList('/api/citas') as List<dynamic>;

  Future<Map<String, dynamic>> crearCita(Map<String, dynamic> payload) =>
      _post('/api/citas', payload);

  Future<Map<String, dynamic>> actualizarCita(
          int id, Map<String, dynamic> payload) =>
      _patch('/api/citas/$id', payload);

  Future<Map<String, dynamic>> subirDocumento({
    required int citaId,
    required String tipo,
    required int userId,
    required List<int> bytes,
    required String nombreArchivo,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('${config.baseHttp}/api/documentos/upload'),
    );
    req.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: nombreArchivo,
    ));
    req.fields['meta'] = jsonEncode({
      'citaId': citaId,
      'tipo': tipo,
      'userId': userId,
    });
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> listarDocumentos(int citaId) async =>
      await _getList('/api/documentos/$citaId') as List<dynamic>;

  Future<Map<String, dynamic>> encolarCorreo(
          Map<String, dynamic> payload) =>
      _post('/api/correos/encolar', payload);

  Future<List<dynamic>> listarCorreos() async =>
      await _getList('/api/correos') as List<dynamic>;

  Future<List<int>> descargarPdfResponsabilidad(int citaId) async {
    final res = await _client.post(
      Uri.parse('${config.baseHttp}/api/citas/$citaId/pdf'),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    return res.bodyBytes;
  }
}
