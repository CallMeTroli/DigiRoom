import Foundation

public struct AnnouncementComment: Identifiable, Codable, Equatable {
    public let id: String
    public let authorName: String
    public let authorAvatar: String?
    public let date: Date
    public let text: String

    public init(id: String = UUID().uuidString, authorName: String, authorAvatar: String? = nil, date: Date = Date(), text: String) {
        self.id = id
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.date = date
        self.text = text
    }
}

public struct Announcement: Identifiable, Codable, Equatable {
    public let id: Int
    public let courseId: Int
    public let authorName: String
    public let authorAvatar: String?
    public let date: Date
    public let content: String
    public var comments: [AnnouncementComment]

    public init(
        id: Int,
        courseId: Int,
        authorName: String,
        authorAvatar: String? = nil,
        date: Date = Date(),
        content: String,
        comments: [AnnouncementComment] = []
    ) {
        self.id = id
        self.courseId = courseId
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.date = date
        self.content = content
        self.comments = comments
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d 'de' MMMM"
        return formatter.string(from: date)
    }
}

public struct Topic: Identifiable, Codable, Equatable {
    public let id: Int
    public let name: String
    public var assignments: [Assignment]

    public init(id: Int, name: String, assignments: [Assignment] = []) {
        self.id = id
        self.name = name
        self.assignments = assignments
    }
}
