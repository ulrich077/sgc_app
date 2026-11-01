enum CorreoTipo {
  prueba('prueba', 'Correo de prueba'),
  confirmacion('confirmacion', 'Confirmación'),
  reagenda('reagenda', 'Reagenda'),
  final_('final', 'Correo final'),
  recordatorio('recordatorio', 'Recordatorio');

  final String dbValue;
  final String label;
  const CorreoTipo(this.dbValue, this.label);

  static CorreoTipo fromDb(String v) =>
      CorreoTipo.values.firstWhere((e) => e.dbValue == v,
          orElse: () => CorreoTipo.prueba);
}

enum CorreoEstado {
  pendiente('pendiente'),
  enviado('enviado'),
  fallido('fallido');

  final String dbValue;
  const CorreoEstado(this.dbValue);

  static CorreoEstado fromDb(String v) =>
      CorreoEstado.values.firstWhere((e) => e.dbValue == v,
          orElse: () => CorreoEstado.pendiente);
}
