# MEMORIA DEL PROYECTO SGC
Última actualización: 2026-11-02
Estado: Fase 2.15 (Flujo de Citas, Contraloría, Correos y Reactividad)

---

## 1. DECISIONES DE PROYECTO

| Tema | Decisión |
|---|---|
| Servidor SMTP | **Gmail** (smtp.gmail.com:587) con App Password de 16 caracteres. |
| Servidor | Se inicia automáticamente desde `main.dart` si `es_servidor == true`. |
| Worker | `EmailQueueWorker` corre cada 5 segundos. |
| Fechas | **Regla VI:** Se guardan en SEGUNDOS en la DB. Se multiplican por 1000 para Flutter. |
| Avisos | **Regla IX:** Modales `AppDialogs` (no SnackBars). |
| Iconografía | **FontAwesome** (`font_awesome_flutter`) en toda la UI. |
| Localización | `flutter_localizations` con locale `es_ES` en el `MaterialApp`. |

---

## 2. NUEVAS FUNCIONALIDADES Y CORRECCIONES

### 2.1. Formulario de Nueva Cita (Premium)
- **Paso 1**: Datos Personales (Nombre, DPI, Teléfono) con `FilteringTextInputFormatter` para solo números.
- **Post Mortem**: `DropZone` para subir el PDF autenticado.
- **Contraloría**: Todos los campos obligatorios (Contrato, Puesto, Salario, Dirección, Fecha Inicio, Fecha Fin). La Ubicación Específica es opcional.
- **Fecha de Fin**: Se autocompleta con el 31 de diciembre del año de la Fecha de Inicio.
- **Paso 2**: Contacto y Fecha. Al abrir el modal, se autoselecciona el primer horario disponible.
- **Paso 3**: Resumen y Notas.

### 2.2. Lógica de Disponibilidad Inteligente
- `hayDisponibilidad` valida el bloque de `intervalo_minutos` (15, 30, 45).
- Si el bloque está lleno o ya pasó (`finBloque.isBefore(DateTime.now())`), no está disponible.
- Si está lleno, se abre un **Diálogo de Horarios** con chips de los próximos 5 horarios disponibles.
- Al hacer clic en un chip, la fecha y hora del formulario se actualizan automáticamente.

### 2.3. Adjuntar Post Mortem al Correo
- **Problema**: El correo se encolaba antes de que el archivo se guardara en la DB.
- **Solución**: `CitasRepository.esperarYEncolarCorreo()` hace polling a la DB hasta que el documento `post_mortem_escaneo` existe, luego encola el correo (que lo busca y lo adjunta).

### 2.4. Correo de Confirmación (Premium)
- **Tarjetas de Fecha y Hora**: `flex: 1` para que ocupen el 50% del ancho cada una.
- **Tabla de Contraloría**: Diseño HTML con encabezados azules y filas alternadas.
- **Aviso del Post Mortem**: Texto legal destacado (abogado no trabajador del Congreso).
- **Botón de Confirmación**: `mailto:` con la fecha y hora incluidas.

### 2.5. Correo de Reagenda
- Plantilla con diseño premium (motivo, nueva fecha y hora).
- Se envía automáticamente al cambiar el estado a `REAGENDADA`.

### 2.6. Historial Detallado
- Eventos con títulos amigables ("Cambio de Estado", "Post Mortem Subido", etc.).
- Subtítulos descriptivos ("De Cita Creada a Firmado").
- Modal con JSON formateado (Clave: Valor).

### 2.7. Kanban Reactivo
- `StreamProvider` escuchando los cambios de Drift.
- Drag & Drop con validación de transiciones.

### 2.8. Alertas de Citas Vencidas
- Banner rojo en el Dashboard si hay citas vencidas (`fechaHoraFirma < ahora` y estado no cerrado/cancelado).

### 2.9. Tabla de Citas
- Oculta las **Cerradas** y **Canceladas**.
- Muestra las **Vencidas** (para reagendar).
- Sort funcional en Nombre, Fecha, Estado y Creada.

### 2.10. Selector de Horarios en Reagendar
- Muestra chips con los horarios disponibles del día seleccionado (9:00 a 16:00).
- Ignora los horarios ocupados o pasados.

---

## 3. PROBLEMAS RESUELTOS EN ESTA SESIÓN

| Problema | Solución |
|---|---|
| Fechas 1970 o 58806 | Se limpió la DB (división por 1000) y se forzó `* 1000`. |
| Error `LocaleDataException` | `initializeDateFormatting` y `flutter_localizations`. |
| Correos atascados en `pendiente` | Arranque del `EmailQueueWorker` en `main.dart`. |
| Post Mortem no se adjuntaba | Polling en `esperarYEncolarCorreo` antes de encolar. |
| DPI y Teléfono aceptaban letras | `FilteringTextInputFormatter.digitsOnly`. |
| Horarios sugeridos ya pasados | Validar `finBloque.isAfter(DateTime.now())`. |
| Error de `FaIconData` vs `IconData` | Se usó `dynamic` en los tipos de íconos. |
| Modal se quedaba colgado | Polling con timeout de 30 segundos y cierre automático. |

---

## 4. DEUDA TÉCNICA ACTUAL

| Tema | Estado |
|---|---|
| Sincronización de Documentos y Configuración | El WebSocket solo sincroniza `citas`. |
| Worker en Cliente | El worker solo corre en el servidor. |
| PDF de Responsabilidad | Se genera en el servidor (funciona). |
| Impresión directa | Falta integrar `printing` para imprimir sin abrir el PDF. |

---

## 5. COMANDOS ÚTILES

- Servidor: `dart run lib/server/main_server.dart` (o automático en `main.dart`).
- App: `flutter run -d macos`
- Regenerar Drift: `dart run build_runner build`
- Gate de commit: `flutter analyze` (debe decir "No issues found!").
- DB Local (macOS): `~/Library/Containers/com.sgc.sgc/Data/Documents/sgc_db.sqlite`

---

## 6. HISTORIAL DE COMMITS

86c5b98 (HEAD -> main, origin/main) feat(acciones): paso 5 de cierre, registro de errores en historial y logica de worker
24276cb feat(ui): mejoras en panel de ajustes, cola de correos expandible, modal de cancelacion y spinners en acciones
... (commits anteriores)

---

FIN DE LA MEMORIA

---

## 14. ADJUNTO DE POST MORTEM Y VALIDACIONES FINALES (2026-11-02)

### 14.1. Adjunto del Post Mortem (Fix Definitivo)
- **Problema:** El correo se enviaba sin el Post Mortem porque el ID del documento no se pasaba correctamente.
- **Solución:** En `nueva_cita_dialog.dart`, ahora se captura el `id` que retorna `subirDocumento` y se pasa a `esperarYEncolarCorreo(citaId, postMortemDocId: postMortemId)`.
- El `CitasRepository` ahora busca el documento por `id` (no por tipo), lo que garantiza que se adjunte el archivo correcto.

### 14.2. Validación del No. de Contrato
- Se agregó un `FilteringTextInputFormatter` que solo permite números y guiones.
- Se agregó un `validator` con el regex `^\d{1,4}-\d{4}$` (ej. `1-2026`, `1001-2026`).

### 14.3. Validación de DPI y Teléfono
- Se agregó `FilteringTextInputFormatter.digitsOnly` para bloquear letras.
- Se agregaron validadores que verifican que el valor sea numérico.

---

FIN DE LA ACTUALIZACIÓN

---

## 15. CONFIRMACIÓN DE CORREO CON DESTINATARIO PREDEFINIDO (2026-11-02)

### 15.1. Mailto con Destinatario
- El botón "Confirmar Recibido" del correo de prueba ahora usa un `mailto:` que incluye el `{{correo_remitente}}` como destinatario.
- Al hacer clic, el cliente de correo del firmante se abre con:
  - **Para**: El correo desde donde se envió la confirmación.
  - **Asunto**: "Confirmación de Cita - [Nombre]".
  - **Cuerpo**: "Hola, confirmo que he recibido el correo y llevaré mis documentos para mi cita del día [fecha] a las [hora]".

### 15.2. Reemplazo del Placeholder
- Se actualizó `EmailDispatcher` para reemplazar `{{correo_remitente}}` en el cuerpo del correo usando el valor de `config['correo_remitente']`.

---

FIN DE LA ACTUALIZACIÓN

---

## 16. DASHBOARD: RESUMEN, PAGINACIÓN Y WATCH AGENDADAS (2026-11-02)

### 16.1. Método `watchTotalAgendadas`
- Se agregó a `CitasRepository` un Stream que cuenta todas las citas agendadas (excluyendo Canceladas y Cerradas).
- Este Stream alimenta la nueva Card de Resumen en el Dashboard.

### 16.2. Card de Resumen
- Se agregó una Card entre los KPIs y el calendario/citas.
- Muestra 3 filas con íconos y colores:
  - **Agendados** (azul): usa `watchTotalAgendadas`.
  - **Terminados** (verde): usa `watchTotalPorEstado(CitaEstado.cerrada)`.
  - **Reagendados** (naranja): usa `watchTotalPorEstado(CitaEstado.reagendada)`.
- Cada fila es reactiva y muestra el conteo en tiempo real.

### 16.3. Paginación en el Panel de Citas del Día
- Se agregaron variables de estado `_page` y `_pageSize = 5`.
- El panel de "Citas para el día" ahora muestra solo 5 citas por página.
- Se agregaron botones de **Anterior / Siguiente** y el indicador **"Pág. X de Y"**.
- Al cambiar de día, la paginación se reinicia a 0.

---

FIN DE LA ACTUALIZACIÓN

---

## 17. GRÁFICA DE ACTIVIDAD EN EL DASHBOARD (2026-11-02)

### 17.1. Paquete Utilizado
- **`fl_chart`** (versión instalada con `flutter pub add fl_chart`).
- Es el estándar de la industria para gráficas en Flutter. Permite gráficas de líneas, barras, pastel, etc., con animaciones y tooltips.
- Importación: `import 'package:fl_chart/fl_chart.dart';`

### 17.2. Estructura de la Gráfica (`_LineChartCard`)
Se creó una tarjeta (`_LineChartCard`) que se coloca entre los KPIs y el calendario.
- **Título**: "Actividad de Citas".
- **Subtítulo**: "Tendencia de los últimos 5 días y próximos 5 días".
- **Leyenda**: 3 ítems (Agendados, Terminados, Reagendados) con colores azul, verde y naranja.
- **Rango de datos**: 
  - Se calculan 11 días en total (5 días antes de hoy y 5 días después).
  - Se agrupan las citas por día usando `fechaHoraFirma` (convertido a segundos).
  - Se generan 3 listas de `FlSpot` (puntos X, Y) para cada serie:
    - **Agendados** (azul): citas cuyo estado no es `CANCELADA` ni `CERRADA`.
    - **Terminados** (verde): citas en estado `CERRADA`.
    - **Reagendados** (naranja): citas en estado `REAGENDADA`.

### 17.3. Configuración de `LineChartData`
- **Cuadrícula (`FlGridData`)**: 
  - Líneas verticales y horizontales en gris suave (`Colors.grey.shade200`).
  - `horizontalInterval` e `verticalInterval` calculados dinámicamente.
- **Títulos (`FlTitlesData`)**:
  - **Eje Y (izquierda)**: Muestra números enteros. El intervalo se calcula dividiendo el valor máximo entre 5.
  - **Eje X (abajo)**: Muestra la fecha en formato `d MMM` (ej. "3 nov"). Se muestra cada 2 días para no saturar.
- **Bordes (`FlBorderData`)**: Solo se muestran los bordes izquierdo y inferior (estilo Chart.js).
- **Escala Dinámica**:
  - Se calcula el valor máximo (`maxValor`) entre las 3 series.
  - Se define `maxY = maxValor + 2` (con un mínimo de 5) para dar margen.
  - Se define `intervaloY = (maxY / 5).ceilToDouble()` para que el eje Y tenga 5 divisiones limpias.
- **Tooltips (`LineTouchData`)**:
  - Al tocar un punto, muestra un tooltip con el valor (ej. "5 citas") y el color de la línea.

### 17.4. Series de Datos (`LineChartBarData`)
Cada serie tiene:
- `spots`: Lista de `FlSpot`.
- `isCurved: true`: Línea curva (suavizada).
- `color`: Azul, verde o naranja.
- `barWidth: 3`: Grosor de la línea.
- `isStrokeCapRound: true`: Extremos redondeados.
- `dotData: FlDotData(show: true)`: Muestra puntos en cada dato.
- `belowBarData: BarAreaData(show: false)`: Sin relleno debajo de la línea (para no saturar).

### 17.5. Problemas Resueltos
| Problema | Solución |
|---|---|
| La gráfica se desbordaba | Se calculó `maxY` dinámicamente y se ajustó `intervaloY`. |
| Se repetían los días (martes, miércoles, etc.) | Se generó una lista fija de 11 días (5 antes, 5 después) y se agrupó por fecha exacta. |
| Los datos no se veían claros | Se agregó leyenda, tooltips y cuadrícula visible. |
| `maxY` fijo en 10 | Se cambió a `(maxValor + 2).ceilToDouble()`. |

---

FIN DE LA ACTUALIZACIÓN
