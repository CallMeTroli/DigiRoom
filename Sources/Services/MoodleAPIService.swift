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
