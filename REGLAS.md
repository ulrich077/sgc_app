
────────────────────────────────────────────────────────────────────────────────
XIV. GATE DE ANALYZE (BLOQUEANTE)
────────────────────────────────────────────────────────────────────────────────
- NINGÚN commit se hace si `flutter analyze` no devuelve `No issues found!`.
- Si se tocaron tablas/DAOs Drift, primero:
    dart run build_runner build
- Luego SIEMPRE:
    if flutter analyze; then
      git add .
      git commit -m "..."
      git push
    else
      echo "❌ Analyze falló. NO se hace commit."
    fi
- Warnings cuentan como fallo. No se ignora ningún issue.
- Antes de proponer cualquier bloque que incluya commit/push, el asistente
  DEBE consultar esta regla y condicionar el commit a analyze limpio.
- Si analyze falla, se corrige primero y se vuelve a correr analyze.
  Nunca se commitea "para arreglar después".

================================================================================
FIN DE LA REGLA DE ORO MAESTRA — SGC v1.2
================================================================================

────────────────────────────────────────────────────────────────────────────────
XIV. GATE DE ANALYZE (BLOQUEANTE)
────────────────────────────────────────────────────────────────────────────────
- NINGÚN commit se hace si `flutter analyze` no devuelve `No issues found!`.
- Si se tocaron tablas/DAOs Drift, primero:
    dart run build_runner build
- Luego SIEMPRE:
    if flutter analyze; then
      git add .
      git commit -m "..."
      git push
    else
      echo "❌ Analyze falló. NO se hace commit."
    fi
- Warnings cuentan como fallo. No se ignora ningún issue.
- Antes de proponer cualquier bloque que incluya commit/push, el asistente
  DEBE consultar esta regla y condicionar el commit a analyze limpio.
- Si analyze falla, se corrige primero y se vuelve a correr analyze.
  Nunca se commitea "para arreglar después".

================================================================================
FIN DE LA REGLA DE ORO MAESTRA — SGC v1.2
================================================================================

### Regla XV: URLs y Caracteres de Escape
- **Problema:** Al usar `sed` o `cat` para reescribir archivos con URLs como `http://$ip:$puerto/api/citas/${cita.id}/pdf`, el carácter `\` se cuela antes del `;` (ej. `pdf'\;`), rompiendo la sintaxis.
- **Solución:** 
  1. **No usar `$` ni `\` dentro de strings en los scripts de terminal.** 
  2. **Construir la URL en Dart usando variables:**
     ```dart
     final baseUrl = 'http://$ip:$puerto';
     final url = Uri.parse('$baseUrl/api/citas/${cita.id}/pdf');
