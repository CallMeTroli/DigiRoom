import SwiftUI

public struct CoursesListView: View {
    @ObservedObject public var viewModel: ClassroomViewModel
    public let user: User?
    public let onSelectCourse: (Course) -> Void

    public init(
        viewModel: ClassroomViewModel,
        user: User?,
        onSelectCourse: @escaping (Course) -> Void
    ) {
        self.viewModel = viewModel
        self.user = user
        self.onSelectCourse = onSelectCourse
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading && viewModel.courses.isEmpty {
                    ProgressView()
                        .padding(.top, 40)
                } else if viewModel.courses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "graduationcap")
                            .font(.system(size: 64))
                            .foregroundColor(GoogleClassroomTheme.textTertiary)
                        Text("No tienes cursos matriculados en el campus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(viewModel.courses) { course in
                        CourseCardView(course: course) {
                            onSelectCourse(course)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(GoogleClassroomTheme.secondaryBackground)
        .refreshable {
            if let user = user {
                await viewModel.loadData(for: user)
            }
        }
    }
}
