
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
