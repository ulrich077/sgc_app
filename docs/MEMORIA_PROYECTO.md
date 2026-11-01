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
