import SwiftUI

public struct ClassworkTabView: View {
    public let course: Course
    public let topics: [Topic]
    public let assignments: [Assignment]
    public let onSelectAssignment: (Assignment) -> Void

    @State private var selectedTopicFilter: String? = nil

    public init(
        course: Course,
        topics: [Topic],
        assignments: [Assignment],
        onSelectAssignment: @escaping (Assignment) -> Void
    ) {
        self.course = course
        self.topics = topics
        self.assignments = assignments
        self.onSelectAssignment = onSelectAssignment
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Topic Filter Chips Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    topicChip(title: "Todos los temas", isSelected: selectedTopicFilter == nil) {
                        selectedTopicFilter = nil
                    }

                    ForEach(topics) { topic in
                        topicChip(title: topic.name, isSelected: selectedTopicFilter == topic.name) {
                            selectedTopicFilter = topic.name
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(GoogleClassroomTheme.background)

            Divider()

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 24) {
                    let filteredTopics = topics.filter { topic in
                        selectedTopicFilter == nil || topic.name == selectedTopicFilter
                    }

                    if filteredTopics.isEmpty && assignments.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "folder")
                                .font(.system(size: 48))
                                .foregroundColor(GoogleClassroomTheme.textTertiary)
                            Text("No hay tareas asignadas en este módulo")
                                .font(.system(size: 15))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        // Display by topic
                        ForEach(filteredTopics) { topic in
                            let topicAssignments = assignments.filter { $0.topicName == topic.name }
                            if !topicAssignments.isEmpty || !topic.assignments.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    // Topic Section Title
                                    Text(topic.name)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(course.bannerColor)
                                        .padding(.horizontal, 16)

                                    Divider()
                                        .padding(.horizontal, 16)

                                    // Topic Tasks
                                    let list = topicAssignments.isEmpty ? topic.assignments : topicAssignments
                                    ForEach(list) { assignment in
                                        AssignmentRowView(
                                            assignment: assignment,
                                            themeColor: course.bannerColor
                                        ) {
                                            onSelectAssignment(assignment)
                                        }
                                        Divider()
                                            .padding(.leading, 72)
                                    }
                                }
                            }
                        }

                        // Assignments without explicit topic or general
                        let generalAssignments = assignments.filter { assign in
                            guard let topicName = assign.topicName else { return true }
                            return !topics.contains(where: { t in t.name == topicName })
                        }
                        if selectedTopicFilter == nil && !generalAssignments.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("General")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(course.bannerColor)
                                    .padding(.horizontal, 16)

                                Divider()
                                    .padding(.horizontal, 16)

                                ForEach(generalAssignments) { assignment in
                                    AssignmentRowView(
                                        assignment: assignment,
                                        themeColor: course.bannerColor
                                    ) {
                                        onSelectAssignment(assignment)
                                    }
                                    Divider()
                                        .padding(.leading, 72)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 60)
            }
            .background(GoogleClassroomTheme.background)
        }
    }

    private func topicChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? course.bannerColor : GoogleClassroomTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? course.bannerColor.opacity(0.12) : Color.clear)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected ? course.bannerColor : GoogleClassroomTheme.cardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
