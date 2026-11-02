# MEMORIA DEL PROYECTO SGC
Última actualización: 2026-11-02
Estado: Fase 2.5 (Mejoras de UI, SMTP y Flujo de Citas)

---

## 1. DECISIONES DE PROYECTO

| Tema | Decisión |
|---|---|
| Nombre del paquete Dart | `sgc` |
| Carpeta del proyecto | `sgc_app` |
| `--org` | `com.sgc` |
| Repositorio | https://github.com/ulrich077/sgc_app.git (rama main) |
| Primer administrador | Seed `admin` / `hacker94` |
| Servidor SMTP | **Gmail** (smtp.gmail.com:587) con App Password |
| Fechas en DB | **Regla VI: Se guardan en SEGUNDOS** (Unix Timestamp) |

---

## 2. REGLAS DE ORO INTERNALIZADAS (v1.2)

| # | Regla | Estado |
|---|---|---|
| I | Honestidad técnica | OK |
| II | Clase global AppConfig + provider reactivo | OK |
| III | Reactividad total (Drift Streams) | OK |
| IV | Responsive total | OK |
| V | DataTable inviolable (sort SQL, 100% width) | OK implementado |
| VI | Fechas (segundos vs milisegundos) | OK (Fix aplicado) |
| VII | Seguridad y permisos | OK |
| VIII | `cat > ... << 'DART_EOF'` + `flutter analyze` | OK estricto |
| IX | Modales con AppDialogs | OK |
| XII | Commits (analyze limpio → commit → push) | OK |
| XIV | Gate de analyze bloqueante | OK |

---

## 3. PROBLEMAS RESUELTOS EN ESTA SESIÓN

### 3.1. SMTP Office 365 vs Gmail
- **Problema:** Office 365 (`smtp.office365.com`) rechazaba la autenticación con error `535 5.7.3` porque la organización tiene bloqueado el SMTP AUTH o Security Defaults.
- **Solución:** Se migró a **Gmail**.
- **Configuración requerida para Gmail:**
  - Activar Verificación en 2 Pasos en la cuenta de Google.
  - Generar una **Contraseña de Aplicación** (16 caracteres sin espacios).
  - `smtp_host`: `smtp.gmail.com`
  - `smtp_port`: `587`
  - `smtp_user`: correo completo.
  - `smtp_password`: La App Password de 16 caracteres.
  - `correo_remitente`: correo completo.

### 3.2. Error `dateCreation` vs `dateCreated`
- Drift generaba error porque en `tables.dart` la columna se llama `dateCreation` (con "n") y no `dateCreated`.
- **Fix:** Se reemplazó en todo el código.

### 3.3. Error de sintaxis por `\` en URL
- La línea `'http://.../api/confirmar/$token'\;` tenía una barra invertida que rompía el código.
- **Fix:** Se eliminó el `\`.

---

## 4. NUEVAS FUNCIONALIDADES IMPLEMENTADAS

### 4.1. Correo Premium Institucional
- Se rediseñó la plantilla de `plantilla_prueba` en la DB.
- **Diseño:** Header oscuro `#1A237E`, tarjetas de Fecha y Hora (sin emojis, solo CSS), caja de requisitos con borde azul, botón `mailto:` para confirmar.
- **Fix de Hora:** Se agregó `{{hora}}` al `PlaceholderResolver` y se formateó a `HH:mm`.
- **Fix de Fecha 1970:** Se multiplicó `cita.fechaHoraFirma * 1000` en `EmailDispatcher` (porque la DB guarda segundos).

### 4.2. Flujo de Acciones de 3 Pasos (`acciones_tab.dart`)
- **Paso 1:** Switches para marcar Post Mortem y Contraloría.
- **Paso 2:** Drag & Drop (`desktop_drop`) para subir el PDF de Responsabilidad y el Contrato. Se guardan en la DB usando `DocumentosRepository.subirDocumento`.
- **Paso 3:** Botón para enviar el correo final (con los adjuntos). Solo se habilita si los documentos están subidos.

### 4.3. Pestaña de Datos (`datos_tab.dart`)
- **Editar Correo:** Botón que abre un diálogo con spinner mientras actualiza en la DB.
- **Reenviar Correo:** Botón con spinner ("Enviando..."). Escucha la tabla `correos_log` en tiempo real y cambia a "¡Enviado!" en verde cuando el *worker* termina de procesarlo.

### 4.4. DataTable (Citas)
- Ahora ocupa el **100% de ancho** (`width: double.infinity`).
- El **Sort** funciona en Nombre, Fecha, Estado y Creada.

### 4.5. Calendario en Dashboard
- Se agregó el paquete `table_calendar` y el widget visual en el Dashboard (falta conectar los puntitos de eventos).

---

## 5. DEUDA TÉCNICA ACTUAL

| Tema | Estado |
|---|---|
| Cancelar Cita | Botón existe, pero falta modal para reagendar y enviar correo. |
| Calendario | El widget está, pero no marca los días con citas (falta `eventLoader`). |
| Correos del Cliente | El worker sigue siendo solo del servidor. Si el cliente encola, depende del sync (que aún no sincroniza `correos_log`). |
| OAuth2 | Gmail funciona con App Password, pero a largo plazo Microsoft/Google piden OAuth2. |

---

## 6. COMANDOS ÚTILES

- Servidor: `dart run lib/server/main_server.dart` (o se inicia automático en `main.dart` si `es_servidor=true`).
- App: `flutter run -d macos`
- Regenerar Drift: `dart run build_runner build`
- Gate de commit: `flutter analyze` (debe decir "No issues found!").
- DB Local (macOS): `~/Library/Containers/com.sgc.sgc/Data/Documents/sgc_db.sqlite`

FIN DE LA MEMORIA
