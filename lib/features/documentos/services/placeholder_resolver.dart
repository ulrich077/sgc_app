class PlaceholderResolver {
  static const String ayudaPlaceholders = 
      'Placeholders disponibles:\n'
      '{{nombre}}, {{dpi}}, {{correo}}, {{fecha}}, {{hora}}, {{dias_cgc}}, {{empresa_nombre}}, {{enlace_confirmacion}}, {{motivo}}';

  static String resolver(
    String plantilla, {
    String? nombre,
    String? dpi,
    String? correo,
    String? fecha,
    String? hora,
    int? diasCgc,
    String? empresaNombre,
  }) {
    var res = plantilla;
    res = res.replaceAll('{{nombre}}', nombre ?? '');
    res = res.replaceAll('{{dpi}}', dpi ?? '');
    res = res.replaceAll('{{correo}}', correo ?? '');
    res = res.replaceAll('{{fecha}}', fecha ?? '');
    res = res.replaceAll('{{hora}}', hora ?? '');
    res = res.replaceAll('{{dias_cgc}}', diasCgc?.toString() ?? '');
    res = res.replaceAll('{{empresa_nombre}}', empresaNombre ?? '');
    return res;
  }
}
