import SwiftUI

public struct AssignmentRowView: View {
    public let assignment: Assignment
    public let themeColor: Color
    public let onSelect: () -> Void

    public init(
        assignment: Assignment,
        themeColor: Color = GoogleClassroomTheme.blue,
        onSelect: @escaping () -> Void
    ) {
        self.assignment = assignment
        self.themeColor = themeColor
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Circular Classroom icon
                ZStack {
                    Circle()
                        .fill(assignment.isSubmitted ? Color(hex: "#80868B") : themeColor)
                        .frame(width: 40, height: 40)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }

                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(assignment.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        Text(assignment.formattedDueDate)
                            .font(.system(size: 12))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)

                        if let grade = assignment.grade {
                            Text("•")
                                .foregroundColor(GoogleClassroomTheme.textTertiary)
                            Text(grade)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(GoogleClassroomTheme.green)
                        }
                    }
                }

                Spacer()

                // Status chip
                if assignment.isSubmitted {
                    Text("Entregada")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(GoogleClassroomTheme.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(GoogleClassroomTheme.green.opacity(0.12))
                        .cornerRadius(12)
                } else if let due = assignment.dueDate, due < Date() {
                    Text("Sin entregar")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(GoogleClassroomTheme.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(GoogleClassroomTheme.red.opacity(0.12))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(GoogleClassroomTheme.background)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
