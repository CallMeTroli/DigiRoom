// Realistic Digitech FP Course & Assignment Database for Google Classroom UI

const now = new Date();
const addDays = (d) => new Date(now.getTime() + d * 86400000);

export const DEMO_USER = {
  id: 9942,
  username: "alumno.dam@digitechfp.com",
  fullname: "Álex Navarro Martín",
  firstname: "Álex",
  lastname: "Navarro Martín",
  siteurl: "https://campus.digitechfp.com",
  token: "demo_digitech_token_2026",
  isDemo: true
};

export const DEMO_COURSES = [
  {
    id: 1,
    fullname: "Programación Multimedia y Dispositivos Móviles (DAM 2º)",
    shortname: "PMM_DAM2",
    themeColor: "#1A73E8", // Classroom Blue
    teacherName: "Prof. Alejandro Ruiz",
    teacherEmail: "aruiz@digitechfp.com",
    progress: 72,
    assignmentsDueSoon: [
      {
        id: 101,
        courseId: 1,
        courseName: "Programación Multimedia y Dispositivos Móviles",
        name: "Práctica 3: Interfaz iOS compatible con Google Classroom",
        intro: "En esta práctica debéis desarrollar los componentes de la aplicación móvil para iOS.<br><br><b>Requisitos clave:</b><br>1. Interfaz idéntica a Google Classroom mobile.<br>2. Conexión con los endpoints de Moodle en campus.digitechfp.com.<br>3. Sistema de notificaciones programables con recordatorio personalizable a 2 días antes de la entrega.<br>4. Entrega de código fuente y documentación técnica.",
        dueDate: addDays(2).toISOString(),
        maxPoints: 100,
        isSubmitted: false,
        topicName: "Tema 3: Desarrollo iOS & SwiftUI",
        attachments: [
          { id: "att1", title: "Enunciado_Practica_3.pdf", fileSize: "1.4 MB", fileType: "pdf" },
          { id: "att2", title: "Guia_Estilo_Google_Classroom.pdf", fileSize: "820 KB", fileType: "pdf" }
        ],
        privateComments: [
          { authorName: "Prof. Alejandro Ruiz", text: "Recordad revisar los permisos de UNUserNotificationCenter para las alertas locales en iOS.", date: "Hoy, 10:30", isCurrentUser: false }
        ]
      }
    ]
  },
  {
    id: 2,
    fullname: "Desarrollo de Interfaces (DAM 2º)",
    shortname: "DI_DAM2",
    themeColor: "#137333", // Classroom Green
    teacherName: "Profª. Laura Gómez",
    teacherEmail: "lgomez@digitechfp.com",
    progress: 65,
    assignmentsDueSoon: [
      {
        id: 102,
        courseId: 2,
        courseName: "Desarrollo de Interfaces",
        name: "Entrega Sprint 2: Usabilidad y Diseño Mobile",
        intro: "Diseño y prototipado responsive aplicando Material Design y directrices Human Interface Guidelines de Apple.",
        dueDate: addDays(1).toISOString(),
        maxPoints: 10,
        isSubmitted: false,
        topicName: "Sprint 2: Prototipado e Interacción",
        attachments: [
          { id: "att3", title: "Criterios_Evaluacion_Sprint2.pdf", fileSize: "540 KB", fileType: "pdf" }
        ],
        privateComments: []
      }
    ]
  },
  {
    id: 3,
    fullname: "Acceso a Datos (DAM 2º)",
    shortname: "AD_DAM2",
    themeColor: "#E37400", // Classroom Orange
    teacherName: "Prof. Javier Morales",
    teacherEmail: "jmorales@digitechfp.com",
    progress: 80,
    assignmentsDueSoon: [
      {
        id: 103,
        courseId: 3,
        courseName: "Acceso a Datos",
        name: "Ejercicio 4: Consultas REST y Mapeo ORM",
        intro: "Integración de capa DAO con servicios REST de Moodle y base de datos relacional PostgreSQL.",
        dueDate: addDays(4).toISOString(),
        maxPoints: 100,
        isSubmitted: false,
        topicName: "Unidad 4: Servicios Web y APIs",
        attachments: [],
        privateComments: []
      }
    ]
  },
  {
    id: 4,
    fullname: "Sistemas de Gestión Empresarial (DAM 2º)",
    shortname: "SGE_DAM2",
    themeColor: "#9334E6", // Classroom Purple
    teacherName: "Profª. Beatriz Santos",
    teacherEmail: "bsantos@digitechfp.com",
    progress: 55,
    assignmentsDueSoon: [
      {
        id: 104,
        courseId: 4,
        courseName: "Sistemas de Gestión Empresarial",
        name: "Caso Práctico: Despliegue de Módulo ERP",
        intro: "Configuración de entorno de pruebas y personalización de vistas de cliente en Odoo.",
        dueDate: addDays(7).toISOString(),
        maxPoints: 100,
        isSubmitted: false,
        topicName: "Bloque II: Personalización Odoo",
        attachments: [],
        privateComments: []
      }
    ]
  },
  {
    id: 5,
    fullname: "Empresa e Iniciativa Emprendedora",
    shortname: "EIE_DAM2",
    themeColor: "#007B83", // Classroom Teal
    teacherName: "Prof. Fernando Ortega",
    teacherEmail: "fortega@digitechfp.com",
    progress: 90,
    assignmentsDueSoon: [
      {
        id: 105,
        courseId: 5,
        courseName: "Empresa e Iniciativa Emprendedora",
        name: "Plan de Empresa: Estudio de Viabilidad",
        intro: "Análisis DAFO, plan financiero y Canvas del modelo de negocio de startup tecnológica.",
        dueDate: addDays(-3).toISOString(),
        maxPoints: 10,
        isSubmitted: true,
        submissionDate: addDays(-3).toISOString(),
        grade: "9.5 / 10",
        topicName: "Tema 2: Plan Financiero",
        attachments: [],
        privateComments: [
          { authorName: "Prof. Fernando Ortega", text: "Excelente análisis financiero de tesorería y retorno.", date: "Hace 2 días", isCurrentUser: false }
        ]
      }
    ]
  }
];

export const DEMO_ANNOUNCEMENTS = {
  1: [
    {
      id: 201,
      courseId: 1,
      authorName: "Prof. Alejandro Ruiz",
      date: "Ayer",
      content: "¡Hola a todos! Recordad que la Práctica 3 vence en 2 días. Os he dejado en el tablón los enlaces de soporte para configurar el centro de notificaciones de iOS. Podéis comentar aquí cualquier duda.",
      comments: [
        { authorName: "Elena Cano", text: "¿Podemos usar SwiftUI moderno con async/await y URLSession?", date: "Hace 18 horas" },
        { authorName: "Prof. Alejandro Ruiz", text: "Sí, es la opción recomendada para iOS.", date: "Hace 15 horas" }
      ]
    },
    {
      id: 202,
      courseId: 1,
      authorName: "Prof. Alejandro Ruiz",
      date: "Hace 5 días",
      content: "Publicadas las calificaciones del examen parcial de Swift y arquitectura MVVM en el campus.",
      comments: []
    }
  ],
  2: [
    {
      id: 203,
      courseId: 2,
      authorName: "Profª. Laura Gómez",
      date: "Hace 2 días",
      content: "Recordatorio: mañana revisaremos los wireframes y el flujo de navegación de Google Classroom en clase.",
      comments: []
    }
  ]
};

export const DEMO_TOPICS = {
  1: ["Tema 1: Arquitectura iOS & Swift", "Tema 2: Componentes y Vistas SwiftUI", "Tema 3: Desarrollo iOS & SwiftUI"],
  2: ["Sprint 1: Principios de Diseño y Accesibilidad", "Sprint 2: Prototipado e Interacción"],
  3: ["Unidad 1: Ficheros y Serialización", "Unidad 4: Servicios Web y APIs"],
  4: ["Bloque I: Arquitectura ERP", "Bloque II: Personalización Odoo"],
  5: ["Tema 1: Idea y Canvas", "Tema 2: Plan Financiero"]
};
