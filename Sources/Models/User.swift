import Foundation

public struct User: Identifiable, Codable, Equatable {
    public let id: Int
    public let username: String
    public let fullname: String
    public let firstname: String
    public let lastname: String
    public let userpictureurl: String?
    public let siteurl: String
    public let token: String
    public let isDemo: Bool

    public init(
        id: Int,
        username: String,
        fullname: String,
        firstname: String,
        lastname: String,
        userpictureurl: String? = nil,
        siteurl: String = "https://campus.digitechfp.com",
        token: String,
        isDemo: Bool = false
    ) {
        self.id = id
        self.username = username
        self.fullname = fullname
        self.firstname = firstname
        self.lastname = lastname
        self.userpictureurl = userpictureurl
        self.siteurl = siteurl
        self.token = token
        self.isDemo = isDemo
    }

    public var initials: String {
        let first = firstname.first.map { String($0) } ?? ""
        let last = lastname.first.map { String($0) } ?? ""
        let combined = "\(first)\(last)".uppercased()
        return combined.isEmpty ? "U" : combined
    }
}
