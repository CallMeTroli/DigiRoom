import SwiftUI

public struct StreamTabView: View {
    public let course: Course
    public let user: User?
    public let announcements: [Announcement]
    public let assignments: [Assignment]
    public let onSelectAssignment: (Assignment) -> Void
    public let onAddComment: (Int, String) -> Void

    @State private var newCommentTexts: [Int: String] = [:]
    @State private var shareText: String = ""
    @State private var isSharing: Bool = false

    public init(
        course: Course,
        user: User?,
        announcements: [Announcement],
        assignments: [Assignment],
        onSelectAssignment: @escaping (Assignment) -> Void,
        onAddComment: @escaping (Int, String) -> Void
    ) {
        self.course = course
        self.user = user
        self.announcements = announcements
        self.assignments = assignments
        self.onSelectAssignment = onSelectAssignment
        self.onAddComment = onAddComment
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                // Course Header Card
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(course.bannerColor)
                        .frame(height: 120)

                    LinearGradient(
                        colors: [Color.black.opacity(0.2), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 120)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(course.fullname)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        Text(course.teacherName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(16)
                }
                .clipShape(RoundedRectangle(cornerRadius: GoogleClassroomTheme.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: GoogleClassroomTheme.cardCornerRadius)
                        .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                )

                // Announcement Composer Box
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        UserAvatarView(user: user, size: 36)

                        Text("Comparte algo con tu clase...")
                            .font(.system(size: 14))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)

                        Spacer()
                    }
                    .padding(16)
                    .background(GoogleClassroomTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: GoogleClassroomTheme.cardCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: GoogleClassroomTheme.cardCornerRadius)
                            .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                }

                // Recent assignments in Stream
                ForEach(assignments.prefix(2)) { assignment in
                    Button(action: { onSelectAssignment(assignment) }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(course.bannerColor)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(course.teacherName) ha publicado una nueva tarea: \(assignment.name)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(GoogleClassroomTheme.textPrimary)
                                    .multilineTextAlignment(.leading)

                                Text(assignment.formattedDueDate)
                                    .font(.system(size: 12))
                                    .foregroundColor(GoogleClassroomTheme.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(GoogleClassroomTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: GoogleClassroomTheme.cardCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: GoogleClassroomTheme.cardCornerRadius)
                                .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Announcements Feed
                ForEach(announcements) { announcement in
                    VStack(alignment: .leading, spacing: 12) {
                        // Header
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(course.bannerColor)
                                    .frame(width: 36, height: 36)
                                Text(announcement.authorName.prefix(1))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(announcement.authorName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(GoogleClassroomTheme.textPrimary)

                                Text(announcement.formattedDate)
                                    .font(.system(size: 12))
                                    .foregroundColor(GoogleClassroomTheme.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "ellipsis")
                                .font(.system(size: 16))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                        }

                        // Content
                        Text(announcement.content)
                            .font(.system(size: 14))
                            .foregroundColor(GoogleClassroomTheme.textPrimary)
                            .lineSpacing(3)

                        Divider()

                        // Comments
                        if !announcement.comments.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(announcement.comments) { comment in
                                    HStack(alignment: .top, spacing: 10) {
                                        Circle()
                                            .fill(Color(hex: "#BDC1C6"))
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Text(comment.authorName.prefix(1))
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.white)
                                            )

                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 6) {
                                                Text(comment.authorName)
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(GoogleClassroomTheme.textPrimary)
                                            }
                                            Text(comment.text)
                                                .font(.system(size: 13))
                                                .foregroundColor(GoogleClassroomTheme.textPrimary)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        // Add comment input
                        HStack(spacing: 10) {
                            TextField(
                                "Añadir un comentario de clase...",
                                text: Binding(
                                    get: { newCommentTexts[announcement.id] ?? "" },
                                    set: { newCommentTexts[announcement.id] = $0 }
                                )
                            )
                            .font(.system(size: 13))

                            let text = newCommentTexts[announcement.id] ?? ""
                            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Button(action: {
                                    onAddComment(announcement.id, text)
                                    newCommentTexts[announcement.id] = ""
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(GoogleClassroomTheme.blue)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(GoogleClassroomTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: GoogleClassroomTheme.cardCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: GoogleClassroomTheme.cardCornerRadius)
                            .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                    )
                }
            }
            .padding(16)
            .padding(.bottom, 60)
        }
        .background(GoogleClassroomTheme.secondaryBackground)
    }
}
