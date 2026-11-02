import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../data/database/app_database.dart';

class PdfResult {
  final Uint8List bytes;
  final String nombreArchivo;
  PdfResult(this.bytes, this.nombreArchivo);
}

class PdfService {
  static Future<PdfResult> generarDocumentoResponsabilidad(Cita cita, {String? logoBase64}) async {
    final pdf = pw.Document();

    pw.MemoryImage? logo;
    if (logoBase64 != null && logoBase64.isNotEmpty) {
      try {
        final cleanBase64 = logoBase64.replaceAll(RegExp(r'\s+'), '');
        logo = pw.MemoryImage(base64Decode(cleanBase64));
      } catch (e) {
        debugPrint('Error al cargar el logo en el PDF: $e');
      }
    }

    // Formato de fecha: "Guatemala 02 de noviembre del 2026"
    final fechaFirma = DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma * 1000);
    final diaStr = DateFormat('dd').format(fechaFirma);
    final mesStr = DateFormat('MMMM', 'es').format(fechaFirma);
    final anioStr = DateFormat('yyyy').format(fechaFirma);
    final fechaStr = 'Guatemala $diaStr de $mesStr del $anioStr';

    // Convertir nombre a Title Case
    final nombreCamelCase = cita.personaNombre
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');

    // Tamaño de hoja 8.5 x 13 pulgadas
    final pageFormat = PdfPageFormat(8.5 * PdfPageFormat.inch, 13 * PdfPageFormat.inch);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        // MÁRGENES DE 1 PULGADA (72 puntos) A LOS LADOS
        margin: const pw.EdgeInsets.symmetric(horizontal: 72, vertical: 40),
        build: (pw.Context context) {
          return [
            // ENCABEZADO CON LOGO
            if (logo != null) ...[
              // LOGO 3 PUNTOS MÁS GRANDE (width: 160)
              pw.Center(child: pw.Image(logo, width: 160)),
              pw.SizedBox(height: 15),
            ],
            
            // TÍTULO DEL DEPARTAMENTO
            pw.Center(
              child: pw.Text(
                'Departamento de Reclutamiento, Selección y Contratos',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 30),

            // FECHA A LA DERECHA
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(fechaStr, style: const pw.TextStyle(fontSize: 11)),
            ),
            pw.SizedBox(height: 30),

            // CUERPO
            pw.Text(
              'Yo, ${nombreCamelCase.toUpperCase()}, quien me identifico con Documento Personal de Identificación (DPI) número ${cita.personaDpi ?? "—"}, en mi calidad de contratado, al suscribir el contrato respectivo, HAGO CONSTAR que he sido informado(a) por el Departamento de Reclutamiento, Selección y Contratación de lo siguiente:',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 15),
            
            // PUNTOS LEGALES
            pw.Text(
              '1. Que, de conformidad con los artículos 20 y 22 del Decreto 89-2002 del Congreso de la República, Ley de Probidad y Responsabilidades de Funcionarios y Empleados Públicos, y su Reglamento (Acuerdo Gubernativo 613-2005), la presentación de la Declaración Jurada Patrimonial ante la Contraloría General de Cuentas (CGC) es una obligación personal e indelegable de quien esté obligado conforme a la ley.',
              style: const pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '2. Que dicha declaración debe presentarse dentro de los treinta (30) días siguientes a la fecha de toma de posesión del cargo o empleo, plazo que la CGC puede ampliar, por un período igual, únicamente en casos excepcionales debidamente justificados.',
              style: const pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '3. Que la presentación se realiza en línea mediante el portal de la Contraloría General de Cuentas, y que es indispensable que me apersone a dicha institución para completar el trámite.',
              style: const pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '4. Que el incumplimiento de esta obligación genera responsabilidad administrativa, sancionable por la CGC conforme a los artículos 17 literal g) y 27 de la citada ley, y puede constituir el delito de incumplimiento del deber de presentar declaración jurada patrimonial, previsto en el artículo 419 Bis del Código Penal, sin perjuicio de otras responsabilidades que pudieran derivarse.',
              style: const pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '5. Que el contenido de la declaración es confidencial conforme al artículo 21 de la ley, por lo que la Dirección de Recursos Humanos no lo solicita ni tiene acceso a él.',
              style: const pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 20),

            // COMPROMISO
            pw.Text(
              'En consecuencia, ME COMPROMETO a presentar mi Declaración Jurada Patrimonial ante la Contraloría General de Cuentas dentro del plazo legal, y a entregar a este Departamento copia de la constancia de presentación dentro de los treinta (30) días siguientes a su presentación, a efecto de que sea incorporada a mi expediente personal.',
              style: const pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 20),
            
            // FRASE SOLICITADA EN NEGRITA Y CURSIVA
            pw.Text(
              'Asimismo, reconozco que cualquier omisión o retraso en el cumplimiento de esta obligación es responsabilidad exclusiva de mi persona.',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 60),

            // FIRMAS
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Container(width: 200, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text(nombreCamelCase, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text('DPI: ${cita.personaDpi ?? "—"}', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Firma', style: const pw.TextStyle(fontSize: 10)), // CAMBIO AQUÍ
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 200, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text('Departamento de Reclutamiento,', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Selección y Contratación', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    return PdfResult(Uint8List.fromList(bytes), 'Constancia_Responsabilidad_${cita.id}.pdf');
  }
}
