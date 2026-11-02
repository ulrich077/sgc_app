import '../../documentos/services/placeholder_resolver.dart';
import '../../../data/database/app_database.dart';
import '../domain/correo_tipo.dart';

class EmailDispatcher {
  /// Construye el cuerpo del correo resolviendo placeholders de la plantilla.
  static String resolverPlantilla({
    required String plantilla,
    required Cita cita,
    required Map<String, String> config,
    String? motivo,
    String? enlaceConfirmacion,
    String? nuevaFecha,
  }) {
    final diasCgc = int.tryParse(config['dias_limite_cgc'] ?? '') ?? 30;
    
    // REGLA VI: La DB guarda segundos, multiplicamos por 1000 para milisegundos.
    final fechaFirma = DateTime.fromMillisecondsSinceEpoch(
            cita.fechaHoraFirma * 1000)
        .toLocal();
        
    final fechaStr =
        '${fechaFirma.day.toString().padLeft(2, '0')}/'
        '${fechaFirma.month.toString().padLeft(2, '0')}/'
        '${fechaFirma.year}';

    final horaStr = '${fechaFirma.hour.toString().padLeft(2, '0')}:${fechaFirma.minute.toString().padLeft(2, '0')}';

    var cuerpo = PlaceholderResolver.resolver(
      plantilla,
      nombre: cita.personaNombre,
      dpi: cita.personaDpi,
      correo: cita.personaCorreo,
      fecha: nuevaFecha ?? fechaStr,
      hora: horaStr, // <-- AGREGAMOS LA HORA
      diasCgc: diasCgc,
      empresaNombre: config['empresa_nombre'] ?? '',
    );

    if (motivo != null) {
      cuerpo = cuerpo.replaceAll('{{motivo}}', motivo);
    }
    if (enlaceConfirmacion != null) {
      cuerpo = cuerpo.replaceAll('{{enlace_confirmacion}}', enlaceConfirmacion);
    }
    return cuerpo;
  }

  static String asuntoPara(CorreoTipo tipo, {String empresa = 'SGC'}) {
    switch (tipo) {
      case CorreoTipo.prueba:
        return '$empresa - Confirma tu correo — Cita de firma';
      case CorreoTipo.confirmacion:
        return '$empresa - Correo confirmado';
      case CorreoTipo.reagenda:
        return '$empresa - Cita reagendada';
      case CorreoTipo.final_:
        return '$empresa - Contrato firmado y Documento de Responsabilidad';
      case CorreoTipo.recordatorio:
        return '$empresa - Recordatorio: apersonarse a la CGC';
    }
  }

  static CorreoTipo tipoFromEstado(String estado) {
    switch (estado) {
      case 'CORREO_CONFIRMADO':
        return CorreoTipo.confirmacion;
      case 'REAGENDADA':
        return CorreoTipo.reagenda;
      case 'CONTRATO_ENVIADO':
        return CorreoTipo.final_;
      default:
        return CorreoTipo.prueba;
    }
  }
}
