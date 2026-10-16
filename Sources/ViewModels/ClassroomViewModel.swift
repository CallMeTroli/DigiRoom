import Foundation
import Combine

public enum ClassroomTab: String, CaseIterable, Identifiable {
    case stream = "Novedades"
    case classwork = "Trabajo de clase"
    case people = "Personas"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .stream: return "bubble.left.and.bubble.right.fill"
        case .classwork: return "clipboard.fill"
        case .people: return "person.2.fill"
        }
    }
}

public enum TodoTab: String, CaseIterable, Identifiable {
    case assigned = "Asignadas"
    case missing = "Sin entregar"
    case completed = "Completadas"

    public var id: String { rawValue }
}

@MainActor
public final class ClassroomViewModel: ObservableObject {
    @Published public var courses: [Course] = []
    @Published public var allAssignments: [Assignment] = []
    @Published public var announcementsByCourse: [Int: [Announcement]] = [:]
    @Published public var topicsByCourse: [Int: [Topic]] = [:]

    @Published public var selectedCourse: Course? = nil
    @Published public var selectedAssignment: Assignment? = nil
    @Published public var activeTab: ClassroomTab = .stream
    @Published public var isSideDrawerOpen: Bool = false
    @Published public var showNotificationSettings: Bool = false
    @Published public var showTodoList: Bool = false
    @Published public var showProfileSheet: Bool = false

    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    private let apiService = MoodleAPIService.shared
    private let mockService = MockDataService.shared

    public init() {}

    public func loadData(for user: User) async {
        isLoading = true
        errorMessage = nil

        if user.isDemo {
            // Load Demo Data
            let demoCourses = mockService.getDemoCourses()
            self.courses = demoCourses
            self.allAssignments = mockService.getDemoAssignments()

            for course in demoCourses {
                self.announcementsByCourse[course.id] = mockService.getDemoAnnouncements(for: course.id)
                self.topicsByCourse[course.id] = mockService.getDemoTopics(for: course.id)
            }
        } else {
            // Load Live Data from campus.digitechfp.com
            do {
                let fetchedCourses = try await apiService.fetchEnrolledCourses(token: user.token, userId: user.id)
                self.courses = fetchedCourses

                let courseIds = fetchedCourses.map { $0.id }
                let fetchedAssignments = try await apiService.fetchAssignments(token: user.token, courseIds: courseIds)
                self.allAssignments = fetchedAssignments

                // Populate assignments inside each course
                for i in 0..<self.courses.count {
                    let cId = self.courses[i].id
                    let courseAssigns = fetchedAssignments.filter { $0.courseId == cId }
                    self.courses[i].assignmentsDueSoon = courseAssigns
                }

                // Fetch topics / sections for each course
                for course in fetchedCourses {
                    if let topics = try? await apiService.fetchCourseContents(token: user.token, courseId: course.id) {
                        self.topicsByCourse[course.id] = topics
                    }
                }
            } catch {
                self.errorMessage = error.localizedDescription
                // Fallback gracefully to demo/cached if offline
                if self.courses.isEmpty {
                    self.courses = mockService.getDemoCourses()
                    self.allAssignments = mockService.getDemoAssignments()
                }
            }
        }

        isLoading = false
    }

    public func selectCourse(_ course: Course) {
        self.selectedCourse = course
        self.activeTab = .stream
    }

    public func toggleSubmission(for assignmentId: Int) {
        if let index = allAssignments.firstIndex(where: { $0.id == assignmentId }) {
            allAssignments[index].isSubmitted.toggle()
            allAssignments[index].submissionDate = allAssignments[index].isSubmitted ? Date() : nil

            if let selected = selectedAssignment, selected.id == assignmentId {
                selectedAssignment = allAssignments[index]
            }

            // Also update in courses
            for i in 0..<courses.count {
                if let aIndex = courses[i].assignmentsDueSoon.firstIndex(where: { $0.id == assignmentId }) {
                    courses[i].assignmentsDueSoon[aIndex].isSubmitted = allAssignments[index].isSubmitted
                }
            }
        }
    }

    public func addPrivateComment(assignmentId: Int, author: String, text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let comment = PrivateComment(authorName: author, text: text, date: Date(), isCurrentUser: true)
        if let index = allAssignments.firstIndex(where: { $0.id == assignmentId }) {
            allAssignments[index].privateComments.append(comment)
            if let selected = selectedAssignment, selected.id == assignmentId {
                selectedAssignment = allAssignments[index]
            }
        }
    }

    public func addClassComment(courseId: Int, announcementId: Int, author: String, text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let comment = AnnouncementComment(authorName: author, date: Date(), text: text)

        if var announcements = announcementsByCourse[courseId] {
            if let index = announcements.firstIndex(where: { $0.id == announcementId }) {
                announcements[index].comments.append(comment)
                announcementsByCourse[courseId] = announcements
            }
        }
    }

    public func assignments(for courseId: Int) -> [Assignment] {
        return allAssignments.filter { $0.courseId == courseId }
    }

    public func todoAssignments(for tab: TodoTab) -> [Assignment] {
        switch tab {
        case .assigned:
            return allAssignments.filter { !$0.isSubmitted && ($0.dueDate == nil || $0.dueDate! >= Date()) }
        case .missing:
            return allAssignments.filter { !$0.isSubmitted && $0.dueDate != nil && $0.dueDate! < Date() }
        case .completed:
            return allAssignments.filter { $0.isSubmitted }
        }
    }
}
