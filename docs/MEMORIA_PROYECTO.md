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
