import Foundation

public final class MockDataService {
    public static let shared = MockDataService()

    private init() {}

    public func getDemoUser() -> User {
        return User(
            id: 9942,
            username: "alumno.dam@digitechfp.com",
            fullname: "Álex Navarro Martín",
            firstname: "Álex",
            lastname: "Navarro Martín",
            userpictureurl: nil,
            siteurl: "https://campus.digitechfp.com",
            token: "demo_digitech_token_2026",
            isDemo: true
        )
    }

    public func getDemoCourses() -> [Course] {
        let calendar = Calendar.current
        let now = Date()

        let dueIn2Days = calendar.date(byAdding: .day, value: 2, to: now)!
        let dueTomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let dueIn4Days = calendar.date(byAdding: .day, value: 4, to: now)!
        let dueNextWeek = calendar.date(byAdding: .day, value: 7, to: now)!
        let submittedPast = calendar.date(byAdding: .day, value: -3, to: now)!

        let assignPMM = Assignment(
            id: 101,
            cmid: 501,
            courseId: 1,
            courseName: "Programación Multimedia y Dispositivos Móviles",
            name: "Práctica 3: Interfaz iOS compatible con Google Classroom",
            intro: """
            En esta práctica debéis desarrollar los componentes de la aplicación móvil para iOS.
            Requisitos clave:
            1. Interfaz idéntica a Google Classroom mobile.
            2. Conexión con los endpoints de Moodle en campus.digitechfp.com.
            3. Sistema de notificaciones programables con recordatorio personalizable a 2 días antes de la entrega.
            4. Entrega de código fuente y documentación técnica.
            """,
            dueDate: dueIn2Days,
            cutoffDate: dueIn2Days,
            maxPoints: 100,
            isSubmitted: false,
            topicName: "Tema 3: Desarrollo iOS & SwiftUI",
            attachments: [
                AssignmentAttachment(title: "Enunciado_Practica_3.pdf", fileUrl: "https://campus.digitechfp.com/mod/resource/view.php?id=101", fileSize: "1.4 MB", fileType: "pdf"),
                AssignmentAttachment(title: "Guia_Estilo_Classroom.pdf", fileUrl: "https://campus.digitechfp.com/mod/resource/view.php?id=102", fileSize: "820 KB", fileType: "pdf")
            ],
            privateComments: [
                PrivateComment(authorName: "Prof. Alejandro Ruiz", text: "Recordad revisar los permisos de UNUserNotificationCenter para las alertas locales.", date: calendar.date(byAdding: .hour, value: -5, to: now)!, isCurrentUser: false)
            ]
        )

        let assignDI = Assignment(
            id: 102,
            cmid: 502,
            courseId: 2,
            courseName: "Desarrollo de Interfaces",
            name: "Entrega Sprint 2: Usabilidad y Diseño Mobile",
            intro: "Diseño y prototipado responsive aplicando Material Design y directrices Human Interface Guidelines de Apple.",
            dueDate: dueTomorrow,
            cutoffDate: dueTomorrow,
            maxPoints: 10,
            isSubmitted: false,
            topicName: "Sprint 2: Prototipado e Interacción"
        )

        let assignAD = Assignment(
            id: 103,
            cmid: 503,
            courseId: 3,
            courseName: "Acceso a Datos",
            name: "Ejercicio 4: Consultas REST y Mapeo ORM",
            intro: "Integración de capa DAO con servicios REST de Moodle y base de datos relacional.",
            dueDate: dueIn4Days,
            cutoffDate: dueIn4Days,
            maxPoints: 100,
            isSubmitted: false,
            topicName: "Unidad 4: Servicios Web y APIs"
        )

        let assignSGE = Assignment(
            id: 104,
            cmid: 504,
            courseId: 4,
            courseName: "Sistemas de Gestión Empresarial",
            name: "Caso Práctico: Despliegue de Módulo ERP",
            intro: "Configuración de entorno de pruebas y personalización de vistas de cliente.",
            dueDate: dueNextWeek,
            cutoffDate: dueNextWeek,
            maxPoints: 100,
            isSubmitted: false,
            topicName: "Bloque II: Personalización Odoo"
        )

        let assignEIE = Assignment(
            id: 105,
            cmid: 505,
            courseId: 5,
            courseName: "Empresa e Iniciativa Emprendedora",
            name: "Plan de Empresa: Estudio de Viabilidad",
            intro: "Análisis DAFO, plan financiero y Canvas del modelo de negocio de startup tecnológica.",
            dueDate: submittedPast,
            cutoffDate: submittedPast,
            maxPoints: 10,
            isSubmitted: true,
            submissionDate: submittedPast,
            grade: "9.5 / 10",
            topicName: "Tema 2: Plan Financiero"
        )

        return [
            Course(
                id: 1,
                fullname: "Programación Multimedia y Dispositivos Móviles (DAM 2º)",
                shortname: "PMM_DAM2",
                summary: "Desarrollo de aplicaciones móviles nativas y multiplataforma para iOS y Android.",
                themeColorHex: "#1A73E8", // Classroom Blue
                teacherName: "Prof. Alejandro Ruiz",
                teacherEmail: "aruiz@digitechfp.com",
                assignmentsDueSoon: [assignPMM],
                progress: 0.72
            ),
            Course(
                id: 2,
                fullname: "Desarrollo de Interfaces (DAM 2º)",
                shortname: "DI_DAM2",
                summary: "Diseño de interfaces de usuario, usabilidad, experiencia de usuario y accesibilidad.",
                themeColorHex: "#137333", // Classroom Green
                teacherName: "Profª. Laura Gómez",
                teacherEmail: "lgomez@digitechfp.com",
                assignmentsDueSoon: [assignDI],
                progress: 0.65
            ),
            Course(
                id: 3,
                fullname: "Acceso a Datos (DAM 2º)",
                shortname: "AD_DAM2",
                summary: "Gestión de ficheros, conectores de bases de datos, ORMs y servicios RESTful.",
                themeColorHex: "#E37400", // Classroom Orange
                teacherName: "Prof. Javier Morales",
                teacherEmail: "jmorales@digitechfp.com",
                assignmentsDueSoon: [assignAD],
                progress: 0.80
            ),
            Course(
                id: 4,
                fullname: "Sistemas de Gestión Empresarial (DAM 2º)",
                shortname: "SGE_DAM2",
                summary: "Implantación, configuración y desarrollo de módulos en ERPs y CRMs.",
                themeColorHex: "#9334E6", // Classroom Purple
                teacherName: "Profª. Beatriz Santos",
                teacherEmail: "bsantos@digitechfp.com",
                assignmentsDueSoon: [assignSGE],
                progress: 0.55
            ),
            Course(
                id: 5,
                fullname: "Empresa e Iniciativa Emprendedora",
                shortname: "EIE_DAM2",
                summary: "Creación de empresas en el sector TIC, gestión de proyectos y legislación laboral.",
                themeColorHex: "#007B83", // Classroom Teal
                teacherName: "Prof. Fernando Ortega",
                teacherEmail: "fortega@digitechfp.com",
                assignmentsDueSoon: [assignEIE],
                progress: 0.90
            )
        ]
    }

    public func getDemoAssignments() -> [Assignment] {
        let courses = getDemoCourses()
        return courses.flatMap { $0.assignmentsDueSoon }
    }

    public func getDemoAnnouncements(for courseId: Int) -> [Announcement] {
        let calendar = Calendar.current
        let now = Date()

        switch courseId {
        case 1:
            return [
                Announcement(
                    id: 201,
                    courseId: 1,
                    authorName: "Prof. Alejandro Ruiz",
                    date: calendar.date(byAdding: .day, value: -1, to: now)!,
                    content: "¡Hola a todos! Recordad que la Práctica 3 vence en 2 días. Os he dejado en el tablón los enlaces de soporte para configurar el centro de notificaciones de iOS (UserNotifications). Podéis comentar aquí cualquier duda.",
                    comments: [
                        AnnouncementComment(authorName: "Elena Cano", date: calendar.date(byAdding: .hour, value: -18, to: now)!, text: "Profesor, ¿podemos usar SwiftUI moderno con async/await?"),
                        AnnouncementComment(authorName: "Prof. Alejandro Ruiz", date: calendar.date(byAdding: .hour, value: -15, to: now)!, text: "Sí, es altamente recomendado.")
                    ]
                ),
                Announcement(
                    id: 202,
                    courseId: 1,
                    authorName: "Prof. Alejandro Ruiz",
                    date: calendar.date(byAdding: .day, value: -5, to: now)!,
                    content: "Publicadas las notas del examen parcial de Swift y arquitectura MVVM en el campus.",
                    comments: []
                )
            ]
        case 2:
            return [
                Announcement(
                    id: 203,
                    courseId: 2,
                    authorName: "Profª. Laura Gómez",
                    date: calendar.date(byAdding: .day, value: -2, to: now)!,
                    content: "Recordatorio: mañana revisaremos los wireframes y el flujo de navegación de Google Classroom para los prototipos de la entrega.",
                    comments: []
                )
            ]
        default:
            return [
                Announcement(
                    id: 204,
                    courseId: courseId,
                    authorName: "Coordinación Digitech FP",
                    date: calendar.date(byAdding: .day, value: -3, to: now)!,
                    content: "Bienvenidos al módulo. Las tutorías semanales se realizarán por videoconferencia a través de Teams y el campus virtual.",
                    comments: []
                )
            ]
        }
    }

    public func getDemoTopics(for courseId: Int) -> [Topic] {
        let assignments = getDemoAssignments().filter { $0.courseId == courseId }

        switch courseId {
        case 1:
            return [
                Topic(id: 1, name: "Tema 1: Arquitectura iOS & Swift", assignments: []),
                Topic(id: 2, name: "Tema 2: Componentes y Vistas SwiftUI", assignments: []),
                Topic(id: 3, name: "Tema 3: Desarrollo iOS & SwiftUI", assignments: assignments)
            ]
        case 2:
            return [
                Topic(id: 1, name: "Sprint 1: Principios de Diseño y Accesibilidad", assignments: []),
                Topic(id: 2, name: "Sprint 2: Prototipado e Interacción", assignments: assignments)
            ]
        default:
            return [
                Topic(id: 1, name: "Unidad 1: Introducción", assignments: []),
                Topic(id: 2, name: "Unidad 2: Desarrollo del Módulo", assignments: assignments)
            ]
        }
    }

    public func getDemoConversations(currentUserId: Int = 9942) -> [MoodleConversation] {
        let calendar = Calendar.current
        let now = Date()

        return [
            MoodleConversation(
                id: 801,
                name: "Prof. Alejandro Ruiz",
                subtitle: "Programación Multimedia y Dispositivos Móviles",
                partnerId: 401,
                isGroup: false,
                isOnline: true,
                unreadCount: 2,
                messages: [
                    MoodleChatMessage(
                        id: 9001,
                        senderId: 401,
                        senderName: "Prof. Alejandro Ruiz",
                        text: "¡Hola Álex! ¿Cómo llevas la integración con la API REST de Moodle para la Práctica 3?",
                        date: calendar.date(byAdding: .hour, value: -3, to: now)!,
                        isFromCurrentUser: false
                    ),
                    MoodleChatMessage(
                        id: 9002,
                        senderId: currentUserId,
                        senderName: "Tú",
                        text: "¡Hola profesor! Ya tengo funcionando el login con token y las notificaciones a medida.",
                        date: calendar.date(byAdding: .hour, value: -2, to: now)!,
                        isFromCurrentUser: true
                    ),
                    MoodleChatMessage(
                        id: 9003,
                        senderId: 401,
                        senderName: "Prof. Alejandro Ruiz",
                        text: "¡Excelente! Recuerda incluir también la vista de mensajería de Moodle (core_message).",
                        date: calendar.date(byAdding: .minute, value: -25, to: now)!,
                        isFromCurrentUser: false
                    ),
                    MoodleChatMessage(
                        id: 9004,
                        senderId: 401,
                        senderName: "Prof. Alejandro Ruiz",
                        text: "Cualquier duda con el certificado de Xcode me comentas por aquí.",
                        date: calendar.date(byAdding: .minute, value: -20, to: now)!,
                        isFromCurrentUser: false
                    )
                ],
                themeColorHex: "#1A73E8"
            ),
            MoodleConversation(
                id: 802,
                name: "Grupo DAM 2º - Proyecto Integrado",
                subtitle: "Grupo del curso (24 miembros)",
                partnerId: nil,
                isGroup: true,
                isOnline: true,
                unreadCount: 1,
                messages: [
                    MoodleChatMessage(
                        id: 9010,
                        senderId: 501,
                        senderName: "Elena Cano",
                        text: "Chicos, ¿a qué hora cerraba el Sprint 2 de Desarrollo de Interfaces?",
                        date: calendar.date(byAdding: .hour, value: -5, to: now)!,
                        isFromCurrentUser: false
                    ),
                    MoodleChatMessage(
                        id: 9011,
                        senderId: currentUserId,
                        senderName: "Tú",
                        text: "Cierra mañana, me acaba de saltar la notificación en DigiRoom.",
                        date: calendar.date(byAdding: .hour, value: -4, to: now)!,
                        isFromCurrentUser: true
                    ),
                    MoodleChatMessage(
                        id: 9012,
                        senderId: 502,
                        senderName: "Marcos Torres",
                        text: "¡Genial! Acabo de subir la parte de los componentes Material Design al repositorio.",
                        date: calendar.date(byAdding: .minute, value: -45, to: now)!,
                        isFromCurrentUser: false
                    )
                ],
                themeColorHex: "#137333"
            ),
            MoodleConversation(
                id: 803,
                name: "Profª. Laura Gómez",
                subtitle: "Desarrollo de Interfaces (DAM 2º)",
                partnerId: 402,
                isGroup: false,
                isOnline: false,
                unreadCount: 0,
                messages: [
                    MoodleChatMessage(
                        id: 9020,
                        senderId: 402,
                        senderName: "Profª. Laura Gómez",
                        text: "Hola Álex, he revisado tu boceto del menú lateral estilo Classroom y cumple genial con las guías de usabilidad.",
                        date: calendar.date(byAdding: .day, value: -1, to: now)!,
                        isFromCurrentUser: false
                    ),
                    MoodleChatMessage(
                        id: 9021,
                        senderId: currentUserId,
                        senderName: "Tú",
                        text: "¡Muchas gracias Laura! Mañana subo la versión final.",
                        date: calendar.date(byAdding: .day, value: -1, to: now)!,
                        isFromCurrentUser: true
                    )
                ],
                themeColorHex: "#E37400"
            ),
            MoodleConversation(
                id: 804,
                name: "Prof. Javier Morales",
                subtitle: "Acceso a Datos (DAM 2º)",
                partnerId: 403,
                isGroup: false,
                isOnline: true,
                unreadCount: 0,
                messages: [
                    MoodleChatMessage(
                        id: 9030,
                        senderId: 403,
                        senderName: "Prof. Javier Morales",
                        text: "El servidor de pruebas para las consultas REST de Moodle ya está activo en el campus.",
                        date: calendar.date(byAdding: .day, value: -2, to: now)!,
                        isFromCurrentUser: false
                    )
                ],
                themeColorHex: "#9334E6"
            )
        ]
    }
}

