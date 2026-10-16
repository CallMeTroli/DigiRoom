import SwiftUI

public struct CourseDetailView: View {
    public let course: Course
    public let user: User?
    @ObservedObject public var viewModel: ClassroomViewModel
    public let onBack: () -> Void
    public let onSelectAssignment: (Assignment) -> Void

    public init(
        course: Course,
        user: User?,
        viewModel: ClassroomViewModel,
        onBack: @escaping () -> Void,
        onSelectAssignment: @escaping (Assignment) -> Void
    ) {
        self.course = course
        self.user = user
        self.viewModel = viewModel
        self.onBack = onBack
        self.onSelectAssignment = onSelectAssignment
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Course Navigation Bar
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .frame(width: 44, height: 44)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(course.fullname)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .lineLimit(1)

                    Text(course.shortname)
                        .font(.system(size: 11))
                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                }

                Spacer()

                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 8)
            .frame(height: 54)
            .background(GoogleClassroomTheme.background)

            Divider()

            // Active Tab Content
            Group {
                switch viewModel.activeTab {
                case .stream:
                    StreamTabView(
                        course: course,
                        user: user,
                        announcements: viewModel.announcementsByCourse[course.id] ?? [],
                        assignments: viewModel.assignments(for: course.id),
                        onSelectAssignment: onSelectAssignment,
                        onAddComment: { annId, text in
                            viewModel.addClassComment(
                                courseId: course.id,
                                announcementId: annId,
                                author: user?.fullname ?? "Alumno",
                                text: text
                            )
                        }
                    )
                case .classwork:
                    ClassworkTabView(
                        course: course,
                        topics: viewModel.topicsByCourse[course.id] ?? [],
                        assignments: viewModel.assignments(for: course.id),
                        onSelectAssignment: onSelectAssignment
                    )
                case .people:
                    PeopleTabView(course: course)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // Google Classroom Bottom Navigation Bar
            HStack {
                ForEach(ClassroomTab.allCases) { tab in
                    Button(action: {
                        viewModel.activeTab = tab
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(viewModel.activeTab == tab ? course.bannerColor : GoogleClassroomTheme.textSecondary)

                            Text(tab.rawValue)
                                .font(.system(size: 11, weight: viewModel.activeTab == tab ? .semibold : .regular))
                                .foregroundColor(viewModel.activeTab == tab ? course.bannerColor : GoogleClassroomTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(GoogleClassroomTheme.background)
        }
        .background(GoogleClassroomTheme.secondaryBackground)
    }
}
