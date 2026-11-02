# MEMORIA DEL PROYECTO SGC
Última actualización: 2026-11-02
Estado: Fase 2.11 (Rediseño UI Premium, Flujo de Documentos y Correos)

---

## 1. DECISIONES DE PROYECTO

| Tema | Decisión |
|---|---|
| Servidor SMTP | **Gmail** (smtp.gmail.com:587) con App Password de 16 caracteres. |
| Servidor | Se inicia automáticamente desde `main.dart` si `es_servidor == true`. |
| Worker | `EmailQueueWorker` corre cada 5 segundos (configurable en `main.dart`). |
| Fechas | **Regla VI:** Se guardan en SEGUNDOS en la DB. Se multiplican por 1000 para Flutter. |
| Avisos | **Regla IX:** Modales `AppDialogs` (no SnackBars). |
| Iconografía | **FontAwesome** (`font_awesome_flutter`) para toda la UI. |

---

## 2. NUEVAS FUNCIONALIDADES IMPLEMENTADAS

### 2.1. Flujo de Acciones (Checkout Premium)
- Se rediseñó la pestaña de Acciones como un **Wizard de 4 pasos** (tarjetas con número, sombras suaves, fondo gris `#F4F7F9`).
- **Lógica de bloqueo secuencial:**
  - El Paso 2 solo se habilita si el Paso 1 (Post Mortem + Contraloría) está completo.
  - El Paso 3 solo se habilita si el Paso 2 (Documento de Responsabilidad) está completo.
  - El Paso 4 solo se habilita si todo está completo.
  - Si se elimina un documento, los pasos posteriores se vuelven a bloquear.
- Los botones de subida son franjas horizontales (`_PremiumUploadRow` estilo Stripe).
- Al subir un documento, se muestra una fila de recibo (`_PremiumDocRow`) con botones de descarga y eliminar.
- Los íconos del flujo son: `folderOpen` (Paso 1), `fileSignature` (Paso 2), `fileContract` (Paso 3), `paperPlane` (Paso 4).

### 2.2. Rediseño de la Pestaña de Datos
- Se unificó el diseño con tarjetas blancas, sombras suaves y fondo gris (`#F4F7F9`).
- Los botones de "Editar Correo" y "Reenviar Correo" están integrados en la tarjeta de "Contacto y Cita".
- Se mantiene el spinner de reenvío de correo.

### 2.3. Polling en el Envío de Correos (Fix)
- **Problema:** El `Stream` de Drift no notificaba al cliente cuando el worker (en el servidor) cambiaba el estado del correo a `enviado`.
- **Solución:** Se implementó un bucle `while` con `Future.delayed` (polling) de 2 segundos en `_enviarCorreoFinal`. La UI consulta la DB hasta que el estado sea `enviado`, con un timeout de 30 segundos.
- **Corrección crucial:** En la DB el tipo de correo se guarda como `final` (sin guion bajo). El polling se ajustó para buscar `tipo.equals('final')`.

### 2.4. Correo Final (Plantilla)
- Se actualizó la plantilla en la DB para el correo final.
- Se eliminó el párrafo de "Se le solicita remitir a este Departamento...".
- El texto legal (Artículos 20, 22, 17, 27 y 419 Bis) ahora se muestra dentro de un **bloque destacado (`legal-box`)** con fondo gris y borde azul, para darle un look más profesional.

### 2.5. Documentos (Pestaña)
- Se agregó un **botón de eliminar** en cada tarjeta de documento (con confirmación `AppDialogs.confirm`).
- Se agregó `AutomaticKeepAliveClientMixin` para que la pestaña escuche los cambios en tiempo real (si subes un documento en Acciones, aparece en Documentos).
- El tamaño del archivo se formatea en KB/MB.

### 2.6. PDF de Responsabilidad
- Se agregó el logo desde la DB (`empresa_logo_base64`).
- Márgenes de 1 pulgada a los lados.
- Fecha: "Guatemala 02 de noviembre del 2026".
- Se cambió "colaborador" por "contratado".
- Se eliminó el encabezado del Congreso, dejando solo "Departamento de Reclutamiento, Selección y Contratos".
- Se cambió "Firma del(a) declarante" por "Firma".

---

## 3. PROBLEMAS RESUELTOS EN ESTA SESIÓN

| Problema | Solución |
|---|---|
| Spinner de envío final colgado | Polling cada 2s buscando `tipo.equals('final')` en la DB. |
| Diseño plano en Acciones y Datos | Rediseño Premium tipo Checkout (tarjetas, sombras, números de paso). |
| Falta de FontAwesome | Se instaló `font_awesome_flutter` y se reemplazaron los íconos. |
| Documentos no se actualizaban en la pestaña | `AutomaticKeepAliveClientMixin` en `documentos_tab.dart`. |
| Error de `FilePicker.platform` | Se actualizó a `FilePicker.pickFiles` (nueva API). |
| Error de `FaIconData` vs `IconData` | Se cambió el tipo en `_PremiumCard` a `FaIconData`. |
| Fechas incorrectas en Tabla | Fix con `* 1000` y migración de datos viejos con SQL. |
| URL con barra invertida (`\`) | `sed` de limpieza recurrente en `acciones_tab.dart`. |

---

## 4. DEUDA TÉCNICA ACTUAL

| Tema | Estado |
|---|---|
| Módulo de Cancelar/Reagendar | El botón existe, pero falta el modal funcional. |
| Sync de Documentos y Configuración | El WebSocket solo sincroniza `citas` (falta `documentos` y `configuracion`). |
| Worker en Cliente | El worker solo corre en el servidor (el cliente no puede enviar correos si el servidor está caído). |

---

FIN DE LA MEMORIA

---

## 7. HISTORIAL Y EVENTOS (2026-11-02)

### 7.1. Registro de Eventos en Acciones
- Se inyectó el `EventosRepository` en `acciones_tab.dart`.
- Ahora cada vez que se sube o elimina un documento (Post Mortem, Contraloría, Responsabilidad, Contrato), se registra un evento en la tabla `eventos_cita`.
- Los eventos se pueden ver en la pestaña **Historial** y al tocarlos se muestra un modal con el JSON de detalles (si existe).

### 7.2. Corrección de Fechas en Eventos
- Los eventos viejos se guardaron por error en milisegundos. Se ejecutó un `UPDATE` en SQLite para dividir entre 1000 y convertirlos a segundos.
- El `EventosRepository` ahora guarda en segundos (`DateTime.now().millisecondsSinceEpoch ~/ 1000`).
- La UI multiplica por 1000 para mostrar la fecha correcta (Regla VI).

### 7.3. Orden del Historial
- Se cambió el `orderBy` del `watchPorCita` para ordenar por `id` de forma descendente. Así, el último evento registrado siempre aparece arriba.

---

FIN DE LA ACTUALIZACIÓN

---

## 9. FASE 2.13: FLUJO COMPLETO DE CITAS Y DATOS DE CONTRALORÍA (2026-11-02)

### 9.1. Formulario de Nueva Cita (Rediseño Premium)
- Se reescribió `nueva_cita_dialog.dart` con un diseño tipo **Checkout**.
- **Diseño**: Fondo gris, tarjetas blancas con sombras, íconos de FontAwesome.
- **Secciones**:
  - **Datos Personales**: Nombre, DPI, Teléfono.
  - **Datos para Contraloría**: No. Contrato, Puesto, Salario, Dirección (dropdown con 11 opciones), Ubicación Específica, Fecha Inicio, Fecha Fin.
- **Fecha de Fin**: Por defecto se autocompleta con el **31 de diciembre del año de la Fecha de Inicio**.
- **Validación**: DPI (13 dígitos), Teléfono (8 dígitos), Correo válido.

### 9.2. Base de Datos (Migración v4)
- Se agregaron las columnas a la tabla `citas`: `numero_contrato`, `puesto`, `salario`, `ubicacion`, `ubicacion_especifica`, `fecha_inicio`, `fecha_fin`.
- Se actualizó `app_database.dart` a `schemaVersion = 4` con los `ALTER TABLE` correspondientes.
- Se actualizó `CitasRepository.crear()` para aceptar y guardar estos campos.

### 9.3. Lógica de Agenda (Configuración)
- En **Ajustes → Agenda**, se puede configurar:
  - El **intervalo entre citas** (15, 30 o 45 min).
  - El **máximo de citas por bloque** (ej. 2).
- El formulario de Nueva Cita valida:
  - Si los minutos coinciden con el intervalo.
  - Si no se supera el máximo de citas por hora.
- **Mensaje de error premium**: Si el bloque está lleno, muestra un diálogo con la lista de los nombres de las citas ya agendadas.

### 9.4. Correo de Confirmación
- La plantilla del correo de prueba ahora incluye los datos de Contraloría (Contrato, Puesto, Salario, Dirección, Fechas).
- Se actualizó `PlaceholderResolver` y `EmailDispatcher` para soportar los nuevos placeholders (`{{numero_contrato}}`, `{{puesto}}`, etc.).

### 9.5. Flujo de Acciones (5 Pasos)
- **Paso 1**: DropZones para subir Post Mortem y Contraloría.
- **Paso 2**: Descargar PDF de Responsabilidad y subir el escaneo firmado.
- **Paso 3**: Subir Contrato Firmado.
- **Paso 4**: Enviar Correo Final. Botón cambia a "¡Enviado!" y aparece el botón de **"Reenviar Correo"**.
- **Paso 5**: **Cerrar Cita**. El botón solo aparece si el correo se envió correctamente. Al presionar, la cita pasa a estado `CERRADA`.
- Todos los pasos usan **Polling** para detectar cuando el worker envía el correo (2 segundos).

### 9.6. Historial Reactivo y Detallado
- El historial muestra títulos amigables (ej. "Cambio de Estado") y subtítulos descriptivos (ej. "De Cita Creada a Firmado").
- Cada evento tiene su propio JSON de detalles que se muestra en un modal al hacer clic.
- Se registran eventos al subir/eliminar documentos, cambiar de estado y errores de envío de correo.

### 9.7. Kanban Reactivo con Drag & Drop
- El Kanban usa un `StreamProvider` para escuchar los cambios de Drift en tiempo real.
- Las tarjetas se mueven automáticamente al cambiar de estado (desde Acciones o desde el propio Kanban).
- Drag & Drop con validación de transiciones de estado.

### 9.8. Alertas de Citas Vencidas
- Se agregó un `Stream` (`watchVencidas`) en `CitasRepository` que cuenta las citas vencidas.
- En el **Dashboard**, si hay citas vencidas, aparece un **banner rojo de advertencia**.
- La tabla de **Citas** oculta las cerradas y canceladas, pero **muestra las vencidas** (para que el operador pueda reagendarlas).

---

## 10. DEUDA TÉCNICA ACTUAL

| Tema | Estado |
|---|---|
| Módulo de Cancelar/Reagendar | El modal está implementado, pero falta probar el flujo completo con el envío de correo. |
| Sync de Documentos y Configuración | El WebSocket solo sincroniza `citas` (falta `documentos` y `configuracion`). |
| Worker en Cliente | El worker solo corre en el servidor (el cliente no puede enviar correos si el servidor está caído). |

---

FIN DE LA ACTUALIZACIÓN

---

## 11. FASE 2.14: CORRECCIONES FINALES DE CORREOS Y UX (2026-11-02)

### 11.1. Correo de Confirmación con Datos de Contraloría
- Se actualizó la plantilla `plantilla_prueba` en la DB para incluir los datos de Contraloría (Contrato, Puesto, Salario, Ubicación, Fechas).
- Se actualizó `PlaceholderResolver` para soportar los nuevos placeholders.
- Se actualizó `EmailDispatcher` para pasar los datos de la cita completa (leída de la DB) al correo.

### 11.2. Correo de Reagenda Premium
- Se actualizó la plantilla `plantilla_reagenda` con el diseño unificado.
- El correo ahora incluye el **motivo**, la **nueva fecha** y la **nueva hora**.
- Se actualizó el `EmailDispatcher` para pasar el motivo y la nueva fecha correctamente.

### 11.3. Polling en Reenvío de Correos (Pestaña Datos)
- El botón de "Reenviar" en la pestaña Datos ahora usa **Polling** (cada 2 segundos) para esperar a que el worker envíe el correo.
- El botón muestra "Enviando..." y cambia a "¡Enviado!" en verde cuando el worker termina.

### 11.4. Selector de Horarios en Reagendar
- El modal de reagendar ahora muestra un **selector de horarios** (chips) con los bloques disponibles (9:00 a 16:00).
- Los horarios se cargan dinámicamente según el día seleccionado y la configuración de agenda (intervalo y máximo de citas).
- Si no hay horarios, muestra un mensaje en rojo.

### 11.5. Alertas de Citas Vencidas
- Se agregó un banner rojo en el Dashboard cuando hay citas vencidas.
- Se agregó el método `watchVencidas` en `CitasRepository` para consultar las citas vencidas en tiempo real.

### 11.6. Migración de Base de Datos a v4
- Se agregaron las columnas `numero_contrato`, `puesto`, `salario`, `ubicacion`, `ubicacion_especifica`, `fecha_inicio`, `fecha_fin` a la tabla `citas`.
- Se actualizó `schemaVersion` a 4 y se agregaron los `ALTER TABLE` en el `onUpgrade`.

---

FIN DE LA ACTUALIZACIÓN
