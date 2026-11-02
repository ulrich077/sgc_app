# MEMORIA DEL PROYECTO SGC
Última actualización: 2026-11-02
Estado: Fase 2.9 (Rediseño de UI, Flujos de Documentos y Correos)

---

## 1. DECISIONES DE PROYECTO

| Tema | Decisión |
|---|---|
| Servidor SMTP | **Gmail** (smtp.gmail.com:587) con App Password de 16 caracteres. |
| Servidor | Se inicia automáticamente desde `main.dart` si `es_servidor == true`. |
| Worker | `EmailQueueWorker` corre cada 5 segundos (configurable en `main.dart`). |
| Fechas | **Regla VI:** Se guardan en SEGUNDOS en la DB. Se multiplican por 1000 para Flutter. |
| Avisos | **Regla IX:** Modales `AppDialogs` (no SnackBars). |

---

## 2. NUEVAS FUNCIONALIDADES IMPLEMENTADAS

### 2.1. Servidor Automático en `main.dart`
- Se creó el widget `ServerBootGate` que envuelve a `SgcApp`.
- Al iniciar, lee la configuración `es_servidor`. Si es `true`, levanta `SgcServer(db)` y `EmailQueueWorker(db).start(intervalo: 5s)`.
- Se solucionó el error de paso de parámetros en `server.start(host: '0.0.0.0', port: 8080)`.

### 2.2. Pantalla de Ajustes (Rediseño Total)
- Se cambió de `TabBar` a un **Menú Lateral (Maestro-Detalle)** con tarjetas.
- **Apariencia**: Selector de colores con reactividad instantánea (se aplican al Sidebar sin reiniciar).
- **Modo Servidor**: Switch para activar/desactivar `es_servidor`.
- **Plantillas de Correo**: Editor de texto con switch para "Modo HTML" (fondo oscuro) y botón de guardar integrado.

### 2.3. Flujo de Acciones (Paso 1, 2, 3 y 4)
Se rediseñó `acciones_tab.dart` para el flujo exacto:
- **Paso 1**: 4 switches (Post Mortem, Contraloría, Doc. Responsabilidad, Contrato). Los de documentos se activan/apagan solos al subir/borrar archivos.
- **Paso 2**: Botón para descargar el PDF de Responsabilidad (generado por el sistema). Zona de Drag & Drop para subirlo firmado.
- **Paso 3**: Drag & Drop para subir el Contrato Firmado.
- **Paso 4**: Botón de "Enviar Correo Final" con spinner. Escucha la DB hasta que el worker envía el correo y cambia a "¡Enviado!".

### 2.4. Documentos (Pestaña)
- Se reordenaron las pestañas: **Datos, Acciones, Documentos, Historial**.
- Las tarjetas de documentos ahora abren un **diálogo premium** al hacer clic con opciones de:
  - Abrir Documento (con `url_launcher`).
  - Abrir Carpeta contenedora.
  - Ver Detalles (tamaño, ruta, fecha).

### 2.5. Cola de Correos
- Se reescribió `correos_tab.dart` usando `ExpansionTile`.
- Muestra el último correo arriba.
- Al expandir, muestra los intentos, fecha de envío, el error (si falló) y un botón de "Reintentar".
- Se agregó el método `reintentar` en `CorreosRepository`.

### 2.6. DataTables
- **Citas**: Sort funcional, 100% de ancho, fechas corregidas.
- **Firmas Enviadas**: Sort funcional, 100% de ancho.
- Se agregó `watchFirmasEnviadas` en `CitasRepository`.

### 2.7. Dashboard
- KPIs restaurados.
- Calendario en español interactivo (con puntitos en días con citas).
- Panel derecho con las citas del día seleccionado (tachadas en rojo si están canceladas).

---

## 3. PROBLEMAS RESUELTOS

| Problema | Solución |
|---|---|
| Fechas 1970 o 58806 | Se limpió la DB (división por 1000) y se forzó `cita.fechaHoraFirma * 1000`. |
| Error `LocaleDataException` | Se agregó `initializeDateFormatting('es_ES', null)` en `main.dart`. |
| SnackBar en Ajustes | Reemplazados por `AppDialogs.success`. |
| Correos atascados en `pendiente` | Faltaba el arranque del `EmailQueueWorker` en `main.dart`. |
| PDF de Responsabilidad no descarga | El botón está maquetado, falta conectar con el `PdfService` o API del servidor. |

---

## 4. DEUDA TÉCNICA ACTUAL

| Tema | Estado |
|---|---|
| Descarga de PDF de Responsabilidad | El botón existe, pero no llama a la función real de generación. |
| Cancelar Cita | El botón existe, pero falta el modal de reagendar. |
| Correos al Cliente | El cliente no tiene worker; depende del servidor. |

---

FIN DE LA MEMORIA
