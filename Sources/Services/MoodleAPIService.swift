import Foundation

public enum MoodleAPIError: LocalizedError {
    case invalidURL
    case invalidCredentials(String)
    case networkError(String)
    case serverError(String)
    case parsingError(String)
    case missingToken

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL del campus no válida."
        case .invalidCredentials(let message):
            return "Error de acceso: \(message)"
        case .networkError(let message):
            return "Error de conexión con el campus: \(message)"
        case .serverError(let message):
            return "El campus respondió con un error: \(message)"
        case .parsingError(let message):
            return "Error al procesar los datos del campus: \(message)"
        case .missingToken:
            return "Sesión expirada o ficha de acceso no encontrada."
        }
    }
}

public final class MoodleAPIService {
    public static let shared = MoodleAPIService()

    public let baseURLString: String

    public init(baseURL: String = "https://campus.digitechfp.com") {
        self.baseURLString = baseURL
    }

    // Google Classroom vibrant palette to assign to courses
    private let classroomPalette = [
        "#1A73E8", // Blue
        "#137333", // Green
        "#E37400", // Orange
        "#9334E6", // Purple
        "#007B83", // Teal
        "#C5221F", // Red
        "#E52592", // Pink
        "#188038"  // Dark green
    ]

    // MARK: - Login / Token Generation
    public func login(username: String, password: String) async throws -> User {
        guard let tokenUrl = URL(string: "\(baseURLString)/login/token.php") else {
            throw MoodleAPIError.invalidURL
        }

        var request = URLRequest(url: tokenUrl)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "username": username,
            "password": password,
            "service": "moodle_mobile_app"
        ]
        request.httpBody = buildQueryString(from: parameters).data(using: .utf8)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw MoodleAPIError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MoodleAPIError.serverError("Código de estado no válido")
        }

        let tokenResponse: MoodleTokenResponse
        do {
            tokenResponse = try JSONDecoder().decode(MoodleTokenResponse.self, from: data)
        } catch {
            // Check if returned text error
            if let stringData = String(data: data, encoding: .utf8), stringData.contains("error") {
                throw MoodleAPIError.invalidCredentials(stringData)
            }
            throw MoodleAPIError.parsingError(error.localizedDescription)
        }

        if let error = tokenResponse.error {
            throw MoodleAPIError.invalidCredentials(error)
        }

        guard let token = tokenResponse.token, !token.isEmpty else {
            throw MoodleAPIError.invalidCredentials("No se pudo obtener el token de acceso móvil")
        }

        // Fetch site info to get user details
        let siteInfo = try await fetchSiteInfo(token: token)

        return User(
            id: siteInfo.userid ?? 1,
            username: siteInfo.username ?? username,
            fullname: siteInfo.fullname ?? username,
            firstname: siteInfo.firstname ?? username,
            lastname: siteInfo.lastname ?? "",
            userpictureurl: siteInfo.userpictureurl,
            siteurl: baseURLString,
            token: token,
            isDemo: false
        )
    }

    // MARK: - Site Info (core_webservice_get_site_info)
    public func fetchSiteInfo(token: String) async throws -> MoodleSiteInfoResponse {
        let responseData = try await callWebService(
            function: "core_webservice_get_site_info",
            token: token,
            parameters: [:]
        )

        do {
            return try JSONDecoder().decode(MoodleSiteInfoResponse.self, from: responseData)
        } catch {
            throw MoodleAPIError.parsingError("No se pudo interpretar la información del usuario")
        }
    }

    // MARK: - Enrolled Courses (core_enrol_get_users_courses)
    public func fetchEnrolledCourses(token: String, userId: Int) async throws -> [Course] {
        let responseData = try await callWebService(
            function: "core_enrol_get_users_courses",
            token: token,
            parameters: ["userid": String(userId)]
        )

        let dtos: [MoodleEnrolledCourseDTO]
        do {
            dtos = try JSONDecoder().decode([MoodleEnrolledCourseDTO].self, from: responseData)
        } catch {
            throw MoodleAPIError.parsingError("Error al cargar las asignaturas del campus")
        }

        var courses: [Course] = []
        for (index, dto) in dtos.enumerated() {
            let colorHex = classroomPalette[index % classroomPalette.count]
            let course = Course(
                id: dto.id,
                fullname: dto.fullname ?? "Curso Digitech",
                shortname: dto.shortname ?? "",
                summary: cleanHTML(dto.summary ?? ""),
                themeColorHex: colorHex,
                teacherName: "Profesorado Digitech FP",
                teacherEmail: "campus@digitechfp.com",
                assignmentsDueSoon: [],
                progress: dto.progress
            )
            courses.append(course)
        }

        return courses
    }

    // MARK: - Assignments (mod_assign_get_assignments)
    public func fetchAssignments(token: String, courseIds: [Int]) async throws -> [Assignment] {
        var params: [String: String] = [:]
        for (index, id) in courseIds.enumerated() {
            params["courseids[\(index)]"] = String(id)
        }

        let responseData = try await callWebService(
            function: "mod_assign_get_assignments",
            token: token,
            parameters: params
        )

        let response: MoodleAssignmentsResponse
        do {
            response = try JSONDecoder().decode(MoodleAssignmentsResponse.self, from: responseData)
        } catch {
            throw MoodleAPIError.parsingError("Error al cargar las tareas del campus")
        }

        var assignments: [Assignment] = []
        if let courses = response.courses {
            for courseDTO in courses {
                guard let assignDTOs = courseDTO.assignments else { continue }
                for assignDTO in assignDTOs {
                    let due = assignDTO.duedate.map { Date(timeIntervalSince1970: TimeInterval($0)) }
                    let cutoff = assignDTO.cutoffdate.map { Date(timeIntervalSince1970: TimeInterval($0)) }

                    var attachments: [AssignmentAttachment] = []
                    if let introAttachments = assignDTO.introattachments {
                        for att in introAttachments {
                            if let name = att.filename, let url = att.fileurl {
                                attachments.append(AssignmentAttachment(
                                    title: name,
                                    fileUrl: url,
                                    fileSize: att.filesize.map { "\($0 / 1024) KB" },
                                    fileType: att.mimetype ?? "application/octet-stream"
                                ))
                            }
                        }
                    }

                    let assignment = Assignment(
                        id: assignDTO.id,
                        cmid: assignDTO.cmid ?? 0,
                        courseId: courseDTO.id,
                        courseName: courseDTO.fullname ?? "",
                        name: assignDTO.name ?? "Tarea sin nombre",
                        intro: cleanHTML(assignDTO.intro ?? ""),
                        dueDate: due,
                        cutoffDate: cutoff,
                        maxPoints: 100,
                        isSubmitted: false,
                        attachments: attachments
                    )
                    assignments.append(assignment)
                }
            }
        }

        return assignments
    }

    // MARK: - Course Contents & Topics (core_course_get_contents)
    public func fetchCourseContents(token: String, courseId: Int) async throws -> [Topic] {
        let responseData = try await callWebService(
            function: "core_course_get_contents",
            token: token,
            parameters: ["courseid": String(courseId)]
        )

        let sections: [MoodleCourseSectionDTO]
        do {
            sections = try JSONDecoder().decode([MoodleCourseSectionDTO].self, from: responseData)
        } catch {
            return []
        }

        var topics: [Topic] = []
        for section in sections {
            let sectionName = section.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "General"
            var topicAssignments: [Assignment] = []

            if let modules = section.modules {
                for mod in modules where mod.modname == "assign" {
                    let assign = Assignment(
                        id: mod.instance ?? mod.id,
                        cmid: mod.id,
                        courseId: courseId,
                        courseName: "",
                        name: mod.name ?? "Tarea",
                        intro: "",
                        topicName: sectionName
                    )
                    topicAssignments.append(assign)
                }
            }

            if !topicAssignments.isEmpty || !sectionName.isEmpty {
                topics.append(Topic(id: section.id, name: sectionName, assignments: topicAssignments))
            }
        }

        return topics
    }

    // MARK: - Moodle Chats / Conversations (core_message_*)
    public func fetchConversations(token: String, userId: Int) async throws -> [MoodleConversation] {
        let responseData = try await callWebService(
            function: "core_message_get_conversations",
            token: token,
            parameters: [
                "userid": String(userId),
                "limitfrom": "0",
                "limitnum": "50"
            ]
        )

        let decoded: MoodleConversationsResponse
        do {
            decoded = try JSONDecoder().decode(MoodleConversationsResponse.self, from: responseData)
        } catch {
            throw MoodleAPIError.parsingError("Error al procesar los chats de Moodle")
        }

        var conversations: [MoodleConversation] = []
        guard let dtos = decoded.conversations else { return [] }

        for (index, dto) in dtos.enumerated() {
            let otherMember = dto.members?.first(where: { $0.id != userId }) ?? dto.members?.first
            let displayName: String
            if let dtoName = dto.name, !dtoName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                displayName = dtoName
            } else if let memberName = otherMember?.fullname, !memberName.isEmpty {
                displayName = memberName
            } else {
                displayName = "Chat de Moodle #\(dto.id)"
            }

            let subtitle: String
            if let sub = dto.subname, !sub.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                subtitle = sub
            } else if dto.type == 2 {
                subtitle = "Grupo del curso (\(dto.membercount ?? 0) miembros)"
            } else {
                subtitle = "Mensajería directa Moodle"
            }

            var mappedMessages: [MoodleChatMessage] = []
            if let msgDTOs = dto.messages {
                // Moodle returns newest messages first in conversation summary; sort oldest to newest
                let sortedDTOs = msgDTOs.sorted { ($0.timecreated ?? 0) < ($1.timecreated ?? 0) }
                for m in sortedDTOs {
                    let fromId = m.useridfrom ?? 0
                    let senderName = fromId == userId
                        ? "Tú"
                        : (dto.members?.first(where: { $0.id == fromId })?.fullname ?? displayName)
                    let msgDate = m.timecreated.map { Date(timeIntervalSince1970: TimeInterval($0)) } ?? Date()
                    mappedMessages.append(
                        MoodleChatMessage(
                            id: m.id,
                            senderId: fromId,
                            senderName: senderName,
                            text: cleanHTML(m.text ?? ""),
                            date: msgDate,
                            isFromCurrentUser: fromId == userId
                        )
                    )
                }
            }

            let colorHex = classroomPalette[index % classroomPalette.count]
            let conv = MoodleConversation(
                id: dto.id,
                name: displayName,
                subtitle: subtitle,
                partnerId: otherMember?.id,
                isGroup: (dto.type == 2),
                isOnline: otherMember?.isonline ?? false,
                unreadCount: dto.unreadcount ?? ((dto.isread == false) ? 1 : 0),
                messages: mappedMessages,
                themeColorHex: colorHex
            )
            conversations.append(conv)
        }

        return conversations
    }

    public func fetchConversationMessages(token: String, userId: Int, conversationId: Int) async throws -> [MoodleChatMessage] {
        let responseData = try await callWebService(
            function: "core_message_get_conversation_messages",
            token: token,
            parameters: [
                "currentuserid": String(userId),
                "convid": String(conversationId),
                "limitfrom": "0",
                "limitnum": "50",
                "newest": "1"
            ]
        )

        let decoded: MoodleConversationMessagesResponse
        do {
            decoded = try JSONDecoder().decode(MoodleConversationMessagesResponse.self, from: responseData)
        } catch {
            throw MoodleAPIError.parsingError("No se pudieron cargar los mensajes de la conversación")
        }

        let members = decoded.members ?? []
        let rawMessages = decoded.messages ?? []
        let sorted = rawMessages.sorted { ($0.timecreated ?? 0) < ($1.timecreated ?? 0) }

        return sorted.map { m in
            let fromId = m.useridfrom ?? 0
            let senderName = fromId == userId
                ? "Tú"
                : (members.first(where: { $0.id == fromId })?.fullname ?? "Usuario Moodle")
            let date = m.timecreated.map { Date(timeIntervalSince1970: TimeInterval($0)) } ?? Date()
            return MoodleChatMessage(
                id: m.id,
                senderId: fromId,
                senderName: senderName,
                text: cleanHTML(m.text ?? ""),
                date: date,
                isFromCurrentUser: fromId == userId
            )
        }
    }

    public func sendChatMessage(
        token: String,
        userId: Int,
        conversationId: Int,
        partnerId: Int?,
        text: String
    ) async throws -> MoodleChatMessage {
        // Primary: core_message_send_messages_to_conversation
        do {
            let responseData = try await callWebService(
                function: "core_message_send_messages_to_conversation",
                token: token,
                parameters: [
                    "conversationid": String(conversationId),
                    "messages[0][text]": text,
                    "messages[0][textformat]": "1"
                ]
            )
            if let sentList = try? JSONDecoder().decode([MoodleSentMessageDTO].self, from: responseData),
               let first = sentList.first {
                let date = first.timecreated.map { Date(timeIntervalSince1970: TimeInterval($0)) } ?? Date()
                return MoodleChatMessage(
                    id: first.id ?? Int.random(in: 100000...999999),
                    senderId: userId,
                    senderName: "Tú",
                    text: cleanHTML(first.text ?? text),
                    date: date,
                    isFromCurrentUser: true
                )
            }
        } catch {
            // Fallback to core_message_send_instant_messages if partnerId is available
            if let partnerId = partnerId {
                let responseData = try await callWebService(
                    function: "core_message_send_instant_messages",
                    token: token,
                    parameters: [
                        "messages[0][touserid]": String(partnerId),
                        "messages[0][text]": text,
                        "messages[0][textformat]": "1"
                    ]
                )
                if let sentList = try? JSONDecoder().decode([MoodleSentMessageDTO].self, from: responseData),
                   let first = sentList.first {
                    if let errorMsg = first.errormessage, !errorMsg.isEmpty {
                        throw MoodleAPIError.serverError(errorMsg)
                    }
                    return MoodleChatMessage(
                        id: first.msgid ?? Int.random(in: 100000...999999),
                        senderId: userId,
                        senderName: "Tú",
                        text: text,
                        date: Date(),
                        isFromCurrentUser: true
                    )
                }
            }
            throw error
        }

        return MoodleChatMessage(
            senderId: userId,
            senderName: "Tú",
            text: text,
            date: Date(),
            isFromCurrentUser: true
        )
    }

    public func markConversationAsRead(token: String, userId: Int, conversationId: Int) async {
        _ = try? await callWebService(
            function: "core_message_mark_all_conversation_messages_as_read",
            token: token,
            parameters: [
                "userid": String(userId),
                "conversationid": String(conversationId)
            ]
        )
    }

    // MARK: - Core Helper
    private func callWebService(
        function: String,
        token: String,
        parameters: [String: String]
    ) async throws -> Data {
        guard let url = URL(string: "\(baseURLString)/webservice/rest/server.php") else {
            throw MoodleAPIError.invalidURL
        }

        var allParams = parameters
        allParams["wstoken"] = token
        allParams["wsfunction"] = function
        allParams["moodlewsrestformat"] = "json"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = buildQueryString(from: allParams).data(using: .utf8)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw MoodleAPIError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MoodleAPIError.serverError("Error del servidor Moodle")
        }

        // Check if the JSON returned is an exception
        if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let exception = jsonObject["exception"] as? String {
            let message = jsonObject["message"] as? String ?? exception
            throw MoodleAPIError.serverError(message)
        }

        return data
    }

    private func buildQueryString(from dict: [String: String]) -> String {
        return dict.map { key, value in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            return "\(escapedKey)=\(escapedValue)"
        }.joined(separator: "&")
    }

    private func cleanHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else { return html }
        if let attributed = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            return attributed.string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        // Fallback regex strip
        return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
