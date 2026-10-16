import SwiftUI

public struct AssignmentDetailView: View {
    public let assignment: Assignment
    public let user: User?
    public let themeColor: Color
    public let onBack: () -> Void
    public let onToggleSubmission: () -> Void
    public let onAddPrivateComment: (String) -> Void

    @State private var privateCommentText: String = ""
    @State private var isWorkSheetExpanded: Bool = true
    @State private var showAttachmentAlert: Bool = false

    public init(
        assignment: Assignment,
        user: User?,
        themeColor: Color = GoogleClassroomTheme.blue,
        onBack: @escaping () -> Void,
        onToggleSubmission: @escaping () -> Void,
        onAddPrivateComment: @escaping (String) -> Void
    ) {
        self.assignment = assignment
        self.user = user
        self.themeColor = themeColor
        self.onBack = onBack
        self.onToggleSubmission = onToggleSubmission
        self.onAddPrivateComment = onAddPrivateComment
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .frame(width: 44, height: 44)
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

            // Main Scroll Area
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(assignment.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)

                    // Points & Deadline
                    HStack(spacing: 12) {
                        Text("\(assignment.maxPoints) puntos")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)

                        Text("•")
                            .foregroundColor(GoogleClassroomTheme.textTertiary)

                        Text(assignment.formattedDueDate)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)
                    }

                    Divider()

                    // Instructions
                    if !assignment.intro.isEmpty {
                        Text(assignment.intro)
                            .font(.system(size: 15))
                            .foregroundColor(GoogleClassroomTheme.textPrimary)
                            .lineSpacing(4)
                    } else {
                        Text("Sin instrucciones adicionales para esta tarea.")
                            .font(.system(size: 14))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)
                            .italic()
                    }

                    // Attachments from teacher
                    if !assignment.attachments.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Archivos adjuntos")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)

                            ForEach(assignment.attachments) { att in
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(themeColor)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(att.title)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(GoogleClassroomTheme.textPrimary)
                                            .lineLimit(1)

                                        if let size = att.fileSize {
                                            Text(size)
                                                .font(.system(size: 11))
                                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                                        }
                                    }

                                    Spacer()

                                    Image(systemName: "arrow.down.circle")
                                        .font(.system(size: 18))
                                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                                }
                                .padding(12)
                                .background(GoogleClassroomTheme.secondaryBackground)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(20)
                .padding(.bottom, 220) // Space for bottom sheet
            }

            // Google Classroom "Tu trabajo" (Your work) Bottom Drawer
            VStack(spacing: 12) {
                // Header with chevron
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tu trabajo")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(GoogleClassroomTheme.textPrimary)
                    }

                    Spacer()

                    // Status Chip
                    Text(assignment.status.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(assignment.isSubmitted ? GoogleClassroomTheme.green : GoogleClassroomTheme.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            (assignment.isSubmitted ? GoogleClassroomTheme.green : GoogleClassroomTheme.blue).opacity(0.12)
                        )
                        .cornerRadius(12)
                }

                if assignment.isSubmitted {
                    // Submitted message
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(GoogleClassroomTheme.green)
                        Text("Tarea entregada correctamente en el campus")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(GoogleClassroomTheme.green)
                        Spacer()
                    }
                    .padding(.vertical, 4)

                    // Button: Anular entrega
                    Button(action: onToggleSubmission) {
                        Text("Anular entrega")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(GoogleClassroomTheme.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                            )
                    }
                } else {
                    // Button: Add Attachment
                    Button(action: { showAttachmentAlert = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Añadir archivo o enlace")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(GoogleClassroomTheme.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                        )
                    }

                    // Button: Submit
                    Button(action: onToggleSubmission) {
                        Text("Marcar como completada")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(themeColor)
                            .cornerRadius(8)
                    }
                }

                // Private comments section
                Divider()
                    .padding(.vertical, 2)

                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(GoogleClassroomTheme.textTertiary)
                    Text("Comentarios privados")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                    Spacer()
                }

                if !assignment.privateComments.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(assignment.privateComments) { comment in
                            HStack(alignment: .top, spacing: 8) {
                                Text(comment.authorName)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(GoogleClassroomTheme.textPrimary)
                                Text(comment.text)
                                    .font(.system(size: 12))
                                    .foregroundColor(GoogleClassroomTheme.textSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Private comment field
                HStack(spacing: 10) {
                    TextField("Añadir comentario para el profesor...", text: $privateCommentText)
                        .font(.system(size: 13))

                    if !privateCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button(action: {
                            onAddPrivateComment(privateCommentText)
                            privateCommentText = ""
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 14))
                                .foregroundColor(themeColor)
                        }
                    }
                }
            }
            .padding(16)
            .background(GoogleClassroomTheme.background)
            .cornerRadius(16, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: -2)
        }
        .background(GoogleClassroomTheme.background)
        .alert("Añadir entrega", isPresented: $showAttachmentAlert) {
            Button("Seleccionar archivo") {}
            Button("Enlace de Google Drive / GitHub") {}
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Puedes subir tu fichero de entrega para enviarlo a https://campus.digitechfp.com.")
        }
    }
}

// Rounded corners helper
extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
