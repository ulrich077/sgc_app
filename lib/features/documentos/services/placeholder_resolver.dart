/// Resuelve placeholders del texto legal configurado en ajustes.
class PlaceholderResolver {
  static String resolver(
    String plantilla, {
    required String nombre,
    String? dpi,
    required String correo,
    required String fecha,
    required int diasCgc,
    required String empresaNombre,
  }) {
    return plantilla
        .replaceAll('{{nombre}}', nombre)
        .replaceAll('{{dpi}}', dpi ?? '—')
        .replaceAll('{{correo}}', correo)
        .replaceAll('{{fecha}}', fecha)
        .replaceAll('{{dias_cgc}}', diasCgc.toString())
        .replaceAll('{{empresa_nombre}}', empresaNombre);
  }

  /// Placeholders documentados para el admin en ajustes.
  static const String ayudaPlaceholders = '''
Placeholders disponibles:
{{nombre}}          Nombre completo del firmante
{{dpi}}             DPI del firmante
{{correo}}          Correo del firmante
{{fecha}}           Fecha de la firma (dd/MM/yyyy)
{{dias_cgc}}        Días límite para apersonarse a la CGC
{{empresa_nombre}}  Nombre de la empresa configurado en ajustes
''';
}
