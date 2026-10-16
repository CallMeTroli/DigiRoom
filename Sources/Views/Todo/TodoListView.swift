import SwiftUI

public struct TodoListView: View {
    @ObservedObject public var viewModel: ClassroomViewModel
    public let onBack: () -> Void
    public let onSelectAssignment: (Assignment) -> Void

    @State private var activeTab: TodoTab = .assigned

    public init(
        viewModel: ClassroomViewModel,
        onBack: @escaping () -> Void,
        onSelectAssignment: @escaping (Assignment) -> Void
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onSelectAssignment = onSelectAssignment
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .frame(width: 44, height: 44)
                }

                Text("Tareas pendientes")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(GoogleClassroomTheme.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 8)
            .frame(height: 54)
            .background(GoogleClassroomTheme.background)

            // Tabs
            HStack(spacing: 0) {
                ForEach(TodoTab.allCases) { tab in
                    Button(action: { activeTab = tab }) {
                        VStack(spacing: 8) {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: activeTab == tab ? .semibold : .medium))
                                .foregroundColor(activeTab == tab ? GoogleClassroomTheme.blue : GoogleClassroomTheme.textSecondary)

                            Rectangle()
                                .fill(activeTab == tab ? GoogleClassroomTheme.blue : Color.clear)
                                .frame(height: 2.5)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(GoogleClassroomTheme.background)

            Divider()

            // List
            let assignments = viewModel.todoAssignments(for: activeTab)
            ScrollView(.vertical, showsIndicators: false) {
                if assignments.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 54))
                            .foregroundColor(GoogleClassroomTheme.green)
                        Text(emptyMessage(for: activeTab))
                            .font(.system(size: 15))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(assignments) { assignment in
                            let courseColor = viewModel.courses.first(where: { $0.id == assignment.courseId })?.bannerColor ?? GoogleClassroomTheme.blue

                            AssignmentRowView(
                                assignment: assignment,
                                themeColor: courseColor
                            ) {
                                onSelectAssignment(assignment)
                            }
                            Divider()
                                .padding(.leading, 72)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .background(GoogleClassroomTheme.background)
        }
    }

    private func emptyMessage(for tab: TodoTab) -> String {
        switch tab {
        case .assigned: return "¡Genial! No tienes tareas asignadas pendientes"
        case .missing: return "No tienes ninguna tarea sin entregar atrasada"
        case .completed: return "Aún no has completado ninguna tarea"
        }
    }
}
