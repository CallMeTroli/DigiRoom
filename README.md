# DigiMoodle · Google Classroom iOS Client para Campus Digitech FP · Hecho en Antigravity con Gemini 3.8 Flash

Aplicación nativa para **iOS (iPhone e iPad)** con diseño idéntico a la interfaz móvil de **Google Classroom**, conectada directamente con la base de datos y servicios web del campus virtual de Digitech FP ([https://campus.digitechfp.com](https://campus.digitechfp.com)), dotada de inicio de sesión seguro y un **sistema de notificaciones altamente personalizable** (con recordatorios automáticos **2 días antes** de la entrega de tareas o ajustado a la medida de cada alumno).

---

## 🎯 Objetivos Implementados

1. **Compatibilidad total con iOS**:
   - Proyecto nativo en **SwiftUI** con arquitectura moderna `MVVM`, `async/await` y soporte completo para iOS 16.0+.
   - Archivo de proyecto Xcode listo para abrir y compilar: `DigiMoodle.xcodeproj`.
   - Integración nativa con `UserNotifications` (`UNUserNotificationCenter`) para alertas locales y badges en segundo plano.

2. **Diseño Visual Idéntico a Google Classroom Mobile**:
   - Barra superior con icono de menú lateral hamburguesa, logotipo de Classroom y selector de avatar.
   - Tarjetas de cursos con las tonalidades icónicas de Google Classroom (Azul `#1A73E8`, Verde `#137333`, Naranja `#E37400`, Morado `#9334E6`, Turquesa `#007B83`), profesor, progreso y tareas próximas.
   - Navegación inferior con 3 pestañas:
     - **Novedades (Stream)**: Tablón de anuncios, avisos del profesorado y comentarios de clase.
     - **Trabajo de clase (Classwork)**: Agrupación por temas/unidades didácticas, chips de filtro, estado de las tareas (*Asignada*, *Entregada*, *Calificada*).
     - **Personas (People)**: Lista del profesorado y compañeros de clase con contacto.
   - Ficha detallada de tarea con puntuación ("100 puntos"), fecha de entrega, instrucciones, archivos adjuntos y panel deslizable **"Tu trabajo"** para subir entregas y añadir comentarios privados para el profesor.
   - Menú lateral deslizable (Side Drawer) con accesos a Clases, Tareas pendientes, Notificaciones y asignaturas matriculadas.

3. **Conexión con la Base de Datos de `campus.digitechfp.com`**:
   - Integración con los endpoints oficiales de **Moodle Mobile Web Services REST API v2**:
     - `POST /login/token.php?service=moodle_mobile_app`: Generación de token seguro de sesión móvil.
     - `core_webservice_get_site_info`: Obtención de perfil, rol y metadatos de usuario.
     - `core_enrol_get_users_courses`: Asignaturas oficiales matriculadas por el alumno.
     - `mod_assign_get_assignments`: Tareas, enunciados, fechas de entrega y archivos adjuntos.
     - `core_course_get_contents`: Secciones y unidades temáticas de cada módulo.
     - `core_calendar_get_action_events_by_timesort`: Fechas límite del calendario oficial.
   - **Modo Demo integrado**: Permite probar la aplicación de inmediato con asignaturas reales de DAM 2º (*Programación Multimedia*, *Desarrollo de Interfaces*, *Acceso a Datos*, etc.).

4. **Inicio de Sesión Oficial**:
   - Pantalla de login limpia con estética de cuenta de Google adaptada a Digitech FP.
   - Formulario de acceso con usuario y contraseña del campus, alternador de visualización de contraseña, persistencia segura de credenciales en `StorageService` y botón de acceso directo a *Modo Demo / Explorar*.

5. **Sistema de Notificaciones Personalizable a Medida**:
   - **Recordatorio a 2 días antes (Recomendado)**: Configurado por defecto para avisar al alumno con 48 horas de margen antes del vencimiento de cualquier tarea.
   - **Selector de antelación**:
     - *2 días antes* (Recomendado)
     - *1 día antes*
     - *3 días antes*
     - *A mi medida (Personalizado)*: Steppers configurables para seleccionar días exactos (1-14 días) y horas adicionales.
   - **Hora preferida del aviso**: Permite seleccionar a qué hora del día recibir la alerta (ej. 09:00 AM, 18:00, etc.).
   - **Interruptores por asignatura**: Permite silenciar o activar notificaciones curso por curso.
   - **Botón "Probar notificación ahora"**: Envía un aviso de prueba en 3 segundos para validar el funcionamiento en el iPhone.

---

## 📁 Estructura del Proyecto

```
DigiMoodle/
├── DigiMoodle.xcodeproj               # Proyecto Xcode nativo generado
├── project.yml                        # Especificación XcodeGen
├── Sources/
│   ├── App/
│   │   ├── DigiMoodleApp.swift        # Punto de entrada @main y AppDelegate
│   │   └── ContentView.swift          # Contenedor raíz y navegación reactiva
│   ├── Models/
│   │   ├── User.swift                 # Modelo de alumno y sesión
│   │   ├── Course.swift               # Modelo de asignatura y paleta de colores
│   │   ├── Assignment.swift           # Modelo de tarea, entregas y estados
│   │   ├── Announcement.swift         # Modelo de novedades y comentarios
│   │   ├── Topic.swift                # Unidades y temas del curso
│   │   ├── NotificationSetting.swift  # Modelo y cálculo matemático de avisos
│   │   └── MoodleDTOs.swift           # DTOs decodables de la API de Moodle
│   ├── Services/
│   │   ├── MoodleAPIService.swift     # Cliente REST a https://campus.digitechfp.com
│   │   ├── NotificationManager.swift  # UNUserNotificationCenter de iOS
│   │   ├── StorageService.swift       # Almacenamiento seguro en UserDefaults
│   │   └── MockDataService.swift      # Base de datos simulada para Modo Demo
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift        # Estado de autenticación
│   │   ├── ClassroomViewModel.swift   # Estado de cursos, tablón y tareas
│   │   └── NotificationViewModel.swift# Estado de configuración de avisos
│   ├── Views/
│   │   ├── Auth/LoginView.swift
│   │   ├── Common/ (TopBar, SideDrawer, Avatar, GoogleClassroomTheme)
│   │   ├── Home/ (CoursesListView, CourseCardView)
│   │   ├── Course/ (CourseDetailView, Stream, Classwork, People, AssignmentRow)
│   │   ├── Assignment/ (AssignmentDetailView, Sheet)
│   │   ├── Todo/TodoListView.swift
│   │   ├── Notifications/NotificationSettingsView.swift
│   │   └── Profile/UserProfileSheet.swift
│   └── Resources/
│       ├── Assets.xcassets            # Iconos y Color de Acento
│       └── Info.plist                 # Configuración de permisos iOS
├── Tests/
│   └── DigiMoodleTests.swift          # Suite de pruebas unitarias
├── web/                               # Simulador interactivo Web/PWA
│   ├── index.html                     # Visualizador estilo iPhone Google Classroom
│   ├── css/classroom.css              # Estilos Material 3 / Google Classroom
│   └── js/ (app.js, moodle-api.js, notifications.js, demo-data.js)
└── README.md
```

---

## 🚀 Cómo Ejecutar la Aplicación

### Opción 1: Abrir en Xcode (Nativo iOS)

1. En tu Mac, abre el proyecto haciendo doble clic en el archivo o ejecuta en la terminal:
   ```bash
   cd /Users/troli/Desktop/DigiMoodle
   open DigiMoodle.xcodeproj
   ```
2. Selecciona tu dispositivo iPhone físico o cualquier simulador iOS (iPhone 15, iPhone 16, etc.) en la barra superior de Xcode.
3. Haz clic en el botón **Run** (Cmd + R).

Para compilar desde la terminal sin abrir Xcode:
```bash
xcodebuild -project DigiMoodle.xcodeproj -scheme DigiMoodle -sdk iphoneos CODE_SIGNING_ALLOWED=NO clean build
```

---

### Opción 2: Probar el Simulador Web / PWA de inmediato

Hemos creado también un visor interactivo que simula la interfaz móvil en un marco de iPhone:

```bash
cd /Users/troli/Desktop/DigiMoodle/web
python3 -m http.server 8080
```
Abre en tu navegador favorito:
👉 **[http://localhost:8080](http://localhost:8080)**

---

## 🔔 Cómo Funciona el Sistema de Notificaciones

El usuario puede ajustar sus recordatorios en el menú lateral (**Ajustes de notificaciones**):

1. **Cálculo de la fecha de disparo (`triggerDate`)**:
   $$\text{Fecha Notificación} = \text{Fecha Entrega} - (\text{Días de antelación} \times 24\,\text{h}) + \text{Hora preferida}$$
   Si una tarea finaliza el viernes a las 23:59 y el usuario tiene configurada la opción recomendada de **2 días antes**, la notificación nativa de iOS se programa automáticamente para el miércoles a las 09:00 AM (o a la hora elegida).
2. **Alertas personalizadas**:
   El usuario puede pulsar sobre *A mi medida* y fijar cualquier cantidad de días y horas.
3. **Filtro por asignatura**:
   Si un alumno solo quiere recibir avisos de *Programación Multimedia* pero silenciar *Empresa*, puede alternar el interruptor correspondiente en la lista.
4. **Verificación inmediata**:
   Pulsando en **"Probar notificación ahora"**, la app agenda una notificación de prueba en 3 segundos para confirmar la entrega del banner y sonido en iOS.

---

## 🧪 Pruebas Unitarias Ejecutadas

Las siguientes pruebas automatizadas validan la integridad del sistema:

| Prueba | Componente | Resultado |
|---|---|---|
| Regla por defecto | `NotificationSetting.daysBefore == 2` | ✅ PASADO |
| Cálculo de fecha | 2 días antes de la fecha límite | ✅ PASADO |
| Ajuste a medida | Días y horas personalizadas | ✅ PASADO |
| Silenciado por curso | `perCourseToggles` | ✅ PASADO |
| Estados de entrega | Asignada, Entregada, Sin entregar, Calificada | ✅ PASADO |
| Compilación iOS | `xcodebuild -sdk iphoneos` | ✅ PASADO (Código 0) |

---

© 2026 DIGITECH FP · Campus Oficial Digital & Tech
