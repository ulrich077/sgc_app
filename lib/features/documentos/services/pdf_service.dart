import 'dart:typed_data';
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
  static Future<PdfResult> generarDocumentoResponsabilidad(Cita cita) async {
    final pdf = pw.Document();
    final fechaStr = DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(cita.fechaHoraFirma * 1000));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('CONGRESO DE LA REPÚBLICA DE GUATEMALA', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Dirección de Recursos Humanos', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('Departamento de Reclutamiento, Selección y Contratación', style: const pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 20),
                  pw.Text('CONSTANCIA DE NOTIFICACIÓN Y COMPROMISO', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Presentación de Declaración Jurada Patrimonial', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Text('Lugar y fecha: Guatemala, $fechaStr', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 20),
            pw.Text(
              'Yo, ${cita.personaNombre}, quien me identifico con Documento Personal de Identificación (DPI) número ${cita.personaDpi ?? "—"}, en mi calidad de colaborador, al suscribir el contrato respectivo, HAGO CONSTAR que he sido informado(a) por el Departamento de Reclutamiento, Selección y Contratación de lo siguiente:',
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 15),
            pw.Text(
              '1. Que, de conformidad con los artículos 20 y 22 del Decreto 89-2002 del Congreso de la República, Ley de Probidad y Responsabilidades de Funcionarios y Empleados Públicos, y su Reglamento (Acuerdo Gubernativo 613-2005), la presentación de la Declaración Jurada Patrimonial ante la Contraloría General de Cuentas (CGC) es una obligación personal e indelegable de quien esté obligado conforme a la ley.',
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '2. Que dicha declaración debe presentarse dentro de los treinta (30) días siguientes a la fecha de toma de posesión del cargo o empleo, plazo que la CGC puede ampliar, por un período igual, únicamente en casos excepcionales debidamente justificados.',
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '3. Que la presentación se realiza en línea mediante el portal de la Contraloría General de Cuentas, y que es indispensable que me apersone a dicha institución para completar el trámite.',
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '4. Que el incumplimiento de esta obligación genera responsabilidad administrativa, sancionable por la CGC conforme a los artículos 17 literal g) y 27 de la citada ley, y puede constituir el delito de incumplimiento del deber de presentar declaración jurada patrimonial, previsto en el artículo 419 Bis del Código Penal, sin perjuicio de otras responsabilidades que pudieran derivarse.',
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '5. Que el contenido de la declaración es confidencial conforme al artículo 21 de la ley, por lo que la Dirección de Recursos Humanos no lo solicita ni tiene acceso a él.',
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'En consecuencia, ME COMPROMETO a presentar mi Declaración Jurada Patrimonial ante la Contraloría General de Cuentas dentro del plazo legal, y a entregar a este Departamento copia de la constancia de presentación dentro de los treinta (30) días siguientes a su presentación, a efecto de que sea incorporada a mi expediente personal.',
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Asimismo, reconozco que cualquier omisión o retraso en el cumplimiento de esta obligación es responsabilidad exclusiva de mi persona.',
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 60),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Container(width: 200, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text(cita.personaNombre, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text('DPI: ${cita.personaDpi ?? "—"}', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Firma del(a) declarante', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 200, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text('Departamento de Reclutamiento,', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
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
