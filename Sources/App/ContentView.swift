import SwiftUI

public struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var classroomViewModel = ClassroomViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            if authViewModel.isAuthenticated {
                mainClassroomContainer
            } else {
                LoginView(viewModel: authViewModel) {
                    if let user = authViewModel.currentUser {
                        Task {
                            await classroomViewModel.loadData(for: user)
                            await notificationViewModel.applyToAssignments(classroomViewModel.allAssignments)
                        }
                    }
                }
            }
        }
        .onAppear {
            if let user = authViewModel.currentUser {
                Task {
                    await classroomViewModel.loadData(for: user)
                    await notificationViewModel.applyToAssignments(classroomViewModel.allAssignments)
                }
            }
        }
    }

    // MARK: - Authenticated Classroom View
    private var mainClassroomContainer: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                // Main Screen Content
                if classroomViewModel.showTodoList {
                    TodoListView(
                        viewModel: classroomViewModel,
                        onBack: { classroomViewModel.showTodoList = false },
                        onSelectAssignment: { assignment in
                            classroomViewModel.selectedAssignment = assignment
                        }
                    )
                } else if classroomViewModel.showNotificationSettings {
                    NotificationSettingsView(
                        viewModel: notificationViewModel,
                        courses: classroomViewModel.courses,
                        assignments: classroomViewModel.allAssignments,
                        onBack: { classroomViewModel.showNotificationSettings = false }
                    )
                } else if let selectedCourse = classroomViewModel.selectedCourse {
                    CourseDetailView(
                        course: selectedCourse,
                        user: authViewModel.currentUser,
                        viewModel: classroomViewModel,
                        onBack: {
                            classroomViewModel.selectedCourse = nil
                        },
                        onSelectAssignment: { assignment in
                            classroomViewModel.selectedAssignment = assignment
                        }
                    )
                } else {
                    // Home Screen: TopBar + Courses Stream
                    VStack(spacing: 0) {
                        ClassroomTopBar(
                            user: authViewModel.currentUser,
                            title: "Google Classroom",
                            subtitle: "Digitech FP Oficial",
                            showBackButton: false,
                            onMenuTapped: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    classroomViewModel.isSideDrawerOpen = true
                                }
                            },
                            onAvatarTapped: {
                                classroomViewModel.showProfileSheet = true
                            }
                        )

                        CoursesListView(
                            viewModel: classroomViewModel,
                            user: authViewModel.currentUser,
                            onSelectCourse: { course in
                                classroomViewModel.selectCourse(course)
                            }
                        )
                    }
                }
            }

            // Google Classroom Side Drawer
            SideDrawerView(
                isOpen: $classroomViewModel.isSideDrawerOpen,
                user: authViewModel.currentUser,
                courses: classroomViewModel.courses,
                onSelectCourse: { course in
                    classroomViewModel.showTodoList = false
                    classroomViewModel.showNotificationSettings = false
                    classroomViewModel.selectCourse(course)
                },
                onSelectClasses: {
                    classroomViewModel.selectedCourse = nil
                    classroomViewModel.showTodoList = false
                    classroomViewModel.showNotificationSettings = false
                },
                onSelectTodoList: {
                    classroomViewModel.showNotificationSettings = false
                    classroomViewModel.showTodoList = true
                },
                onSelectNotifications: {
                    classroomViewModel.showTodoList = false
                    classroomViewModel.showNotificationSettings = true
                },
                onLogout: {
                    authViewModel.logout()
                    classroomViewModel.selectedCourse = nil
                    classroomViewModel.showTodoList = false
                    classroomViewModel.showNotificationSettings = false
                }
            )
        }
        // Assignment Detail Sheet
        .sheet(item: $classroomViewModel.selectedAssignment) { assignment in
            let courseColor = classroomViewModel.courses.first(where: { $0.id == assignment.courseId })?.bannerColor ?? GoogleClassroomTheme.blue

            AssignmentDetailView(
                assignment: assignment,
                user: authViewModel.currentUser,
                themeColor: courseColor,
                onBack: {
                    classroomViewModel.selectedAssignment = nil
                },
                onToggleSubmission: {
                    classroomViewModel.toggleSubmission(for: assignment.id)
                    Task {
                        await notificationViewModel.applyToAssignments(classroomViewModel.allAssignments)
                    }
                },
                onAddPrivateComment: { text in
                    classroomViewModel.addPrivateComment(
                        assignmentId: assignment.id,
                        author: authViewModel.currentUser?.fullname ?? "Alumno",
                        text: text
                    )
                }
            )
        }
        // User Profile Sheet
        .sheet(isPresented: $classroomViewModel.showProfileSheet) {
            UserProfileSheet(
                user: authViewModel.currentUser,
                onLogout: {
                    classroomViewModel.showProfileSheet = false
                    authViewModel.logout()
                    classroomViewModel.selectedCourse = nil
                },
                onClose: {
                    classroomViewModel.showProfileSheet = false
                }
            )
        }
    }
}
