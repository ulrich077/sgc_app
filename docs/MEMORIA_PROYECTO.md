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

---

## 18. GRÁFICA DE ACTIVIDAD Y CROSS-FILTERING EN DASHBOARD (2026-11-02)

### 18.1. Paquete Utilizado
- **`fl_chart`**: Se instaló con `flutter pub add fl_chart`.
- Es el paquete estándar para gráficas en Flutter. Permite gráficas de líneas, barras, pastel, etc.

### 18.2. Componente `_LineChartCard` (Gráfica de Líneas)
- Se agregó una tarjeta entre los KPIs y el calendario/citas.
- **Datos**: Se conecta a `repo.watchTodas()` (Drift Stream), por lo que es **100% reactivo**.
  - Cualquier `INSERT` o `UPDATE` en la tabla `citas` redibuja la gráfica automáticamente.
- **Rango**: 11 días en total (5 días antes de hoy y 5 días después).
- **Series (3 líneas)**:
  - **Azul**: Agendados (estado != CANCELADA y != CERRADA).
  - **Verde**: Terminados (estado == CERRADA).
  - **Naranja**: Reagendados (estado == REAGENDADA).
- **Diseño**:
  - Leyenda superior (estilo Chart.js).
  - Cuadrícula visible (horizontal y vertical) en gris suave.
  - Líneas curvas (`isCurved: true`) con puntos (`FlDotData`).
  - Tooltips al pasar el mouse (muestra la cantidad de citas).
- **Escala Dinámica**:
  - El `maxY` se calcula dinámicamente como `maxValor + 2` (mínimo 5) para que la línea más alta no se desborde.
  - El intervalo del eje Y se calcula como `(maxY / 5).ceilToDouble()`.
- **Eje X**: Muestra la fecha cada 2 días (formato `d MMM`, ej. "3 nov").

### 18.3. Cross-Filtering (Filtrado Cruzado)
- Al hacer clic en un punto de la gráfica, se dispara un callback (`onPuntoSeleccionado`).
- El Dashboard recibe la fecha y el tipo de serie (agendados, terminados, reagendados).
- Se actualiza `_selectedDay` y `_focusedDay` en el calendario, y el panel de "Citas para el día" se filtra para mostrar solo las citas de ese tipo en ese día.
- Si el usuario hace clic en el calendario manualmente, se quita el filtro y se muestran todas las citas del día.

### 18.4. Problemas Resueltos
| Problema | Solución |
|---|---|
| La gráfica se desbordaba | `maxY` dinámico: `(maxValor + 2).ceilToDouble().clamp(5.0, ...)`. |
| Se repetían los días | Se generó una lista fija de 11 días (5 antes, 5 después) y se agrupa por fecha exacta. |
| Error `setState` en `ConsumerWidget` | Se cambiaron las llamadas directas por callbacks (`onPuntoSeleccionado`). |
| Variables no usadas (`_filtroTipoGrafica`, `_filtroFechaGrafica`) | Se eliminaron porque el filtrado se hace directamente en `_cargarCitasDelDia`. |

---

FIN DE LA ACTUALIZACIÓN

---

## 19. CONEXIÓN LAN, DESCUBRIMIENTO mDNS Y TLS (2026-11-02)

### 19.1. Contexto
Se trabajó en el Frente 1 (descubrimiento mDNS) y se planeó el Frente 2 (TLS autofirmado).
La prueba real de LAN no fue posible porque el entorno era un hotspot de iPhone
(AP isolation de iOS impide comunicación entre dispositivos). El código quedó listo
para probarse en una LAN real (router del Congreso o cable Ethernet directo).

### 19.2. Hallazgos de red
- El servidor SÍ publica `_sgc._tcp` correctamente (`dns-sd -B` lo confirma).
- `dns-sd -L SGC-Server _sgc._tcp local` muestra `interface 15` (Wi-Fi real, `172.20.10.3`).
- `interface 1` era loopback (`127.0.0.1`), no `utun` de VPN (falsa alarma inicial).
- **El hotspot de iPhone NO sirve para probar** (AP isolation). Probar en LAN real o cable directo.
- En Windows sin Bonjour, mDNS falla en silencio. La IP manual es el fallback correcto.
- En LAN corporativa, si hay "AP isolation" o multicast bloqueado, mDNS falla pero la IP manual funciona.

### 19.3. Frente 1 — Descubrimiento mDNS endurecido (COMPLETADO)
Archivos modificados:
- **`lib/core/network/bonjour_helper.dart`** (NUEVO):
  - `BonjourHelper.disponible()`: detecta si Bonjour está instalado en Windows vía
    `Process.run('sc', ['query', 'Bonjour Service'])`. En macOS/Linux siempre `true`.
  - `BonjourHelper.mensajeNoDisponible`: mensaje honesto para el usuario.
- **`lib/core/network/mdns_discovery.dart`** (REESCRITO):
  - Verifica `BonjourHelper.disponible()` antes de intentar `bonsoir`.
  - Filtra IPs válidas de LAN (`_esIpDeLan`): solo acepta `10.x.x.x`, `172.16-31.x.x`, `192.168.x.x`.
    Descarta `127.x`, `169.254.x`, IPv6.
  - `_limpiarIp` quita sufijos `%en0` que a veces devuelve `bonsoir`.
  - Timeout de 8s, limpieza correcta de stream y `discovery.stop()` en `finally`.
  - Logs `debugPrint('[mDNS] ...')` para diagnóstico.
- **`admin_settings_screen.dart`**:
  - `_buscarServidor` usa `BonjourHelper.disponible()` y muestra mensaje honesto en Windows sin Bonjour.
  - Import `bonjour_helper.dart` añadido.
- **`flutter analyze`: No issues found!**

### 19.4. Frente 2 — TLS autofirmado (PLANIFICADO, NO IMPLEMENTADO AÚN)
Decisiones confirmadas:
- **Opción B2**: certificado generado desde la app con `basic_utils` (no `openssl` del sistema,
  para funcionar en Windows y macOS).
- **Botón en `_NetworkPanel`** de `admin_settings_screen.dart`, solo visible para rol `administrador`
  y solo si `es_servidor == true`.
- **Cert guardado en** `getApplicationSupportDirectory()/certs/sgc_cert.pem` y `sgc_key.pem`
  (no en `assets/`, que es solo lectura en runtime).
- **SAN recomendado:** `['localhost', '127.0.0.1', <IP local detectada>]`.
- **Si ya existe cert:** confirm de "¿Regenerarlo?" antes de sobrescribir.
- **Diálogo de reinicio:** `AppDialogs.choose` con "Reiniciar ahora" / "Descartar".
  El mensaje debe decir explícitamente que el admin deberá **abrir la app manualmente** desde el Dock/Launchpad.
- **Cuenta regresiva de 5s** con spinner y texto:
  *"La aplicación se cerrará en 5 segundos. ⚠️ Deberás abrirla manualmente de nuevo desde el Dock."*
- **Cierre:** `await server.stop()` + `exit(0)`. No se usa `restart_app` porque falla en macOS sandboxed.
- **Puerto:** cambia de `8080` a `8443`.
- **`network_config.dart`:** `baseHttp` → `https://`, `baseWs` → `wss://`.
- **`api_client.dart`:** `IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true)`.
- **`sgc_server.dart`:** `SecurityContext` + `io.serve(handler, host, 8443, securityContext: ctx)`.
  Fallback a HTTP en 8080 si el cert no existe (con warning en `stderr`).
- **Pendiente de decidir:** el PDF de `acciones_tab.dart:99` (descarga interna con `IOClient` +
  `open_file`, o navegador externo con warning de cert autofirmado).

### 19.5. Código muerto identificado (NO BORRADO, tema aparte)
- `{{enlace_confirmacion}}` en `app_database.dart:38 y :140` (plantilla por defecto).
- `enlace` en `citas_repository.dart:185-187` (`http://ip:puerto/api/confirmar/$token`).
- Endpoint `/api/confirmar/<token>` en `sgc_server.dart:319-330`.
- `placeholder_resolver.dart:4, 16, 34` y `email_dispatcher.dart:53-54`.
- **Contexto:** el código actual manda un **link HTTP en texto plano**, NO un `mailto:`.
  El HTML con botón "Confirmar Recibido" que se revisó vino de un correo enviado manualmente
  (probablemente desde Gmail, por el `class="m_..."`), NO del sistema.
- **Decisión pendiente:** si implementar `mailto:` (Camino 1) o dejar el link HTTP (Camino 2).
  En intranet pura, el link HTTP solo funciona si el firmante está dentro de la LAN del Congreso.

### 19.6. Entorno de prueba
- Hotspot iPhone: ❌ No sirve (AP isolation de iOS).
- Router Wi-Fi normal: ✅ Funciona (si no hay AP isolation ni multicast bloqueado).
- Cable Ethernet directo con IPs estáticas: ✅ Funciona.
- LAN del Congreso: ✅ Debería funcionar (verificar con el admin de red que no haya AP isolation).

### 19.7. Comandos útiles
```bash
# Ver si el servicio mDNS está publicado
dns-sd -B _sgc._tcp local

# Ver la IP que anuncia mDNS
dns-sd -L SGC-Server _sgc._tcp local
dns-sd -G v4 <hostname>.local

# Verificar expiración del cert (cuando exista)
openssl x509 -in assets/certs/sgc_cert.pem -noout -dates



---

## Notas para la próxima sesión

Cuando retomes el Frente 2 (TLS), lo primero es:

1. **Añadir `basic_utils`** a `pubspec.yaml`.
2. **Crear `lib/core/network/cert_service.dart`** con la generación del cert.
3. **Añadir el botón** en `_NetworkPanel` (solo admin, solo servidor).
4. **Implementar el diálogo** con cuenta regresiva de 5s y aviso de "abrir manualmente".
5. **Modificar `sgc_server.dart`** para leer el cert con `File` y usar `SecurityContext`.
6. **Cambiar `network_config.dart`** a `https` + `wss` + puerto 8443.
7. **Modificar `api_client.dart`** con `IOClient` + `badCertificateCallback`.
8. **Decidir el PDF** (descarga interna vs navegador externo).
9. **`flutter analyze` limpio**.

**Regla I recordatorio:** el código actual manda un link HTTP, no un mailto. Eso contradice el diseño de "correo de vuelta" que mencionaste. Antes de tocar TLS, conviene decidir si se implementa el mailto (Camino 1) o se deja el link HTTP (Camino 2). Ese es un tema aparte que no bloquea TLS pero que quedó pendiente.

---

## 20. TLS AUTOFIRMADO — IMPLEMENTACIÓN (2026-11-03)

### 20.1. Contexto
Se retomó el Frente 2 (TLS) que había quedado planificado en la sesión anterior.
El objetivo: que el servidor SGC corra en HTTPS (puerto 8443) y el cliente se conecte
con `badCertificateCallback` para aceptar el certificado autofirmado.

### 20.2. Decisiones confirmadas
- **Librería:** `basic_utils` para generar el certificado en Dart puro (sin `openssl`
  del sistema), porque el sistema debe funcionar en macOS y Windows.
- **Versión:** `basic_utils: ^5.7.0` (NO `^5.8.2`). La 5.8.x entra en conflicto con
  `excel ^4.0.6` porque ambas dependen de versiones incompatibles de `archive`
  (`excel` → `archive ^3.6.1`, `basic_utils 5.8` → `archive ^4.0.2`).
- **Ubicación del cert:** `getApplicationSupportDirectory()/certs/sgc_cert.pem` y `sgc_key.pem`.
  No en `assets/` (solo lectura en runtime).
- **Botón:** en `_NetworkPanel` de `admin_settings_screen.dart`, en una sección nueva,
  visible solo si `isAdmin == true` y `es_servidor == true`.
- **Diálogo de reinicio:** `AppDialogs.choose` con "Reiniciar ahora" / "Descartar".
  El mensaje debe decir explícitamente que el admin deberá **abrir la app manualmente**
  desde el Dock/Launchpad (porque `restart_app` falla en macOS sandboxed).
- **Cuenta regresiva:** 5 segundos con spinner y texto:
  *"La aplicación se cerrará en 5 segundos. ⚠️ Deberás abrirla manualmente de nuevo desde el Dock."*
- **Cierre:** `await server.stop()` + `exit(0)`.
- **Puerto:** `8080` → `8443`.
- **Cliente HTTP:** `IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true)`.
- **PDF:** ya estaba completado en sesión anterior, NO se toca.
- **Mailto de confirmación:** tema aparte, NO se toca en esta sesión.

### 20.3. Estado de la implementación (al cierre de esta sesión)

| Paso | Archivo | Estado |
|---|---|---|
| 1 | `pubspec.yaml` — añadir `basic_utils` | ⚠️ Añadido como `^5.8.2`, **conflicto con `excel`**. Hay que bajar a `^5.7.0`. |
| 2 | `lib/core/network/cert_service.dart` | ⚠️ Escrito pero **quedó corrupto** (se pegó el texto del marcador `[... el contenido ...]` en vez del código). Hay que reescribirlo con el bloque corregido. |
| 3 | `lib/core/network/network_config.dart` | ❌ **No parcheado**. El Python abortó porque no encontró `String get baseHttp => 'http://$servidorIp:$puerto';`. Hay que ver el archivo real antes de parchear. |
| 4 | `lib/core/network/api_client.dart` | ⏳ Pendiente. Falta ver `sed -n '1,40p'`. |
| 5 | `lib/server/sgc_server.dart` | ⏳ Pendiente. Falta ver `sed -n '335,365p'`. |
| 6 | `admin_settings_screen.dart` (botón) | ⏳ Pendiente. |
| 7 | `flutter analyze` limpio | ❌ Pendiente. |

### 20.4. Errores encontrados y su causa
- **Conflicto de dependencias:** `basic_utils ^5.8.2` vs `excel ^4.0.6`.
  - Causa: ambas dependen de `archive` en versiones incompatibles.
  - Solución: bajar a `basic_utils: ^5.7.0`.
- **`cert_service.dart` corrupto:** el archivo se escribió con el texto literal
  `[... el contenido completo del cert_service.dart que te di antes ...]`.
  - Causa: en el bloque de comandos se puso ese marcador en vez del código.
  - Solución: reescribir el archivo con el código Dart real (bloque corregido en 20.5).
- **`network_config.dart` no parcheado:** el Python no encontró el patrón `baseHttp`.
  - Causa: el archivo ya tiene otra estructura (posiblemente `https` ya aplicado
    o `baseHttp` con otro nombre/formato).
  - Solución: ver `cat lib/core/network/network_config.dart` antes de parchear.
- **`flutter analyze` con 18 errores:** todos derivados del `cert_service.dart` corrupto
  y de `CertService` indefinido en `sgc_server.dart`.
  - Solución: reescribir `cert_service.dart` con el código real.
- **2 `info` de HTML en doc comments:** `Angle brackets will be interpreted as HTML`.
  - Solución: quitar los `<Directory>` del doc comment o envolverlos en backticks.

### 20.5. Bloque corregido de `cert_service.dart` (para reescribir)

```dart
import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CertService {
  CertService._();

  static const String _carpetaCerts = 'certs';
  static const String _nombreCert = 'sgc_cert.pem';
  static const String _nombreKey = 'sgc_key.pem';
  static const int _diasValidez = 3650;

  static Future<Directory> _carpeta() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/$_carpetaCerts');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<bool> existe() async {
    final dir = await _carpeta();
    return File('${dir.path}/$_nombreCert').existsSync() &&
        File('${dir.path}/$_nombreKey').existsSync();
  }

  static Future<String?> rutaCert() async {
    final dir = await _carpeta();
    final f = File('${dir.path}/$_nombreCert');
    return f.existsSync() ? f.path : null;
  }

  static Future<String?> rutaKey() async {
    final dir = await _carpeta();
    final f = File('${dir.path}/$_nombreKey');
    return f.existsSync() ? f.path : null;
  }

  static Future<void> generar() async {
    final dir = await _carpeta();
    final certFile = File('${dir.path}/$_nombreCert');
    final keyFile = File('${dir.path}/$_nombreKey');

    final keyPair = CryptoUtils.generateRSAKeyPair();
    final privateKey = keyPair.privateKey as RSAPrivateKey;
    final publicKey = keyPair.publicKey as RSAPublicKey;

    final attrs = <String, String>{
      'CN': 'SGC-Server',
      'O': 'Congreso',
      'C': 'GT',
    };

    final sans = <String>['localhost', '127.0.0.1'];
    final ip = await _ipLan();
    if (ip != null && !sans.contains(ip)) sans.add(ip);

    final csr = X509Utils.generateRsaCsrPem(attrs, privateKey, publicKey, san: sans);
    final certPem = X509Utils.generateSelfSignedCertificate(
      privateKey, csr, _diasValidez, sans: sans,
    );

    await certFile.writeAsString(certPem);
    await keyFile.writeAsString(CryptoUtils.encodeRSAPrivateKeyToPem(privateKey));

    debugPrint('[CertService] Certificado generado en ${dir.path}');
    debugPrint('[CertService] SANs: $sans');
  }

  static Future<void> borrar() async {
    final dir = await _carpeta();
    for (final f in [
      File('${dir.path}/$_nombreCert'),
      File('${dir.path}/$_nombreKey'),
    ]) {
      if (f.existsSync()) await f.delete();
    }
  }

  static Future<String?> _ipLan() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (_esIpDeLan(addr.address)) return addr.address;
        }
      }
    } catch (e) {
      debugPrint('[CertService] Error IP LAN: $e');
    }
    return null;
  }

  static bool _esIpDeLan(String ip) {
    final p = ip.split('.');
    if (p.length != 4) return false;
    final nums = p.map(int.tryParse).toList();
    if (nums.any((n) => n == null)) return false;
    final a = nums[0]!, b = nums[1]!;
    if (a == 10) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    if (a == 192 && b == 168) return true;
    return false;
  }
}


---

**Nota:** esta memoria refleja el estado **real** al cierre. No dice "completado" donde no lo está. La próxima sesión empieza con el checklist de 20.6.
---

## 20. TLS AUTOFIRMADO — IMPLEMENTADO (2026-11-03)

### 20.1. Estado: COMPLETADO

TLS autofirmado funcionando. `flutter analyze: No issues found!`.

### 20.2. Archivos modificados

- `pubspec.yaml`: `basic_utils: ^5.7.0` (NO 5.8.x, conflicto con `excel`).
- `lib/core/network/cert_service.dart` (NUEVO): genera cert RSA-2048 con SAN
  (localhost + 127.0.0.1 + IP LAN detectada). Métodos: `generar()`, `existe()`,
  `rutaCert()`, `rutaKey()`, `info()`, `borrar()`.
- `lib/core/network/network_config.dart`: `https` + `wss` + puerto 8443.
- `lib/server/sgc_server.dart`: `SecurityContext` + `io.serve` en 8443.
  Fallback a HTTP 8080 si no hay cert.
- `lib/core/network/api_client.dart`: `IOClient(HttpClient()..badCertificateCallback = ...)`.
- `lib/features/admin/admin_settings_screen.dart`:
  - Sección "Certificado TLS" en `_NetworkPanel` (solo `auth.isAdmin`).
  - Botón "Generar certificado TLS" con confirm si ya existe.
  - Diálogo "Reiniciar ahora" / "Descartar" con aviso de abrir manualmente.
  - Cuenta regresiva 5s con spinner.
  - Tarjeta de estado con 4 TextField desactivados (Estado, Ruta, Generado, Válido hasta).
  - Botón "Eliminar certificado" con confirm.
- `lib/main.dart`: función `cerrarAplicacion()` con `server.stop()` + `exit(0)`.
  Import `dart:io` añadido.

### 20.3. Ubicación del certificado

`getApplicationSupportDirectory()/certs/sgc_cert.pem` y `sgc_key.pem`.

En macOS:
`~/Library/Containers/com.sgc.sgc/Data/Library/Application Support/com.sgc.sgc/certs/`

En Windows:
`%APPDATA%\com.sgc.sgc\certs\`

### 20.4. Flujo de uso (técnico)

1. Admin va a Ajustes → Conexión de Red.
2. Pulsa "Generar certificado TLS" (confirm si ya existe).
3. Diálogo "Reiniciar ahora" / "Descartar" con aviso de abrir manualmente.
4. Si "Reiniciar ahora": cuenta regresiva 5s → `exit(0)`.
5. Admin abre la app manualmente.
6. Servidor arranca en `https://0.0.0.0:8443`.
7. Tarjeta de estado muestra ruta, fecha de generación y vencimiento.

### 20.5. Notas técnicas

- `restart_app` NO se usa (falla en macOS sandboxed).
- `exit(0)` es abrupto pero aceptable: `server.stop()` previo cierra el socket.
- Cert válido 3650 días (10 años). No se renueva automáticamente.
- Si se elimina el cert, el servidor vuelve a HTTP 8080 (con warning en stderr).
- Pendiente: probar en LAN real (router del Congreso o cable Ethernet).

### 20.6. Por qué TLS en una intranet

TLS no es "para que el cliente funcione mejor". Es para que los datos que viajan
entre el cliente y el servidor no los pueda leer ni modificar nadie en la red.
Sin TLS, cualquier persona con acceso a la red del Congreso (Wireshark, ARP
spoofing, switch comprometido, malware en una PC) puede ver DPI, correos,
salarios, contratos y credenciales de operadores. Con TLS, ve basura cifrada.

La intranet NO es una burbuja de confianza: es una red compartida por decenas
o cientos de personas y dispositivos. TLS es la única forma de proteger los
datos personales de los firmantes en tránsito.

Cumple la Regla X del proyecto: "TLS autofirmado mínimo en LAN".

### 20.7. Lo que TLS NO hace

- No acelera la app.
- No arregla bugs del cliente.
- No evita que un operador vea los datos en su pantalla.
- No protege la DB del servidor (eso es cifrado en reposo, otra cosa).
- No autentica al usuario (eso es el login).
- No reemplaza el control de acceso (eso es authProvider y Regla VII).

---

## 21. MANUAL DE USUARIO — CERTIFICADO TLS (2026-11-03)

### 21.1. ¿Qué es el certificado TLS?

Es un archivo que permite que la comunicación entre la computadora servidor
y las computadoras cliente viaje cifrada. Sin él, cualquier persona en la misma
red podría ver los datos que se transmiten (nombres, DPI, correos, contratos).

El certificado se genera una sola vez en la máquina que actúa como servidor.

### 21.2. ¿Quién debe generarlo?

Solo el usuario con rol **administrador**, y solo en la máquina que será el
servidor del sistema. Los operadores no ven esta opción.

### 21.3. Pasos para generar el certificado

1. Abrir la aplicación en la máquina servidor.
2. Iniciar sesión como administrador.
3. Ir a **Ajustes del sistema** (menú lateral).
4. Seleccionar **Conexión de Red**.
5. Bajar hasta la sección **Certificado TLS**.
6. Pulsar el botón **"Generar certificado TLS"**.
7. Si ya existía un certificado, aparecerá un aviso preguntando si se desea
   regenerar. Pulsar **"Sí, regenerar"** solo si es necesario.
8. Esperar unos segundos mientras se genera el certificado.
9. Aparecerá un mensaje: "Certificado generado correctamente".
10. Pulsar **"Reiniciar ahora"**.
11. La aplicación mostrará una cuenta regresiva de 5 segundos y se cerrará.
12. **IMPORTANTE:** abrir la aplicación manualmente de nuevo desde el Dock
    (macOS) o el menú de inicio (Windows). No se abre sola.
13. Al volver a entrar, ir a **Ajustes → Conexión de Red** y verificar que
    aparece la tarjeta con:
    - Estado: Activo
    - Ruta del certificado
    - Fecha de generación
    - Fecha de vencimiento

### 21.4. ¿Qué pasa si no genero el certificado?

El sistema funcionará igual, pero la comunicación entre cliente y servidor
irá sin cifrar (HTTP plano). Esto significa que cualquier persona en la red
del Congreso podría ver los datos que se transmiten. No se recomienda.

### 21.5. ¿Cuándo caduca el certificado?

El certificado tiene una validez de **10 años** desde su generación. La fecha
exacta de vencimiento aparece en la tarjeta de estado, en el campo
**"Válido hasta"**.

### 21.6. ¿Cómo renuevo el certificado?

Cuando el certificado esté cerca de vencer, o si por alguna razón se corrompe:

1. Ir a **Ajustes → Conexión de Red → Certificado TLS**.
2. Pulsar **"Generar certificado TLS"**.
3. Confirmar **"Sí, regenerar"**.
4. Reiniciar la aplicación como se indicó en los pasos anteriores.

El nuevo certificado reemplaza al anterior automáticamente.

### 21.7. ¿Cómo elimino el certificado?

Si necesitas volver a HTTP plano (por ejemplo, para hacer pruebas):

1. Ir a **Ajustes → Conexión de Red → Certificado TLS**.
2. En la tarjeta de estado, pulsar **"Eliminar certificado"**.
3. Confirmar la acción.
4. Reiniciar la aplicación.

Al reiniciar, el servidor arrancará en HTTP plano (puerto 8080) con un aviso
en la consola. Para volver a TLS, genera un certificado nuevo.

### 21.8. ¿Qué pasa con las computadoras cliente?

Las computadoras cliente no necesitan hacer nada. La aplicación acepta
automáticamente el certificado del servidor (está configurada para ello).
Solo necesitan tener configurada la IP del servidor en
**Ajustes → Conexión de Red**.

### 21.9. Preguntas frecuentes

**¿El certificado se genera en cada computadora?**
No. Solo en la máquina servidor. Las computadoras cliente lo aceptan
automáticamente.

**¿Puedo generar el certificado desde una computadora cliente?**
No. La opción solo aparece en la máquina servidor, y solo para el
usuario administrador.

**¿Qué pasa si genero el certificado y luego cambio la IP del servidor?**
El certificado incluye la IP que tenía el servidor al momento de generarse.
Si la IP cambia, regenera el certificado para incluir la nueva IP.

**¿El certificado sirve para acceder desde fuera de la red del Congreso?**
No. El sistema es de uso interno (intranet). El certificado protege la
comunicación dentro de la red local.

**¿Puedo usar un certificado comprado en lugar del autofirmado?**
Sí, si el Congreso proporciona un certificado corporativo. En ese caso,
contacta al administrador de red del Congreso.

---

FIN DE LA ACTUALIZACIÓN

---

## 22. SELECTOR SERVIDOR/CLIENTE Y REINICIO UNIFICADO (2026-11-03)

### 22.1. Contexto
El panel de red no tenía forma visual de cambiar entre modo servidor y cliente.
Solo existía la opción en el wizard de primer arranque, y si fallaba, había que
tocar SQLite a mano. Se añadió un selector `Switch` en el `_NetworkPanel`.

### 22.2. Cambios en admin_settings_screen.dart

- Añadido estado `_esServidor` y `_cambiandoModo` en `_NetworkPanelState`.
- `_loadIp()` ahora también carga `es_servidor` de la DB.
- Nuevo método `_cambiarModo(bool aServidor)`:
  1. Confirm inicial ("Vas a activar MODO SERVIDOR/CLIENTE...").
  2. UPDATE en `configuracion` (`es_servidor` = 'true'/'false').
  3. `AppDialogs.confirm` "Reiniciar ahora" / "Descartar" con aviso de abrir
     manualmente desde el Dock/Launchpad.
  4. Si "Reiniciar ahora": `_mostrarCuentaRegresiva()` → 5s → `cerrarAplicacion()`.
- En el `build()`, sección "Modo de esta máquina" con un `Switch`:
  - Icono dinámico (`dns_outlined` si servidor, `computer` si cliente).
  - Texto descriptivo dinámico.
  - `onChanged: null` cuando `_cambiandoModo == true` (deshabilitado).
- Se descartó `RadioGroup` porque `onChanged` es no-nullable y causaba error
  de tipos. El `Switch` es más simple para dos opciones.

### 22.3. Flujo unificado
Tanto "cambiar modo" como "generar certificado" siguen el mismo patrón:
acción → confirm → "Reiniciar ahora"/"Descartar" → cuenta regresiva 5s → `exit(0)`.

### 22.4. Estado
`flutter analyze: No issues found!`.

---

FIN DE LA ACTUALIZACIÓN
---

## 23. USUARIOS, GRUPOS Y PERMISOS GRANULARES — PENDIENTE (2026-11-03)

### 23.1. Contexto
El sistema tiene roles fijos (`administrador`, `operador`) y una tabla `permisos`
en el esquema, pero NO existe UI para gestionar usuarios, grupos ni permisos.
`usuarios_screen.dart` es un stub de 36 líneas.

Se va a replicar el patrón que funcionó en Farmacia App:
roles fijos → grupos de permisos → permisos granulares por módulo/acción,
con helper `auth.puede(modulo, accion)`.

### 23.2. Patrón de Farmacia App (referencia)

Estructura de tablas:
- `roles`: administrador, operador (fijos, no editables).
- `grupos`: agrupaciones lógicas de permisos (ej. "Citas - Operación").
  Campos: id, nombre, descripcion, modulo, activo.
- `rol_grupos`: tabla intermedia (rol_id, grupo_id).
- `permisos`: permisos granulares asignados a grupos.
  Campos: id, grupo_id, modulo, accion.

Cadena de resolución:
usuario → rol → rol_grupos → grupos → permisos → cache en AuthState.

Ventaja: el admin puede crear grupos nuevos y asignarlos a roles sin tocar código.
Los permisos son datos, no hardcode.

### 23.3. Checklist de implementación

BLOQUE 0 — Estado actual (verificado)
- [x] Tabla roles con administrador y operador seedeados.
- [x] Tabla usuarios con rol_id, activo, soft delete.
- [x] Tabla permisos (rol_id, modulo, accion) en el esquema.
- [x] AuthState con isAdmin e isOperador (hardcode).
- [ ] usuarios_screen.dart (36 líneas, solo class UsuariosScreen) — stub.
- [ ] Tabla grupos — no existe.
- [ ] Tabla rol_grupos — no existe.
- [ ] Helper auth.puede(modulo, accion) — no existe.
- [ ] UI de permisos granulares — no existe.
- [ ] Sidebar con estado persistido — no existe.

BLOQUE 1 — Base de datos (Drift)
- [ ] 1.1 Añadir tabla grupos (id, nombre, descripcion, modulo, activo).
- [ ] 1.2 Añadir tabla rol_grupos (id, rol_id, grupo_id).
- [ ] 1.3 Migración de Drift (schemaVersion +1, onUpgrade).
- [ ] 1.4 Seed de 6 grupos por defecto.
- [ ] 1.5 Seed de rol_grupos (admin → todos, operador → Citas-Operación + Reportes).
- [ ] 1.6 Regenerar Drift: dart run build_runner build --delete-conflicting-outputs.

BLOQUE 2 — Helper de permisos
- [ ] 2.1 Cargar permisos al login (rol → grupos → permisos) en _permisosCache.
- [ ] 2.2 Método auth.puede(modulo, accion) en AuthState.
- [ ] 2.3 Método auth.grupos (lista de grupos del usuario).
- [ ] 2.4 Recargar permisos al cambiar rol o grupos de un usuario.

BLOQUE 3 — Pantalla de Usuarios
- [ ] 3.1 Listado con DataTable (Regla V: sort SQL, paginación 20).
- [ ] 3.2 Botón "Nuevo usuario" → modal (username, nombre, password, rol, activo).
- [ ] 3.3 Acción editar.
- [ ] 3.4 Acción reset password.
- [ ] 3.5 Acción activar/desactivar.
- [ ] 3.6 Acción eliminar (soft delete) con confirm.
- [ ] 3.7 Solo visible si auth.isAdmin (triple seguridad: sidebar + ruta + header).

BLOQUE 4 — Pantalla de Grupos
- [ ] 4.1 Listado de grupos con DataTable.
- [ ] 4.2 Botón "Nuevo grupo" → modal (nombre, descripción, módulo).
- [ ] 4.3 Checkboxes de permisos por grupo (ver, crear, editar, eliminar, enviar_correo, admin).
- [ ] 4.4 Acción editar grupo.
- [ ] 4.5 Acción eliminar grupo (con confirm).
- [ ] 4.6 Asignar grupos a roles (UI de checkboxes rol × grupo).
- [ ] 4.7 Solo visible si auth.isAdmin.

BLOQUE 5 — Pantalla de Permisos (opcional, redundante con Bloque 4)
- [ ] 5.1 Listado de permisos por grupo y módulo.
- [ ] 5.2 Edición inline de permisos (checkboxes).
- [ ] 5.3 Solo visible si auth.isAdmin.
NOTA: si el Bloque 4 ya permite editar permisos por grupo, este bloque puede omitirse.

BLOQUE 6 — Sidebar con memorización
- [ ] 6.1 Persistir colapsado/expandido en shared_preferences.
- [ ] 6.2 Cargar estado al inicio.
- [ ] 6.3 Guardar estado al cambiar.

BLOQUE 7 — Integración en la UI existente
- [ ] 7.1 Añadir "Usuarios" al sidebar (solo admin).
- [ ] 7.2 Añadir "Grupos y Permisos" al sidebar (solo admin).
- [ ] 7.3 Reemplazar auth.isAdmin por auth.puede(modulo, accion) donde aplique.
- [ ] 7.4 Reemplazar auth.isOperador por auth.puede(...) en acciones de citas.
- [ ] 7.5 Verificar que operador NO ve /admin-settings, /auditoria, /usuarios, /grupos.

BLOQUE 8 — Verificación final
- [ ] 8.1 flutter analyze limpio.
- [ ] 8.2 Regenerar Drift.
- [ ] 8.3 Probar login como admin: ve todo.
- [ ] 8.4 Probar login como operador: NO ve usuarios/grupos/auditoría.
- [ ] 8.5 Probar crear usuario.
- [ ] 8.6 Probar crear grupo con permisos.
- [ ] 8.7 Probar asignar grupo a rol.
- [ ] 8.8 Commit siguiendo Regla XII.

### 23.4. Grupos por defecto propuestos

| Grupo | Permisos |
|---|---|
| Citas - Operación | citas:ver, citas:crear, citas:editar, citas:enviar_correo |
| Citas - Eliminar | citas:eliminar |
| Usuarios | usuarios:ver, usuarios:crear, usuarios:editar, usuarios:eliminar |
| Auditoría | auditoria:ver |
| Configuración | smtp:admin, plantillas:editar, configuracion:admin |
| Reportes | reportes:ver |

Asignación inicial:
- administrador → todos los grupos.
- operador → Citas - Operación + Reportes.

### 23.5. Módulos y acciones del SGC

Modulos: citas, usuarios, auditoria, smtp, plantillas, reportes, configuracion.
Acciones: ver, crear, editar, eliminar, enviar_correo, admin.

### 23.6. Prioridad de implementación

Alta: Bloques 1, 2 (sin DB y helper, nada funciona).
Alta: Bloque 3 (usuarios es lo más urgente).
Alta: Bloque 4 (grupos es el corazón del patrón).
Media: Bloque 6 (sidebar cosmético).
Media: Bloque 7 (integración en UI).
Baja: Bloque 5 (redundante con Bloque 4).
Alta: Bloque 8 (verificación y commit).

### 23.7. Decisiones pendientes de confirmar

1. ¿Se replican los 6 grupos por defecto tal cual?
2. ¿Se omite el Bloque 5 (pantalla de permisos) por ser redundante?
3. ¿Los módulos son los 7 listados, o se añaden más (documentos, dashboard, kanban)?
4. ¿Roles fijos (admin/operador) o el admin puede crear roles nuevos? (recomendado: fijos)

### 23.8. Notas para próximas sesiones

- El patrón de Farmacia App está probado y funciona. No inventar desde cero.
- La migración de Drift requiere schemaVersion +1 y onUpgrade.
- Regenerar con build_runner después de tocar tablas.
- El helper auth.puede() debe usarse en toda la UI (botones, rutas, sidebar).
- Regla VII: triple seguridad (sidebar + ruta + header) para rutas de admin.

---

FIN DE LA ACTUALIZACIÓN
