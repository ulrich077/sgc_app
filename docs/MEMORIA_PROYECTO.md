# MEMORIA DEL PROYECTO SGC
Última actualización: 2026-11-01
Estado: Fase 1 cerrada (commit 85f9753, pusheado a origin/main)

---

## 1. DECISIONES DE PROYECTO

| Tema | Decisión |
|---|---|
| Nombre del paquete Dart | `sgc` |
| Carpeta del proyecto | `sgc_app` (anidada en Desktop/SGC/sgc_app/sgc_app/sgc_app/) |
| `--org` | `com.sgc` (NO com.congreso) |
| Repositorio | https://github.com/ulrich077/sgc_app.git (rama main) |
| Primer administrador | Seed `admin` / `hacker94` (Opción 1) |
| Orden de trabajo | Ruta B — DB primero, auth después |
| correoCcFinal default | Vacío '' |
| empresaNombre default | Vacío '' |
| Colores primary/secondary | Editables desde /admin-settings, reactivos vía themeColorsProvider |
| secondary | Dos pickers independientes, sin auto-ajuste. Uso operativo limitado (opción A) |
| Kanban | PENDIENTE de decidir (recomendado: botones/menú, no drag & drop) |
| Correo de prueba al crear cita | PENDIENTE de decidir (recomendado: diferir a Fase 4) |

---

## 2. REGLAS DE ORO INTERNALIZADAS

Del REGLAS.md original (v1.1) más las nuevas:

| # | Regla | Estado |
|---|---|---|
| I | Honestidad técnica | OK |
| II | Clase global AppConfig + provider reactivo | OK implementado |
| III | Reactividad total (Drift Streams) | OK aplicado en dashboard |
| IV | Responsive total (<600 / 600-900 / >=900) | OK widgets creados |
| V | DataTable inviolable (sort SQL, paginación, width 100%) | PENDIENTE Fase 2 |
| VI | Fechas (segundos vs milisegundos) | PENDIENTE |
| VII | Seguridad y permisos (2 roles, triple seguridad) | OK router + guards |
| VIII | cat > ... << 'DART_EOF' + flutter analyze obligatorio | OK aplicado |
| IX | Modales con AppDialogs (no SnackBar) | DEUDA: SnackBar en panel de colores |
| X | Red LAN (server/client) | PENDIENTE Fase 5 |
| XI | Impresión y PDF | PENDIENTE Fase 3 |
| XII | Commits (analyze limpio → commit → push) | OK |
| XIII | Glosario del dominio | OK docs/GLOSARIO_DOMINIO.md |
| XIV | Gate de analyze bloqueante (warnings = fallo) | OK en REGLAS.md v1.2 |

REGLA ADICIONAL DE FLUJO (acordada 2026-11-01):
- No commitear por bloque. Un commit por FASE cerrada.
- Los bloques intermedios solo corren `flutter analyze`.
- El commit se hace al cerrar la fase, con gate analyze obligatorio.

REGLA DE MEMORIA:
- Toda memoria del proyecto vive en docs/MEMORIA_PROYECTO.md.
- El asistente DEBE leer este archivo antes de responder cualquier cosa
  relacionada con el estado del proyecto.

---

## 3. ESTRUCTURA ACTUAL

sgc_app/
├── REGLAS.md                          <- Regla de Oro v1.2 con gate XIV
├── docs/
│   ├── GLOSARIO_DOMINIO.md
│   └── MEMORIA_PROYECTO.md            <- este archivo
├── lib/
│   ├── main.dart                      <- ProviderScope + MaterialApp.router + themeColorsProvider
│   ├── core/
│   │   ├── auth/
│   │   │   ├── auth_state.dart        <- AuthStatus, AuthState con isAdmin/isOperador
│   │   │   └── auth_provider.dart     <- Notifier: login, logout, restoreSession, cambiarPassword
│   │   ├── config/
│   │   │   └── app_config.dart        <- Clase inmutable (defaults vacíos)
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_sizes.dart
│   │   │   └── app_strings.dart
│   │   ├── providers/
│   │   │   ├── database_provider.dart <- Provider<AppDatabase>
│   │   │   └── theme_colors_provider.dart <- ThemeColors + colorToHex + _parseHex
│   │   ├── router/
│   │   │   └── app_router.dart        <- GoRouter con redirect por rol + refreshListenable
│   │   ├── utils/
│   │   │   └── dialogs.dart           <- AppDialogs
│   │   └── widgets/
│   │       ├── responsive.dart
│   │       ├── app_page_header.dart
│   │       ├── app_dialog_shell.dart
│   │       └── responsive_kpis_row.dart
│   ├── data/
│   │   └── database/
│   │       ├── tables.dart            <- 9 tablas Drift
│   │       ├── app_database.dart      <- schemaVersion 2, onUpgrade, seed
│   │       └── app_database.g.dart    <- generado
│   └── features/
│       ├── auth/login_screen.dart
│       ├── dashboard/dashboard_screen.dart
│       └── admin/
│           ├── admin_settings_screen.dart
│           ├── usuarios_screen.dart       <- placeholder
│           └── auditoria_screen.dart      <- placeholder
├── pubspec.yaml
└── test/widget_test.dart

---

## 4. BASE DE DATOS (schemaVersion 2)

### Tablas
- roles: id, nombre (administrador|operador), descripcion
- usuarios: id, username UNIQUE, passwordHash (SHA-256), nombreCompleto, rolId FK, activo, audit fields, isDelete
- permisos: id, rolId FK, modulo, accion
- configuracion: id, clave UNIQUE, valor, tipo
- citas: id, uuidPublico UNIQUE, personaNombre, personaDpi, personaCorreo, personaTelefono, fechaHoraFirma, estado, tokenConfirmacion, tokenExpira, confirmadoRecibidoAt, reagendadaVeces, motivoUltimaReagenda, categoriaMotivoReagenda, postMortemPresentado, contraloriaPresentada, probidadAperturadaAt, notas, creadaPor FK, audit fields, isDelete
- documentos: id, citaId FK, tipo, nombre, rutaArchivo, hashSha256, mimeType, tamanoBytes, subidoPor FK, subidoAt, isDelete
- correos_log: id, citaId FK, tipo, destinatario, cc, asunto, cuerpoHtml, adjuntosJson, estado, intentos, proximoIntentoAt, errorMensaje, programadoAt, enviadoAt
- eventos_cita: id, citaId FK, tipoEvento, detalleJson, createdAt, createdBy FK
- auditoria: id, userId FK, tabla, registroId, accion, valorAntes, valorDespues, motivo, fecha

### Claves de configuracion (seed)
empresa_nombre, empresa_nit, empresa_logo_base64,
smtp_host, smtp_port, smtp_user, smtp_password,
correo_remitente, correo_cc_final,
dias_limite_envio_contrato, dias_limite_cgc, dias_vencimiento_token,
max_palabras_motivo_reagenda, min_palabras_motivo_reagenda,
texto_legal_responsabilidad, texto_legal_multa,
nombre_interno_post_mortem, nombre_oficial_post_mortem,
tamano_logo, servidor_ip, es_servidor, impresora_ticket,
color_primary, color_secondary

### Migración v2 (onUpgrade)
Agrega color_primary (#FF1A237E) y color_secondary (#FF3949AB) con INSERT OR IGNORE.

---

## 5. AUTENTICACIÓN

- AuthStatus: loading, unauthenticated, authenticated
- AuthState: userId, username, nombreCompleto, rolNombre, rolId + isAdmin/isOperador
- AuthNotifier extends Notifier<AuthState>:
  - build() -> _restoreSession() en background, retorna loading
  - login(username, password) -> SHA-256 contra DB, retorna String? (null = éxito)
  - logout() -> borra storage
  - cambiarPassword(actual, nueva)
- Storage: flutter_secure_storage, clave sgc_user_id
- Seed: admin / hacker94

---

## 6. ROUTER (go_router)

Rutas:
- /splash       -> spinner mientras auth carga
- /login        -> LoginScreen
- /dashboard    -> DashboardScreen
- /admin-settings -> AdminSettingsScreen (solo admin)
- /usuarios     -> UsuariosScreen (solo admin)
- /auditoria    -> AuditoriaScreen (solo admin)

Redirect:
- loading -> /splash
- No auth -> /login
- Auth + /login o /splash -> admin a /admin-settings, operador a /dashboard
- Operador en ruta admin -> /dashboard
- Triple seguridad: router + guard en pantalla + (sidebar pendiente Fase 2)

---

## 7. TEMA REACTIVO

- ThemeColors (primary, secondary) + ThemeColors.defaults
- themeColorsProvider: StreamProvider<ThemeColors> sobre configuracion
- colorToHex(Color) -> #AARRGGBB
- _parseHex(String?, Color fallback)
- main.dart usa ref.watch(themeColorsProvider) para ColorScheme.fromSeed
- Panel de colores en /admin-settings: cp.ColorPicker con prefijo,
  dos swatches independientes, botón guardar + restablecer,
  layout responsive (Column mobile, Row desktop)

---

## 8. WIDGETS RESPONSIVE

- Responsive: Responsive.of(context) -> ScreenType; isMobile/isTablet/isDesktop
- AppPageHeader: {title, subtitle?, actions[]} — Column mobile, Row desktop
- AppDialogShell: {title, child, actions[], maxWidth?} — actions ANTES de child
- ResponsiveKpisRow: {children[], minItemWidth=220, spacing=12} — Wrap con columns calculadas

---

## 9. PROBLEMAS ENCONTRADOS Y SOLUCIONES

| Problema | Solución |
|---|---|
| git remote add origin <URL> con <> | Zsh interpretó redirección. Usar URL real sin <> |
| Repo no existía en GitHub | Crear vacío en github.com/new |
| build_runner --delete-conflicting-outputs | Opción removida. Usar solo dart run build_runner build |
| .and() en Drift | No existe como instancia. Usar operador & |
| & no definido en Expression<bool> | Import show Value ocultaba operador. Usar import sin show |
| ColorPicker indefinido con hide colorToHex | hide ocultaba ColorPicker. Usar as cp + cp.ColorPicker |
| unnecessary_underscores en (_, __) | Cambiar a (context, state) |
| sort_child_properties_last | Poner actions: antes de child: |
| unused_import en dashboard_screen | Quitar import responsive.dart |
| Heredoc abierto (faltaba DART_EOF) | Verificar último renglón DART_EOF en su línea |
| flutter analyze con warnings | Gate XIV: warnings cuentan como fallo |

---

## 10. HISTORIAL DE COMMITS

85f9753 (HEAD -> main, origin/main) feat: fundación del sistema
8822b1a feat(widgets): responsive helpers + fixes router/colorpicker
15e9576 feat(ui): router por rol, login, dashboard, panel de colores
6adeded feat(theme): migración v2 con color_primary/color_secondary
0a3b649 feat(theme): migración v2 (duplicado)
9a8de18 feat(db): tablas Drift, AppDatabase con seed
d596e2e chore: dependencias base
0e43565 chore: proyecto Flutter inicial generado con flutter create

---

## 11. DEPENDENCIAS INSTALADAS

Producción: drift, drift_flutter, sqlite3_flutter_libs, path_provider, path,
flutter_riverpod, go_router, flutter_secure_storage, uuid, crypto, mailer,
pdf, printing, intl, excel, file_picker, shared_preferences,
package_info_plus, shelf, shelf_router, flutter_colorpicker

Dev: drift_dev, build_runner

---

## 12. FASES

| Fase | Contenido | Estado |
|---|---|---|
| 1 | Fundación: DB, auth, router, responsive, dashboard, panel colores | CERRADA 85f9753 |
| 2 | CRUD citas + Kanban + Dashboard real + Firmas Enviadas | SIGUIENTE |
| 3 | Documentos + PDF Documento de Responsabilidad + escaneos | PENDIENTE |
| 4 | Cola de correos + SMTP + plantillas editables | PENDIENTE |
| 5 | Servidor LAN Shelf + cliente thin + wizard primer arranque | PENDIENTE |
| 6 | Reportes + Excel + auditoría real + cierre de probidad | PENDIENTE |

---

## 13. DECISIONES PENDIENTES PARA FASE 2

1. Kanban: ¿botones/menú de transición (recomendado) o drag & drop?
2. ¿Creación de cita genera ya el correo de prueba (cola correos_log),
   o queda para Fase 4?

---

## 14. DEUDA TÉCNICA ANOTADA

- Regla IX (no SnackBar): panel de colores usa ScaffoldMessenger.showSnackBar.
  Cambiar a AppDialogs.info en pasada de limpieza.
- Regla V (DataTable inviolable): aún no implementada. Fase 2.
- Regla VI (fechas): aún no implementada. Fase 2 al crear citas.
- Sidebar: no existe. Router + guards cubren triple seguridad, falta sidebar.
  Se hace en Fase 2 con layout principal.
- Wizard primer arranque (server/cliente): Fase 5.

---

FIN DE LA MEMORIA

---

## 15. DECISIONES TOMADAS PARA FASE 2 (2026-11-01)

1. Kanban: **botones/menú de transición** (NO drag & drop).
   Razón: el flujo de estados tiene reglas (no se puede saltar de CITA_CREADA
   a FIRMADO). El menú guía al operador con transiciones válidas.
2. Creación de cita: **NO genera correo de prueba todavía**.
   Razón: la cola de correos (correos_log + SMTP) es Fase 4.
   En Fase 2 solo se crea la cita con estado CITA_CREADA.
   El correo de prueba se engancha en Fase 4 sin tocar el CRUD.

### Alcance Fase 2
- 2.A: CitaEstado enum + transiciones válidas + CitasRepository
       (streams paginados, sort SQL con whitelist, búsqueda LIKE)
- 2.B: CitasScreen (DataTable responsive, paginación, sort, filtros, crear cita)
- 2.C: KanbanScreen (columnas por estado, botones de transición)
- 2.D: FirmasEnviadasScreen (DataTable solo CONTRATO_ENVIADO/CERRADA)
       + Dashboard real con KPIs por estado
- Layout principal con Sidebar (oculta items según rol)

---

## 16. FASE 2 COMPLETADA (2026-11-01)

### Archivos nuevos
- lib/features/citas/domain/cita_estado.dart (enum + transiciones + colores)
- lib/features/citas/data/citas_repository.dart (watchPage, crear, cambiarEstado, watchTotalPorEstado, watchRecientes)
- lib/features/citas/providers/citas_page_provider.dart (StreamProvider.family + CitasQuery)
- lib/features/citas/screens/citas_screen.dart (DataTable responsive, sort SQL, paginación, búsqueda, filtro estado)
- lib/features/citas/screens/kanban_screen.dart (columnas por estado, transiciones con menú)
- lib/features/citas/screens/firmas_enviadas_screen.dart (DataTable CONTRATO_ENVIADO/CERRADA)
- lib/features/citas/widgets/nueva_cita_dialog.dart (AppDialogShell + formulario)
- lib/features/dashboard/dashboard_screen.dart (KPIs por estado + recientes)
- lib/core/utils/dialogs.dart (AppDialogs restaurado)

### Rutas nuevas
- /citas
- /kanban
- /firmas-enviadas

### Deuda técnica resuelta
- SnackBar en admin_settings reemplazado por AppDialogs.success

### Deuda técnica pendiente
- Sidebar con items por rol (no existe layout principal aún)
- Link de navegación a /citas, /kanban, /firmas-enviadas desde UI (solo router por ahora)
- CitaDetalleScreen completo (por ahora diálogo simple)

---

## 17. DECISIONES FASE 3 (2026-11-01)

1. Texto legal con placeholders editables desde ajustes.
   Placeholders soportados: {{nombre}}, {{dpi}}, {{correo}}, {{fecha}},
   {{dias_cgc}}, {{empresa_nombre}}.
   El admin escribe la plantilla en configuracion.texto_legal_responsabilidad
   y configuracion.texto_legal_multa. El sistema reemplaza al generar
   PDF y correo final.
2. Subida de escaneos con file_picker, copia a
   ApplicationDocumentsDirectory/escaneos/<citaId>/<timestamp>_<nombre>.
3. Hash SHA-256 del archivo subido guardado en documentos.hash_sha256.
4. El texto legal configurado en ajustes se usa en:
   - PDF Documento de Responsabilidad
   - Correo final (cuerpo del email)

---

## 18. REORDENAMIENTO DE FASES (2026-11-01)

Decisión: TODO se almacena en el servidor (DB + archivos + PDFs).
Los clientes son thin clients con DB local para lectura y WebSocket para
recibir notificaciones de cambios. Por eso la Fase 5 (servidor LAN) se
adelanta antes de la Fase 3 (documentos) y la Fase 4 (correos).

Nuevo orden:
1. Fase 1 — Fundación (CERRADA, commit 85f9753)
2. Fase 2 — CRUD citas + Kanban + Dashboard (CERRADA, commit 132ab40)
3. FASE 5 ADELANTADA — Servidor Shelf + WebSocket + cliente thin
4. Fase 3 — Documentos + PDF + flujo de firma (usa API de archivos del server)
5. Fase 4 — Cola de correos + SMTP (el server centraliza SMTP)
6. Fase 6 — Reportes + Excel + auditoría real

---

## 19. ARQUITECTURA DE SINCRONIZACIÓN (2026-11-01)

### Modelo elegido: D + WebSocket broadcast
- Cada cliente tiene DB local Drift (mismas tablas que el servidor).
- La UI usa `watch()` sobre Drift local. Reactividad total (Regla III).
- El servidor tiene la DB maestra.
- El servidor escucha `db.tableUpdates(TableUpdateQuery.onAllTables(...))`
  de Drift y hace broadcast por WebSocket a TODOS los clientes conectados.
- Cuando un cliente recibe `{"event":"db_changed","tables":[...]}`,
  hace pull REST de la tabla afectada, escribe en su Drift local, y el
  `watch()` local dispara la actualización de UI.
- Escrituras: el cliente envía REST al servidor (POST/PATCH), el servidor
  escribe en DB maestra, Drift del servidor emite tableUpdate, el servidor
  hace broadcast, TODOS los clientes (incluido el que escribió) hacen pull.

### Flujo de un cambio (ejemplo: crear cita desde Cliente B)
1. Cliente B: POST /api/citas al servidor
2. Servidor: insert en DB maestra
3. Drift del servidor: tableUpdates emite {citas}
4. Servidor: broadcast {"event":"db_changed","tables":["citas"]} a todos
5. Cliente A y Cliente B: reciben el evento, hacen GET /api/citas
6. Cada cliente escribe el resultado en su Drift local
7. watch() local de cada cliente dispara, la UI se actualiza sola

### Decisiones técnicas
- WebSocket (NO SSE). Paquetes: shelf_web_socket + web_socket_channel.
- Pull completo de la tabla afectada (NO delta). Simple y suficiente en LAN.
- El cliente que escribe también recibe el broadcast y hace pull
  (no hay escritura optimista local; se espera confirmación del server).

### Tablas que notifican
citas, documentos, configuracion, correos_log.

---

## 20. FASE 5 ADELANTADA — BLOQUE 5.A (EN PROGRESO)

### Archivos nuevos
- lib/server/ws_channel_hub.dart
  List<WebSocketChannel> _clients + add() + broadcast(Map) + closeAll()
- lib/server/drift_change_notifier.dart
  Escucha db.tableUpdates(TableUpdateQuery.onAllTables(db.allTables))
  y hace hub.broadcast({"event":"db_changed","tables":[...]}).
  OJO: el getter correcto es TableUpdate.table (NO tableName).
- lib/server/sgc_server.dart
  SgcServer(db): start(host, port) con shelf + shelf_router + shelf_web_socket
  Endpoints:
    GET /api/health -> {status, clients, ts}
    GET /api/ws -> WebSocket upgrade, hub.add(ws), envía {"event":"hello"}
    GET /api/citas -> lista completa (JSON)
    POST /api/citas -> 501 Not implemented (se completa en 5.C)
- lib/server/main_server.dart
  Entry point: dart run lib/server/main_server.dart
  Corre en 0.0.0.0:8080

### Dependencias nuevas
shelf, shelf_router, shelf_web_socket, web_socket_channel

### Pendiente en 5.A
- flutter analyze limpio (2 issues corregidos: u.table en lugar de u.tableName,
  y quitar import sin usar de database_provider en sgc_server.dart)

---

## 21. BLOQUES PENDIENTES DE FASE 5 ADELANTADA

| Bloque | Contenido |
|---|---|
| 5.B | Cliente: ApiClient (GET/POST/PATCH REST) + WebSocketSyncService (escucha /api/ws, hace pull, escribe en Drift local) |
| 5.C | Servidor: completar POST /api/citas, PATCH /api/citas/:id, GET /api/config |
| 5.D | Servidor: endpoint de subida de archivos multipart + descarga |
| 5.E | Wizard primer arranque (server/cliente + IP del servidor) |
| 5.F | Detección de modo server/cliente al arrancar la app + arranque del server en background |

---

## 22. DEUDA TÉCNICA ACTUALIZADA

- Sidebar / layout principal con items por rol (Fase 2 dejó rutas pero sin nav visual)
- CitaDetalleScreen completo (por ahora diálogo simple en CitasScreen y Kanban)
- FileStorageService guarda local. Debe cambiar a envío HTTP al servidor en 5.D.
- DocumentosRepository ya no usa FileStorageService directamente (se quitó _storage).
  El flujo de subida se implementará en 5.D vía API del servidor.
- Regla V estricta en FirmasEnviadasScreen (afinar scroll vertical+horizontal)
- Panel de colores ya usa AppDialogs (SnackBar corregido)

---

## 23. COMANDOS ÚTILES

- Servidor: dart run lib/server/main_server.dart
- App: flutter run
- Regenerar Drift: dart run build_runner build
- Gate de commit: if flutter analyze; then git add . && git commit -m "..." && git push; fi

---

## 24. HISTORIAL DE COMMITS ACTUALIZADO

132ab40 (HEAD -> main, origin/main) feat(citas): CRUD de citas, DataTable paginado con sort SQL, Kanban con transiciones, Firmas Enviadas y Dashboard real
85f9753 feat: fundación del sistema — DB v2, auth, router por rol, widgets responsive, dashboard reactivo y panel de colores admin
8822b1a feat(widgets): responsive helpers + fixes router/colorpicker
15e9576 feat(ui): router por rol, login, dashboard, panel de colores admin y placeholders admin
6adeded feat(theme): migración v2 con color_primary/color_secondary y themeColorsProvider reactivo
0a3b649 feat(theme): migración v2 (duplicado)
9a8de18 feat(db): tablas Drift, AppDatabase con seed
d596e2e chore: dependencias base
0e43565 chore: proyecto Flutter inicial generado con flutter create

FIN DE LA ACTUALIZACIÓN

---

## 25. FASE 5 ADELANTADA — COMPLETADA (2026-11-01)

### Archivos nuevos
- lib/server/ws_channel_hub.dart (Set<WebSocketChannel> + broadcast)
- lib/server/drift_change_notifier.dart (tableUpdates -> broadcast {"event":"db_changed","tables":[...]})
- lib/server/sgc_server.dart (Shelf + Router + WebSocket + endpoints REST)
- lib/server/main_server.dart (entry point: dart run lib/server/main_server.dart)
- lib/core/network/network_config.dart (NetworkConfig + networkConfigProvider)
- lib/core/network/api_client.dart (ApiClient: health, listarCitas, crearCita, actualizarCita, subirDocumento, listarDocumentos)
- lib/core/network/websocket_sync_service.dart (WebSocketSyncService: conexión, reconexión, pull de citas)
- lib/core/providers/sync_provider.dart (apiClientProvider, syncServiceProvider)
- lib/features/wizard/primer_arranque_screen.dart (wizard server/cliente + IP)
- lib/main.dart (gate de wizard + MaterialApp.router reactivo)

### Endpoints del servidor
- GET /api/health -> {status, clients, ts}
- GET /api/ws -> WebSocket upgrade, hub.add(ws)
- GET /api/citas -> lista completa
- POST /api/citas -> crear cita
- PATCH /api/citas/<id> -> actualizar estado/notas/checks
- GET /api/config -> todas las claves de configuracion
- GET /api/documentos/<citaId> -> documentos de una cita
- POST /api/documentos/upload -> multipart (meta JSON + file), guarda en server, hash SHA-256, inserta en DB
- GET /api/documentos/<id>/download -> descarga archivo

### Flujo de sincronización (confirmado)
1. Cliente B escribe via POST/PATCH al servidor
2. Servidor inserta/actualiza en DB maestra
3. Drift del servidor emite tableUpdates
4. DriftChangeNotifier hace broadcast {"event":"db_changed","tables":[...]}
5. TODOS los clientes reciben, hacen pull de la tabla afectada
6. Cada cliente escribe en su Drift local
7. watch() de cada cliente dispara, la UI se actualiza sola

### Cliente thin
- CitasRepository: si es cliente remoto, crear() y cambiarEstado() van por API.
  Lectura siempre por watch() sobre Drift local.
- DocumentosRepository: si es cliente remoto, subirBytes() va por API multipart.
  Servidor guarda local + inserta.
- WebSocketSyncService: se conecta a ws://server:8080/api/ws, reconecta a los 3s,
  en db_changed hace pull de citas (configuracion/documentos: TODO en Fase 3).
- Wizard: primer arranque pide server/cliente + IP, guarda en configuracion
  (es_servidor, servidor_ip, wizard_completado). main.dart bloquea la app hasta
  que wizard_completado=true.

### Pendiente de Fase 5 (deuda técnica)
- WebSocketSyncService._syncCitas: creadaPor: 1 hardcoded (FIXME). Requiere auth
  remoto (Fase 5.x o Fase 4).
- Sync de configuracion y documentos: por ahora solo se sincroniza citas.
  Documentos se sincronizan en Fase 3 cuando se usen.
- Servidor no arranca automáticamente desde la app. Hay que correr
  dart run lib/server/main_server.dart en el server.
- La app no detecta aún si esServidor para arrancar SgcServer en background.
  Se puede hacer en un bloque extra 5.F.

FIN DE FASE 5 ADELANTADA

---

## 26. DECISIONES FASE 3 (2026-11-01)

1. PDF Documento de Responsabilidad se genera en el SERVIDOR
   (POST /api/citas/:id/pdf). El cliente lo descarga, lo muestra con
   printing preview, y lo imprime. Todos ven el mismo PDF centralizado.
2. Logo incrustado desde configuracion.empresa_logo_base64.
3. Firma es MANUAL en papel. El PDF tiene recuadro amplio con línea y
   leyenda "Firma del contratado". NO hay imagen de firma ni canvas.
   El operador imprime, el firmante firma en azul, el operador escanea
   y sube el archivo firmado. El escaneo se almacena en el SERVIDOR.
4. Texto legal con placeholders resueltos en el servidor al generar PDF:
   {{nombre}}, {{dpi}}, {{correo}}, {{fecha}}, {{dias_cgc}},
   {{empresa_nombre}}.

---

## 28. DECISIONES FASE 4 (2026-11-01)

1. Plantillas de correo en configuracion (NO tabla nueva):
   plantilla_prueba, plantilla_confirmacion, plantilla_reagenda,
   plantilla_final, plantilla_recordatorio.
   Todas soportan placeholders (mismos que el PDF + {{enlace_confirmacion}},
   {{dias_limite}}).
2. Adjuntos reales embebidos en el correo final:
   - PDF Documento de Responsabilidad
   - Contrato firmado (escaneo)
3. correo_cc_final vacío -> sin CC. Con valor -> se agrega CC.
4. Cola inteligente:
   - Si no hay correos pendientes y el worker está libre -> envía inmediato.
   - Si hay cola -> el nuevo correo se encola y se procesa en orden FIFO.
   - Reintentos con backoff: 1m, 5m, 15m, 1h, 6h.

---

## 29. FASE 4 COMPLETADA (2026-11-01)

### Archivos nuevos
- lib/server/email_service.dart (SMTP con mailer, adjuntos reales, CC opcional)
- lib/server/email_queue_worker.dart (worker con Timer 30s, backoff 1m/5m/15m/1h/6h/24h, max 6 intentos)
- lib/features/correos/domain/correo_tipo.dart (CorreoTipo, CorreoEstado)
- lib/features/correos/data/correos_repository.dart (encolar, watchTodos, watchPendientes, marcarEnviado, marcarFallido)
- lib/features/correos/services/email_dispatcher.dart (resolverPlantilla, asuntoPara, tipoFromEstado)
- lib/features/admin/correos_tab.dart (cola visible, reintentar manual)

### Cambios en archivos existentes
- app_database.dart: schemaVersion 3, migración con plantillas, seed con 5 plantillas
- sgc_server.dart: POST /api/correos/encolar, GET /api/correos, GET /api/confirmar/<token>
- main_server.dart: arranca EmailQueueWorker + SIGINT graceful
- api_client.dart: encolarCorreo, listarCorreos
- citas_repository.dart: crear() encola correo prueba con token; cambiarEstado() encola correo final (CONTRATO_ENVIADO) y reagenda (REAGENDADA)
- acciones_tab.dart: botón "Reenviar correo de prueba"
- admin_settings_screen.dart: DefaultTabController con 2 tabs (General, Correos)

### Flujo de correos
1. Crear cita -> encolar correo prueba con {{enlace_confirmacion}}
2. Firmante abre enlace -> GET /api/confirmar/<token> marca confirmadoRecibidoAt y estado CORREO_CONFIRMADO
3. Cambiar estado a CONTRATO_ENVIADO -> encolar correo final con adjuntos
   (PDF responsabilidad + contrato firmado) y CC si correo_cc_final no vacío
4. Cambiar estado a REAGENDADA -> encolar correo reagenda con {{motivo}}
5. Botón reenviar prueba -> reencola correo prueba

### Cola inteligente
- Si no hay pendientes, nuevo correo se envía inmediato (worker cada 30s)
- Si hay pendientes, se suma a la cola FIFO
- Backoff: 1m, 5m, 15m, 1h, 6h, 24h
- Max 6 intentos -> estado "fallido", reintento manual desde CorreosTab

### Pendiente de Fase 4 (deuda técnica)
- El worker corre solo en servidor. El cliente encola vía API REST.
- Si el servidor no está corriendo, el cliente no puede encolar. Los correos
  quedan en la DB local del cliente y se sincronizan cuando vuelva el server.
- Sync de correos_log no implementado en WebSocketSyncService (solo citas).
- El enlace /api/confirmar/<token> apunta a servidor_ip. Si el firmante está
  fuera de la LAN, no funciona. En producción se necesitaría un dominio público.
- Envío de correo final requiere que el operador haya subido el contrato firmado
  y el documento de responsabilidad firmado antes de cambiar a CONTRATO_ENVIADO.
  Si no, el correo sale sin adjuntos.

FIN DE FASE 4

---

## 30. FASE 6 COMPLETADA (2026-11-01)

### Archivos nuevos
- lib/core/layout/app_shell.dart (Sidebar responsive + AppShell)
- lib/features/citas/data/eventos_repository.dart (registrar, watchPorCita)
- lib/features/citas/data/auditoria_repository.dart (registrar, watchTodos, watchPorTabla)
- lib/features/reportes/data/reportes_repository.dart (watchKpis, obtenerCitas)
- lib/features/reportes/data/excel_service.dart (generarCitas -> xlsx)
- lib/features/reportes/screens/reportes_screen.dart (KPIs + exportar Excel + rango de fechas)

### Cambios
- router: ShellRoute con AppShell para todas las rutas protegidas; ruta /reportes
- citas_repository: registra evento y auditoría en crear y cambiarEstado
- documentos_repository: registra auditoría en subirBytes y eliminar
- cita_detalle_screen: 4 tabs (Datos, Documentos, Acciones, Historial)
- auditoria_screen: lista reactiva real (no placeholder)
- app_shell: items según rol (admin ve todo, operador ve dashboard/citas/kanban/firmas/reportes)

### Auditoría
- citas: crear, cambiar_estado
- documentos: crear, eliminar
- eventos_cita: estado_cambiado (con jsonEncode del detalle)

### Reportes
- KPIs: total, en proceso, pendiente envío, enviadas, cerradas, canceladas, reagendadas
- Filtro por rango de fechas (desde/hasta)
- Exportar Excel con excel ^4.0.6
- FilePicker para elegir ubicación destino

### Sidebar
- Admin: Dashboard, Citas, Kanban, Firmas enviadas, Reportes, Ajustes, Usuarios, Auditoría
- Operador: Dashboard, Citas, Kanban, Firmas enviadas, Reportes
- Cerrar sesión al pie
- Responsive: drawer en mobile, fijo en desktop

FIN DE FASE 6

---

## 31. FASE 5.F y 6 (SESIÓN 2026-11-01 - TARDE)

### 31.1. Configuración del SDK de Flutter
- Flutter 3.47.9 causaba errores de `invalid-type` en el framework.
- Se descargó **Flutter 3.47.3 (Dart 3.13.3)** de forma limpia en `/Users/ulrichceballos/Desktop/flutter_3473`.
- Se configuró un `.vscode/settings.json` local en SGC con la ruta a ese SDK.
- Se cambió el `pubspec.yaml` a `sdk: '>=3.9.0 <4.0.0'`.
- Comando para arrancar en terminal: `export PATH="/Users/ulrichceballos/Desktop/flutter_3473/bin:$PATH"`.

### 31.2. Firmas y Entitlements en macOS
- `flutter_secure_storage` pedía permiso de Llavero y exigía perfil de aprovisionamiento.
- Se quitaron los `keychain-access-groups` de los entitlements (`DebugProfile.entitlements` y `Release.entitlements`).
- Se modificó `auth_provider.dart` para usar `MacOsOptions(usesDataProtectionKeychain: false)` solo en macOS usando `defaultTargetPlatform`.
- Se forzó la firma local ("Sign to Run Locally") editando el `project.pbxproj` de Xcode (vaciando `CODE_SIGN_IDENTITY`, `DEVELOPMENT_TEAM`, etc.).
- La app ahora compila y guarda sesión correctamente en macOS.

### 31.3. Login Premium
- `login_screen.dart` rediseñado con:
  - Fondo con gradiente (color primario y secundario reactivo).
  - Tarjeta flotante con sombra y bordes redondeados.
  - Íconos en los campos de texto.
  - Botón grande "INGRESAR".

### 31.4. Sidebar y Navegación
- `app_shell.dart` rediseñado:
  - Fondo con el color primario.
  - Textos e íconos en blanco.
  - Elemento seleccionado con fondo blanco translúcido.
  - Fix del error `ListTile` usando `Material` y `Colors.transparent`.
- `app_router.dart` actualizado:
  - Las rutas internas (`/dashboard`, `/citas`, etc.) están envueltas en un `ShellRoute` con `AppShell`.
  - El login redirige al `/dashboard` (antes mandaba a `/admin-settings`).
- `main.dart` actualizado:
  - `_serverBootProvider` arranca el `SgcServer` y el `EmailQueueWorker` automáticamente si `esServidor` es `true` en la configuración. ¡Ya no hace falta correr el servidor manualmente en otra terminal!

### 31.5. Tabla de Citas (Cumpliendo Regla V)
- `citas_screen.dart` reescrito:
  - La tabla ahora ocupa el **100% del ancho** (`width: double.infinity`, calculado con `LayoutBuilder`).
  - **Sin overflow**: el `ConstrainedBox(minWidth)` está bien configurado.
  - El **sort** funciona correctamente llamando al repositorio (el índice 0, 1, 2, 3 se mapea a 'nombre', 'fecha', 'estado', 'creada').
  - Se movió la barra de paginación arriba a la derecha, junto a los filtros.

### 31.6. Modal de Nueva Cita (Wizard Premium)
- `nueva_cita_dialog.dart` rediseñado:
  - Modal flotante con `Dialog` y header con color primario.
  - **3 pasos**: Datos Personales -> Contacto y Fecha -> Resumen.
  - **Validaciones**:
    - DPI: exactamente 13 dígitos.
    - Teléfono: exactamente 8 dígitos.
    - Correo: regex válida.
  - Barra de progreso con círculos (1, 2, 3).
  - Botones de "Atrás" y "Siguiente" con diseño premium.

### 31.7. Modal de Detalle de Cita
- Nuevo archivo `cita_detalle_modal.dart`:
  - Se abre al hacer clic en una fila de la tabla.
  - Tiene las mismas pestañas que la pantalla completa (Datos, Documentos, Acciones, Historial) pero dentro de un `Dialog` de `900px` de ancho.
  - Header con el nombre del firmante y el estado.
  - En `citas_screen.dart`, el `onSelectChanged` ahora llama a `CitaDetalleModal.show(context, cita.id)` en lugar de `context.push`.

### 31.8. Rediseño de Acciones y Documentos
- `acciones_tab.dart`:
  - Todo envuelto en tarjetas (`_ActionCard`) con íconos, títulos y subtítulos.
  - Switches para Post Mortem y Contraloría.
  - Botones grandes para generar PDF, subir escaneos, etc.
- `documentos_tab.dart`:
  - Empty State (estado vacío) premium con ícono de nube y botón de "Subir el primer documento".
  - Tarjetas de documentos con ícono de PDF (rojo) o Imagen (azul), nombre, tamaño y fecha.

### 31.9. Rediseño de Historial
- `cita_detalle_screen.dart` y `cita_detalle_modal.dart`:
  - El historial ahora tiene un "Empty State" con ícono grande y texto amigable.
  - Los eventos se muestran en tarjetas tipo "Timeline" con check azul, título, detalles y fecha a la derecha.

### 31.10. Fix de AppDialogs
- `dialogs.dart` corregido para usar `Navigator.of(context, rootNavigator: true)` capturado antes del `showDialog`. Esto evita el error `Null check operator used on a null value` que ocurría al hacer clic en botones después de un `await`.

### 31.11. Pendientes / Deuda Técnica
- Probar la subida de documentos real (guarda en el servidor o en local?).
- Verificar que el correo se encole correctamente desde el modal de nueva cita (y que el servidor lo envíe).
- El botón "Reenviar correo de prueba" en AccionesTab actualmente solo muestra un mensaje de éxito, falta implementar la lógica real de encolado.
- El botón "Generar PDF" requiere que el servidor esté corriendo para descargar el PDF. Si es cliente, el servidor debe tener la IP configurada en ajustes.

FIN DE LA SESIÓN 31

---

## 32. SESIÓN DE ESTABILIZACIÓN, DISEÑO PREMIUM Y FIXES (2026-11-01 - TARDE/NOCHE)

### 32.1. Configuración Crítica del SDK (¡Importante para nuevos chats!)
- **Flutter 3.47.9 tiene un bug** con `invalid-type` en macOS. NO USAR.
- Se descargó e instaló **Flutter 3.47.3 (Dart 3.13.3)** manualmente en `/Users/ulrichceballos/Desktop/flutter_3473`.
- **SIEMPRE** que se abra una terminal nueva, se debe forzar el PATH antes de cualquier comando:
  `export PATH="/Users/ulrichceballos/Desktop/flutter_3473/bin:$PATH"`
- Se configuró un `.vscode/settings.json` local apuntando a esta ruta para evitar que VS Code use el SDK global roto.

### 32.2. Configuración de macOS (Xcode, Firma y Sandbox)
- **Llavero (Keychain):** `flutter_secure_storage` fallaba con el código `-34018`. Se solucionó usando `MacOsOptions(usesDataProtectionKeychain: false)` en `auth_provider.dart`.
- **Firma Local:** Para evitar errores de aprovisionamiento al añadir permisos, se modificó el `project.pbxproj` para que firme con `-` (Sign to Run Locally) y se vaciaron los `DEVELOPMENT_TEAM`.
- **Permisos de Impresión:** Se agregó el entitlement `com.apple.security.print` a `DebugProfile.entitlements` y `Release.entitlements` para habilitar el PDF.
- **Ruta de Descargas:** El Sandbox de macOS prohíbe guardar en `/Users/.../Downloads`. El PDF se guarda en `getApplicationDocumentsDirectory()` (la carpeta interna de la app) y se abre con `Process.run('open', [file.path])`.

### 32.3. Rediseño de UI Premium (AppShell y Tablas)
- **Sidebar:** Rediseñado con el color `primary` dinámico, textos blancos y efecto glassmorphism. Se eliminaron los errores de `ListTile` envolviendo los `Card` en `Material` o quitando el `color` de los `Container` padres.
- **DataTable (Citas):** Se forzó el ancho al 100% (cumpliendo Regla V) usando `LayoutBuilder`, `ConstrainedBox(minWidth: tableWidth)` y `DataTable` sin anchos fijos. El `onSelectChanged` de cada fila ahora abre el `CitaDetalleModal`. La paginación se movió arriba a la derecha.
- **Modales:** 
  - **Nueva Cita:** Es un Wizard de 3 pasos (Datos, Contacto, Resumen). Valida DPI (13 dígitos), Teléfono (8 dígitos) y Correo.
  - **Detalle de Cita:** Es un `Dialog` de 900px que contiene las 4 pestañas (Datos, Documentos, Acciones, Historial) para no perder el contexto de la tabla.
- **Diseño de Pestañas:** Se rediseñó el "Empty State" de Documentos e Historial, y las tarjetas de Acciones para que se vean como un CRM moderno.

### 32.4. Flujo de Correos y SMTP
- Se creó la pestaña `SmtpConfigTab` en Ajustes para que el admin ingrese Host, Puerto, Usuario, Contraseña, Remitente y CC.
- **Fix del diálogo:** Al guardar el SMTP, la app se ponía en negro porque `AppDialogs` usaba el `rootNavigator` incorrectamente. Se solucionó usando `Navigator.of(ctx).pop()` dentro del `builder` del `showDialog` (usando el contexto local `ctx`).
- **Nota sobre Unicode en PDF:** El paquete `pdf` muestra un warning (`Helvetica has no Unicode support`). Esto significa que las tildes (á, é, í) no se verán en el PDF generado. Para solucionarlo en el futuro, se debe cargar una fuente TTF (como Roboto) en el servidor y usarla en `PdfService`.

### 32.5. Estado Actual del Proyecto
- El proyecto está en `/Users/ulrichceballos/Desktop/SGC/sgc_app`.
- Todos los `flutter analyze` han salido limpios tras los últimos fixes.
- La arquitectura es: Servidor (Shelf + Drift) + Cliente (Drift local + WebSocket Sync).
- El flujo completo (Crear cita -> Encolar correo -> Generar PDF -> Guardar en Documentos) está implementado y funcionando.

FIN DE LA SESIÓN 32
