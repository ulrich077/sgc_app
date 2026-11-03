class PuestoInfo {
  final String codigo;
  final String nombre;
  final String salario;
  
  const PuestoInfo({
    required this.codigo,
    required this.nombre,
    required this.salario,
  });
}

const List<PuestoInfo> catalogoPuestos = [
  // Personal de apoyo legislativo - Artículo 154 Bis
  PuestoInfo(codigo: '154-01', nombre: 'Asesor II – 154 Bis', salario: 'Q22,000.00'),
  PuestoInfo(codigo: '154-02', nombre: 'Asesor I – 154 Bis', salario: 'Q20,000.00'),
  PuestoInfo(codigo: '154-03', nombre: 'Asesor – 154 Bis', salario: 'Q18,000.00'),
  PuestoInfo(codigo: '154-04', nombre: 'Asistente II – 154 Bis', salario: 'Q14,000.00'),
  PuestoInfo(codigo: '154-05', nombre: 'Asistente I – 154 Bis', salario: 'Q12,000.00'),
  PuestoInfo(codigo: '154-06', nombre: 'Secretaria II – 154 Bis', salario: 'Q10,000.00'),
  PuestoInfo(codigo: '154-07', nombre: 'Secretaria I – 154 Bis', salario: 'Q8,000.00'),

  // Asesores parlamentarios - Bloques legislativos
  PuestoInfo(codigo: 'AP-BL-01', nombre: 'Asesor Parlamentario III (Bloques)', salario: 'Q22,000.00'),
  PuestoInfo(codigo: 'AP-BL-02', nombre: 'Asesor Parlamentario II (Bloques)', salario: 'Q20,000.00'),
  PuestoInfo(codigo: 'AP-BL-03', nombre: 'Asesor Parlamentario I (Bloques)', salario: 'Q18,000.00'),

  // Asesores parlamentarios - Junta Directiva
  PuestoInfo(codigo: 'AP-JD-01', nombre: 'Asesor Parlamentario III (Junta Directiva)', salario: 'Q26,000.00'),
  PuestoInfo(codigo: 'AP-JD-02', nombre: 'Asesor Parlamentario II (Junta Directiva)', salario: 'Q24,000.00'),
  PuestoInfo(codigo: 'AP-JD-03', nombre: 'Asesor Parlamentario I (Junta Directiva)', salario: 'Q22,000.00'),
  PuestoInfo(codigo: 'AP-JD-04', nombre: 'Asesor Parlamentario (Junta Directiva)', salario: 'Q18,000.00'),

  // Personal de apoyo administrativo - Profesionales
  PuestoInfo(codigo: 'P-01', nombre: 'Profesional III', salario: 'Q24,000.00'),
  PuestoInfo(codigo: 'P-02', nombre: 'Profesional II', salario: 'Q23,000.00'),
  PuestoInfo(codigo: 'P-03', nombre: 'Profesional I', salario: 'Q22,000.00'),
  PuestoInfo(codigo: 'P-04', nombre: 'Profesional', salario: 'Q18,000.00'),

  // Asistentes, secretaria y técnicos
  PuestoInfo(codigo: 'A-01', nombre: 'Asistente III', salario: 'Q14,000.00'),
  PuestoInfo(codigo: 'A-02', nombre: 'Asistente II', salario: 'Q12,000.00'),
  PuestoInfo(codigo: 'A-03', nombre: 'Asistente I', salario: 'Q10,000.00'),
  PuestoInfo(codigo: 'T-01', nombre: 'Técnico III', salario: 'Q9,000.00'),
  PuestoInfo(codigo: 'S-01', nombre: 'Secretaria', salario: 'Q8,000.00'),
  PuestoInfo(codigo: 'T-02', nombre: 'Técnico II', salario: 'Q8,000.00'),
  PuestoInfo(codigo: 'T-03', nombre: 'Técnico I', salario: 'Q7,000.00'),

  // Guardia parlamentario y operativo
  PuestoInfo(codigo: 'G-01', nombre: 'Guardia Parlamentario', salario: 'Q6,500.00'),
  PuestoInfo(codigo: 'O-01', nombre: 'Operativo', salario: 'Q6,000.00'),
];
