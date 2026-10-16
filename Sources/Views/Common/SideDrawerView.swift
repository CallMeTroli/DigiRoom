import SwiftUI

public struct SideDrawerView: View {
    @Binding public var isOpen: Bool
    public let user: User?
    public let courses: [Course]
    public let onSelectCourse: (Course) -> Void
    public let onSelectClasses: () -> Void
    public let onSelectTodoList: () -> Void
    public let onSelectNotifications: () -> Void
    public let onLogout: () -> Void

    public init(
        isOpen: Binding<Bool>,
        user: User?,
        courses: [Course],
        onSelectCourse: @escaping (Course) -> Void,
        onSelectClasses: @escaping () -> Void = {},
        onSelectTodoList: @escaping () -> Void,
        onSelectNotifications: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) {
        self._isOpen = isOpen
        self.user = user
        self.courses = courses
        self.onSelectCourse = onSelectCourse
        self.onSelectClasses = onSelectClasses
        self.onSelectTodoList = onSelectTodoList
        self.onSelectNotifications = onSelectNotifications
        self.onLogout = onLogout
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            if isOpen {
                // Dimmed backdrop
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isOpen = false
                        }
                    }

                // Drawer panel
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack(spacing: 12) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 26))
                            .foregroundColor(GoogleClassroomTheme.green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Google Classroom")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(GoogleClassroomTheme.textPrimary)

                            Text("Digitech Campus Virtual")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    .padding(.bottom, 20)

                    Divider()

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 4) {
                            // Primary Navigation
                            drawerItem(
                                icon: "house.fill",
                                title: "Clases",
                                isSelected: true
                            ) {
                                withAnimation { isOpen = false }
                                onSelectClasses()
                            }

                            drawerItem(
                                icon: "checklist",
                                title: "Tareas pendientes",
                                isSelected: false
                            ) {
                                withAnimation { isOpen = false }
                                onSelectTodoList()
                            }

                            drawerItem(
                                icon: "bell.badge.fill",
                                title: "Ajustes de notificaciones",
                                isSelected: false
                            ) {
                                withAnimation { isOpen = false }
                                onSelectNotifications()
                            }

                            Divider()
                                .padding(.vertical, 8)

                            // Enrolled Courses section
                            Text("CURSOS MATRICULADOS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(GoogleClassroomTheme.textTertiary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)

                            ForEach(courses) { course in
                                Button(action: {
                                    withAnimation { isOpen = false }
                                    onSelectCourse(course)
                                }) {
                                    HStack(spacing: 16) {
                                        Circle()
                                            .fill(course.bannerColor)
                                            .frame(width: 14, height: 14)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(course.fullname)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(GoogleClassroomTheme.textPrimary)
                                                .lineLimit(1)

                                            Text(course.teacherName)
                                                .font(.system(size: 12))
                                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                                                .lineLimit(1)
                                        }

                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }

                            Divider()
                                .padding(.vertical, 8)

                            // Logout
                            drawerItem(
                                icon: "arrow.right.square.fill",
                                title: "Cerrar sesión",
                                iconColor: GoogleClassroomTheme.red
                            ) {
                                withAnimation { isOpen = false }
                                onLogout()
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    Spacer()

                    // Footer branding
                    VStack(alignment: .leading, spacing: 4) {
                        Text("campus.digitechfp.com")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(GoogleClassroomTheme.textTertiary)
                        Text("Moodle Mobile Web Services API")
                            .font(.system(size: 10))
                            .foregroundColor(GoogleClassroomTheme.textTertiary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .frame(width: 300)
                .background(GoogleClassroomTheme.background)
                .ignoresSafeArea()
                .transition(.move(edge: .leading))
            }
        }
    }

    private func drawerItem(
        icon: String,
        title: String,
        isSelected: Bool = false,
        iconColor: Color? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor ?? (isSelected ? GoogleClassroomTheme.blue : GoogleClassroomTheme.textSecondary))
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? GoogleClassroomTheme.blue : GoogleClassroomTheme.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isSelected ? GoogleClassroomTheme.chipBackground : Color.clear)
            .cornerRadius(24)
            .padding(.horizontal, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
