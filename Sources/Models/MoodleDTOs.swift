import Foundation

// MARK: - Token Response
public struct MoodleTokenResponse: Codable {
    public let token: String?
    public let privatetoken: String?
    public let error: String?
    public let errorcode: String?
}

// MARK: - Site Info Response (core_webservice_get_site_info)
public struct MoodleSiteInfoResponse: Codable {
    public let sitename: String?
    public let username: String?
    public let firstname: String?
    public let lastname: String?
    public let fullname: String?
    public let userid: Int?
    public let siteurl: String?
    public let userpictureurl: String?
    public let functions: [MoodleFunctionDTO]?
    public let usercalendartype: String?
    public let userissiteadmin: Bool?
    public let theme: String?
}

public struct MoodleFunctionDTO: Codable {
    public let name: String?
    public let version: String?
}

// MARK: - Enrolled Courses Response (core_enrol_get_users_courses)
public struct MoodleEnrolledCourseDTO: Codable {
    public let id: Int
    public let shortname: String?
    public let fullname: String?
    public let displayname: String?
    public let summary: String?
    public let progress: Double?
    public let startdate: Int?
    public let enddate: Int?
    public let visible: Int?
}

// MARK: - Assignments Response (mod_assign_get_assignments)
public struct MoodleAssignmentsResponse: Codable {
    public let courses: [MoodleCourseWithAssignmentsDTO]?
    public let warnings: [MoodleWarningDTO]?
}

public struct MoodleCourseWithAssignmentsDTO: Codable {
    public let id: Int
    public let fullname: String?
    public let shortname: String?
    public let assignments: [MoodleAssignmentDTO]?
}

public struct MoodleAssignmentDTO: Codable {
    public let id: Int
    public let cmid: Int?
    public let course: Int?
    public let name: String?
    public let nosubmissions: Int?
    public let duedate: Int?
    public let cutoffdate: Int?
    public let intro: String?
    public let introattachments: [MoodleIntroAttachmentDTO]?
    public let gradingduedate: Int?
}

public struct MoodleIntroAttachmentDTO: Codable {
    public let filename: String?
    public let fileurl: String?
    public let filesize: Int?
    public let mimetype: String?
}

// MARK: - Calendar Action Events (core_calendar_get_action_events_by_timesort)
public struct MoodleActionEventsResponse: Codable {
    public let events: [MoodleCalendarEventDTO]?
}

public struct MoodleCalendarEventDTO: Codable {
    public let id: Int
    public let name: String?
    public let description: String?
    public let course: MoodleEventCourseDTO?
    public let timesort: Int?
    public let timestart: Int?
    public let timeduration: Int?
    public let eventtype: String?
    public let modulename: String?
    public let instance: Int?
    public let isactionevent: Bool?
    public let action: MoodleEventActionDTO?
}

public struct MoodleEventCourseDTO: Codable {
    public let id: Int
    public let fullname: String?
    public let shortname: String?
}

public struct MoodleEventActionDTO: Codable {
    public let name: String?
    public let url: String?
    public let itemcount: Int?
    public let actionable: Bool?
}

// MARK: - Course Contents (core_course_get_contents)
public struct MoodleCourseSectionDTO: Codable {
    public let id: Int
    public let name: String?
    public let visible: Int?
    public let summary: String?
    public let modules: [MoodleCourseModuleDTO]?
}

public struct MoodleCourseModuleDTO: Codable {
    public let id: Int
    public let url: String?
    public let name: String?
    public let instance: Int?
    public let modicon: String?
    public let modname: String?
    public let modplural: String?
    public let indent: Int?
    public let contents: [MoodleModuleContentDTO]?
}

public struct MoodleModuleContentDTO: Codable {
    public let type: String?
    public let filename: String?
    public let filepath: String?
    public let filesize: Int?
    public let fileurl: String?
    public let timecreated: Int?
    public let timemodified: Int?
    public let mimetype: String?
    public let author: String?
}

public struct MoodleWarningDTO: Codable {
    public let item: String?
    public let itemid: Int?
    public let warningcode: String?
    public let message: String?
}

// MARK: - Moodle Chat / Messaging DTOs (core_message_*)
public struct MoodleConversationsResponse: Codable {
    public let conversations: [MoodleConversationDTO]?
}

public struct MoodleConversationDTO: Codable {
    public let id: Int
    public let name: String?
    public let subname: String?
    public let imageurl: String?
    public let type: Int? // 1: Individual, 2: Group, 3: Self
    public let membercount: Int?
    public let isread: Bool?
    public let unreadcount: Int?
    public let members: [MoodleConversationMemberDTO]?
    public let messages: [MoodleConversationMessageDTO]?
}

public struct MoodleConversationMemberDTO: Codable {
    public let id: Int
    public let fullname: String?
    public let profileimageurl: String?
    public let isonline: Bool?
}

public struct MoodleConversationMessageDTO: Codable {
    public let id: Int
    public let useridfrom: Int?
    public let text: String?
    public let timecreated: Int?
}

public struct MoodleConversationMessagesResponse: Codable {
    public let id: Int?
    public let members: [MoodleConversationMemberDTO]?
    public let messages: [MoodleConversationMessageDTO]?
}

public struct MoodleSentMessageDTO: Codable {
    public let id: Int?
    public let msgid: Int?
    public let useridfrom: Int?
    public let text: String?
    public let timecreated: Int?
    public let conversationid: Int?
    public let errormessage: String?
}

