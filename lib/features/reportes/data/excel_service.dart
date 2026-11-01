import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../../data/database/app_database.dart';
import '../../citas/domain/cita_estado.dart';

class ExcelService {
  /// Genera un Excel con el listado de citas y lo guarda en `rutaSalida`.
  Future<File> generarCitas({
    required List<Cita> citas,
    required String rutaSalida,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Citas'];
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nombre'),
      TextCellValue('DPI'),
      TextCellValue('Correo'),
      TextCellValue('Teléfono'),
      TextCellValue('Fecha firma'),
      TextCellValue('Estado'),
      TextCellValue('Post Mortem'),
      TextCellValue('Contraloría'),
      TextCellValue('Reagendada'),
    ]);

    for (final c in citas) {
      sheet.appendRow([
        IntCellValue(c.id),
        TextCellValue(c.personaNombre),
        TextCellValue(c.personaDpi ?? ''),
        TextCellValue(c.personaCorreo),
        TextCellValue(c.personaTelefono ?? ''),
        TextCellValue(dateFmt.format(
            DateTime.fromMillisecondsSinceEpoch(c.fechaHoraFirma))),
        TextCellValue(CitaEstado.fromDb(c.estado).label),
        TextCellValue(c.postMortemPresentado ? 'Sí' : 'No'),
        TextCellValue(c.contraloriaPresentada ? 'Sí' : 'No'),
        TextCellValue(c.reagendadaVeces.toString()),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception('No se pudo generar el Excel');
    final file = File(rutaSalida);
    await file.writeAsBytes(bytes);
    return file;
  }
}
