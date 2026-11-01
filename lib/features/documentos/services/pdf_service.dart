import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfResult {
  final List<int> bytes;
  final String nombreArchivo;
  const PdfResult({required this.bytes, required this.nombreArchivo});
}

class PdfService {
  Future<PdfResult> generarDocumentoResponsabilidad({
    required String nombreFirmante,
    required String dpi,
    required String correo,
    required String fechaFirma,
    required String textoLegal,
    required String textoMulta,
    required String empresaNombre,
    required String empresaNit,
    String? logoBase64,
  }) async {
    final doc = pw.Document();
    final pageFormat = PdfPageFormat.letter;

    pw.MemoryImage? logo;
    if (logoBase64 != null && logoBase64.isNotEmpty) {
      try {
        logo = pw.MemoryImage(base64Decode(logoBase64));
      } catch (_) {}
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(48),
        header: (ctx) => _header(logo, empresaNombre, empresaNit),
        footer: (ctx) => _footer(ctx),
        build: (ctx) => [
          pw.SizedBox(height: 16),
          pw.Text(
            'DOCUMENTO DE RESPONSABILIDAD',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Yo, $nombreFirmante, con DPI $dpi, correo $correo, en fecha '
            '$fechaFirma, declaro lo siguiente:',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            textoLegal,
            style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            textoMulta,
            style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
          ),
          pw.SizedBox(height: 48),
          _firmaBox(),
          pw.SizedBox(height: 16),
          pw.Text(
            'Nombre: $nombreFirmante',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            'DPI: $dpi',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            'Fecha: $fechaFirma',
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    return PdfResult(
      bytes: bytes,
      nombreArchivo: 'documento_responsabilidad_$dpi.pdf',
    );
  }

  pw.Widget _header(pw.MemoryImage? logo, String empresa, String nit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logo != null)
              pw.Container(
                width: 60,
                height: 60,
                child: pw.Image(logo),
              ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    empresa.isEmpty ? 'SGC' : empresa,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (nit.isNotEmpty)
                    pw.Text(
                      'NIT: $nit',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _footer(pw.Context ctx) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text(
          'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _firmaBox() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 60),
        pw.Container(
          width: 280,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(width: 1),
            ),
          ),
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text(
            'Firma del contratado',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
