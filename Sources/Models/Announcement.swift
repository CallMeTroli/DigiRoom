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

public struct MoodleChatMessage: Identifiable, Codable, Equatable {
    public let id: Int
    public let senderId: Int
    public let senderName: String
    public let text: String
    public let date: Date
    public let isFromCurrentUser: Bool

    public init(
        id: Int = Int.random(in: 100000...999999),
        senderId: Int,
        senderName: String,
        text: String,
        date: Date = Date(),
        isFromCurrentUser: Bool
    ) {
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.text = text
        self.date = date
        self.isFromCurrentUser = isFromCurrentUser
    }

    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "d MMM, HH:mm"
        }
        return formatter.string(from: date)
    }
}

public struct MoodleConversation: Identifiable, Codable, Equatable {
    public let id: Int
    public var name: String
    public var subtitle: String
    public var partnerId: Int?
    public var isGroup: Bool
    public var isOnline: Bool
    public var unreadCount: Int
    public var messages: [MoodleChatMessage]
    public var themeColorHex: String

    public init(
        id: Int,
        name: String,
        subtitle: String = "Campus Digitech FP",
        partnerId: Int? = nil,
        isGroup: Bool = false,
        isOnline: Bool = false,
        unreadCount: Int = 0,
        messages: [MoodleChatMessage] = [],
        themeColorHex: String = "#1A73E8"
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.partnerId = partnerId
        self.isGroup = isGroup
        self.isOnline = isOnline
        self.unreadCount = unreadCount
        self.messages = messages
        self.themeColorHex = themeColorHex
    }

    public var lastMessageText: String {
        messages.last?.text ?? "Sin mensajes todavía"
    }

    public var lastMessageTimeFormatted: String {
        guard let lastDate = messages.last?.date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        if Calendar.current.isDateInToday(lastDate) {
            formatter.dateFormat = "HH:mm"
        } else if Calendar.current.isDateInYesterday(lastDate) {
            return "Ayer"
        } else {
            formatter.dateFormat = "dd/MM"
        }
        return formatter.string(from: lastDate)
    }

    public var initials: String {
        let parts = name
            .replacingOccurrences(of: "Prof.", with: "")
            .replacingOccurrences(of: "Profª.", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
        if parts.count >= 2 {
            let first = parts[0].prefix(1)
            let second = parts[1].prefix(1)
            return "\(first)\(second)".uppercased()
        } else if let first = parts.first {
            return String(first.prefix(2)).uppercased()
        }
        return "DM"
    }
}

