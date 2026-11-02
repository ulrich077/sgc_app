class PlaceholderResolver {
  static const String ayudaPlaceholders = 
      'Placeholders disponibles:\n'
      '{{nombre}}, {{dpi}}, {{correo}}, {{fecha}}, {{hora}}, {{dias_cgc}}, {{empresa_nombre}}, {{enlace_confirmacion}}, {{motivo}}, {{numero_contrato}}, {{puesto}}, {{salario}}, {{ubicacion}}, {{ubicacion_especifica}}, {{fecha_inicio}}, {{fecha_fin}}';

  static String resolver(
    String plantilla, {
    String? nombre,
    String? dpi,
    String? correo,
    String? fecha,
    String? hora,
    int? diasCgc,
    String? empresaNombre,
    String? motivo,
    String? enlaceConfirmacion,
    String? numeroContrato,
    String? puesto,
    String? salario,
    String? ubicacion,
    String? ubicacionEspecifica,
    String? fechaInicio,
    String? fechaFin,
  }) {
    var res = plantilla;
    res = res.replaceAll('{{nombre}}', nombre ?? '');
    res = res.replaceAll('{{dpi}}', dpi ?? '');
    res = res.replaceAll('{{correo}}', correo ?? '');
    res = res.replaceAll('{{fecha}}', fecha ?? '');
    res = res.replaceAll('{{hora}}', hora ?? '');
    res = res.replaceAll('{{dias_cgc}}', diasCgc?.toString() ?? '');
    res = res.replaceAll('{{empresa_nombre}}', empresaNombre ?? '');
    res = res.replaceAll('{{motivo}}', motivo ?? '');
    res = res.replaceAll('{{enlace_confirmacion}}', enlaceConfirmacion ?? '');
    res = res.replaceAll('{{numero_contrato}}', numeroContrato ?? '');
    res = res.replaceAll('{{puesto}}', puesto ?? '');
    res = res.replaceAll('{{salario}}', salario ?? '');
    res = res.replaceAll('{{ubicacion}}', ubicacion ?? '');
    res = res.replaceAll('{{ubicacion_especifica}}', ubicacionEspecifica ?? '');
    res = res.replaceAll('{{fecha_inicio}}', fechaInicio ?? '');
    res = res.replaceAll('{{fecha_fin}}', fechaFin ?? '');
    return res;
  }
}
