import SwiftUI

public struct CourseCardView: View {
    public let course: Course
    public let onSelect: () -> Void

    public init(course: Course, onSelect: @escaping () -> Void) {
        self.course = course
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Top Banner with course color
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(course.bannerColor)
                        .frame(height: 135)

                    // Subtle background geometric art / gradient
                    LinearGradient(
                        colors: [Color.black.opacity(0.15), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 135)

                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top) {
                            Text(course.fullname)
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                        }

                        Text(course.teacherName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.92))
                            .lineLimit(1)

                        Spacer()

                        if let progress = course.progress {
                            HStack(spacing: 8) {
                                ProgressView(value: progress)
                                    .tint(.white)
                                    .scaleEffect(x: 1, y: 0.8, anchor: .center)
                                Text("\(Int(progress * 100))%")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.bottom, 6)
                        }
                    }
                    .padding(16)
                }

                // Card Body
                VStack(alignment: .leading, spacing: 8) {
                    if let nextTask = course.assignmentsDueSoon.first(where: { !$0.isSubmitted }) {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 16))
                                .foregroundColor(GoogleClassroomTheme.orange)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(nextTask.formattedDueDate)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(GoogleClassroomTheme.textPrimary)

                                Text(nextTask.name)
                                    .font(.system(size: 13))
                                    .foregroundColor(GoogleClassroomTheme.textSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(GoogleClassroomTheme.green)

                            Text("No hay tareas pendientes esta semana")
                                .font(.system(size: 13))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }

                    Divider()

                    // Card Footer / Actions
                    HStack {
                        Spacer()
                        Image(systemName: "folder")
                            .font(.system(size: 16))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)
                            .frame(width: 36, height: 36)

                        Image(systemName: "tray.full")
                            .font(.system(size: 16))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)
                            .frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
                }
                .background(GoogleClassroomTheme.background)
            }
            .clipShape(RoundedRectangle(cornerRadius: GoogleClassroomTheme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: GoogleClassroomTheme.cardCornerRadius)
                    .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
