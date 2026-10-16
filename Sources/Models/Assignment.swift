import Foundation

public enum AssignmentStatus: String, Codable, CaseIterable {
    case assigned = "Asignada"
    case submitted = "Entregada"
    case missing = "Sin entregar"
    case graded = "Calificada"
}

public struct AssignmentAttachment: Identifiable, Codable, Equatable {
    public let id: String
    public let title: String
    public let fileUrl: String
    public let fileSize: String?
    public let fileType: String // "pdf", "zip", "doc", "link"

    public init(id: String = UUID().uuidString, title: String, fileUrl: String, fileSize: String? = nil, fileType: String = "pdf") {
        self.id = id
        self.title = title
        self.fileUrl = fileUrl
        self.fileSize = fileSize
        self.fileType = fileType
    }
}

public struct PrivateComment: Identifiable, Codable, Equatable {
    public let id: String
    public let authorName: String
    public let text: String
    public let date: Date
    public let isCurrentUser: Bool

    public init(id: String = UUID().uuidString, authorName: String, text: String, date: Date = Date(), isCurrentUser: Bool = true) {
        self.id = id
        self.authorName = authorName
        self.text = text
        self.date = date
        self.isCurrentUser = isCurrentUser
    }
}

public struct Assignment: Identifiable, Codable, Equatable {
    public let id: Int
    public let cmid: Int
    public let courseId: Int
    public var courseName: String
    public let name: String
    public let intro: String
    public let dueDate: Date?
    public let cutoffDate: Date?
    public let maxPoints: Int
    public var isSubmitted: Bool
    public var submissionDate: Date?
    public var grade: String?
    public var topicName: String?
    public var attachments: [AssignmentAttachment]
    public var privateComments: [PrivateComment]

    public init(
        id: Int,
        cmid: Int = 0,
        courseId: Int,
        courseName: String = "",
        name: String,
        intro: String = "",
        dueDate: Date? = nil,
        cutoffDate: Date? = nil,
        maxPoints: Int = 100,
        isSubmitted: Bool = false,
        submissionDate: Date? = nil,
        grade: String? = nil,
        topicName: String? = nil,
        attachments: [AssignmentAttachment] = [],
        privateComments: [PrivateComment] = []
    ) {
        self.id = id
        self.cmid = cmid
        self.courseId = courseId
        self.courseName = courseName
        self.name = name
        self.intro = intro
        self.dueDate = dueDate
        self.cutoffDate = cutoffDate
        self.maxPoints = maxPoints
        self.isSubmitted = isSubmitted
        self.submissionDate = submissionDate
        self.grade = grade
        self.topicName = topicName
        self.attachments = attachments
        self.privateComments = privateComments
    }

    public var status: AssignmentStatus {
        if let grade = grade, !grade.isEmpty {
            return .graded
        }
        if isSubmitted {
            return .submitted
        }
        if let due = dueDate, due < Date() {
            return .missing
        }
        return .assigned
    }

    public var formattedDueDate: String {
        guard let due = dueDate else { return "Sin fecha de entrega" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")

        let calendar = Calendar.current
        if calendar.isDateInToday(due) {
            formatter.dateFormat = "'Hoy a las' HH:mm"
            return formatter.string(from: due)
        } else if calendar.isDateInTomorrow(due) {
            formatter.dateFormat = "'Mañana a las' HH:mm"
            return formatter.string(from: due)
        } else {
            formatter.dateFormat = "d 'de' MMMM, HH:mm"
            return "Fecha de entrega: " + formatter.string(from: due)
        }
    }
}
