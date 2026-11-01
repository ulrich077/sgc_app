enum DocumentoTipo {
  postMortemEscaneo('post_mortem_escaneo', 'Escaneo Post Mortem'),
  contraloriaEscaneo('contraloria_escaneo', 'Escaneo Contraloría'),
  responsabilidadFirmado('responsabilidad_firmado', 'Documento de Responsabilidad firmado'),
  contratoFirmado('contrato_firmado', 'Contrato firmado'),
  escaneoAdicional('escaneo_adicional', 'Escaneo adicional');

  final String dbValue;
  final String label;
  const DocumentoTipo(this.dbValue, this.label);

  static DocumentoTipo fromDb(String v) =>
      DocumentoTipo.values.firstWhere((e) => e.dbValue == v,
          orElse: () => DocumentoTipo.escaneoAdicional);
}
