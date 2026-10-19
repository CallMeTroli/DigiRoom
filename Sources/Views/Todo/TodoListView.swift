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

// MARK: - Moodle Chat Filter
public enum MoodleChatFilter: String, CaseIterable, Identifiable {
    case all = "Todos"
    case unread = "No leídos"
    case groups = "Grupos"

    public var id: String { rawValue }
}

// MARK: - Moodle Chat List View
public struct MoodleChatListView: View {
    @ObservedObject public var viewModel: ClassroomViewModel
    public let user: User?
    public let onBack: () -> Void

    @State private var searchText: String = ""
    @State private var selectedFilter: MoodleChatFilter = .all

    public init(
        viewModel: ClassroomViewModel,
        user: User?,
        onBack: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.user = user
        self.onBack = onBack
    }

    private var filteredConversations: [MoodleConversation] {
        viewModel.conversations.filter { conv in
            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .unread:
                matchesFilter = conv.unreadCount > 0
            case .groups:
                matchesFilter = conv.isGroup
            }

            let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedSearch.isEmpty {
                return matchesFilter
            }
            return matchesFilter && (
                conv.name.localizedCaseInsensitiveContains(trimmedSearch) ||
                conv.subtitle.localizedCaseInsensitiveContains(trimmedSearch) ||
                conv.lastMessageText.localizedCaseInsensitiveContains(trimmedSearch)
            )
        }
    }

    public var body: some View {
        if let activeConv = viewModel.selectedConversation {
            MoodleChatDetailView(
                conversation: activeConv,
                viewModel: viewModel,
                user: user,
                onBack: {
                    viewModel.selectedConversation = nil
                }
            )
        } else {
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(GoogleClassroomTheme.textPrimary)
                            .frame(width: 44, height: 44)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 15))
                                .foregroundColor(GoogleClassroomTheme.blue)

                            Text("Chats de Moodle")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(GoogleClassroomTheme.textPrimary)
                        }

                        Text("Mensajería conectada con campus.digitechfp.com")
                            .font(.system(size: 11))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: {
                        Task {
                            await viewModel.refreshConversations(for: user)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(GoogleClassroomTheme.blue)
                            .frame(width: 38, height: 38)
                            .background(GoogleClassroomTheme.chipBackground)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: 58)
                .background(GoogleClassroomTheme.background)

                Divider()

                // Search & Filter Bar
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(GoogleClassroomTheme.textSecondary)
                            .font(.system(size: 15))

                        TextField("Buscar profesores, grupos o mensajes...", text: $searchText)
                            .font(.system(size: 14))
                            .foregroundColor(GoogleClassroomTheme.textPrimary)

                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(GoogleClassroomTheme.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(GoogleClassroomTheme.secondaryBackground)
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                    )

                    HStack(spacing: 8) {
                        ForEach(MoodleChatFilter.allCases) { filter in
                            let isSelected = selectedFilter == filter
                            Button(action: { selectedFilter = filter }) {
                                HStack(spacing: 5) {
                                    Text(filter.rawValue)
                                        .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                                    if filter == .unread && viewModel.totalUnreadChatCount > 0 {
                                        Text("\(viewModel.totalUnreadChatCount)")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(isSelected ? .white : GoogleClassroomTheme.blue)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(isSelected ? GoogleClassroomTheme.blue.opacity(0.3) : GoogleClassroomTheme.chipBackground)
                                            .clipShape(Capsule())
                                    }
                                }
                                .foregroundColor(isSelected ? GoogleClassroomTheme.chipText : GoogleClassroomTheme.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(isSelected ? GoogleClassroomTheme.chipBackground : GoogleClassroomTheme.secondaryBackground)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(GoogleClassroomTheme.background)

                Divider()

                // Conversation List
                ScrollView(.vertical, showsIndicators: false) {
                    if filteredConversations.isEmpty {
                        VStack(spacing: 14) {
                            Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                                .font(.system(size: 46))
                                .foregroundColor(GoogleClassroomTheme.textTertiary)
                            Text("No se encontraron conversaciones en Moodle")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 64)
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredConversations) { conversation in
                                Button(action: {
                                    Task {
                                        await viewModel.openConversation(conversation, user: user)
                                    }
                                }) {
                                    HStack(spacing: 14) {
                                        // Avatar with online indicator
                                        ZStack(alignment: .bottomTrailing) {
                                            Circle()
                                                .fill(Color(hex: conversation.themeColorHex))
                                                .frame(width: 48, height: 48)
                                                .overlay(
                                                    Group {
                                                        if conversation.isGroup {
                                                            Image(systemName: "person.3.fill")
                                                                .font(.system(size: 16, weight: .semibold))
                                                                .foregroundColor(.white)
                                                        } else {
                                                            Text(conversation.initials)
                                                                .font(.system(size: 16, weight: .bold))
                                                                .foregroundColor(.white)
                                                        }
                                                    }
                                                )

                                            if conversation.isOnline {
                                                Circle()
                                                    .fill(GoogleClassroomTheme.green)
                                                    .frame(width: 13, height: 13)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white, lineWidth: 2)
                                                    )
                                            }
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(conversation.name)
                                                    .font(.system(size: 15, weight: conversation.unreadCount > 0 ? .bold : .semibold))
                                                    .foregroundColor(GoogleClassroomTheme.textPrimary)
                                                    .lineLimit(1)

                                                Spacer()

                                                Text(conversation.lastMessageTimeFormatted)
                                                    .font(.system(size: 12, weight: conversation.unreadCount > 0 ? .semibold : .regular))
                                                    .foregroundColor(conversation.unreadCount > 0 ? GoogleClassroomTheme.blue : GoogleClassroomTheme.textTertiary)
                                            }

                                            Text(conversation.subtitle)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(Color(hex: conversation.themeColorHex))
                                                .lineLimit(1)

                                            HStack {
                                                Text(conversation.lastMessageText)
                                                    .font(.system(size: 13, weight: conversation.unreadCount > 0 ? .medium : .regular))
                                                    .foregroundColor(conversation.unreadCount > 0 ? GoogleClassroomTheme.textPrimary : GoogleClassroomTheme.textSecondary)
                                                    .lineLimit(1)

                                                Spacer()

                                                if conversation.unreadCount > 0 {
                                                    Text("\(conversation.unreadCount)")
                                                        .font(.system(size: 11, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .frame(minWidth: 20, minHeight: 20)
                                                        .padding(.horizontal, 5)
                                                        .background(GoogleClassroomTheme.blue)
                                                        .clipShape(Capsule())
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())

                                Divider()
                                    .padding(.leading, 78)
                            }
                        }
                    }
                }
                .background(GoogleClassroomTheme.background)
            }
        }
    }
}

// MARK: - Moodle Chat Detail View
public struct MoodleChatDetailView: View {
    public let conversation: MoodleConversation
    @ObservedObject public var viewModel: ClassroomViewModel
    public let user: User?
    public let onBack: () -> Void

    @State private var messageText: String = ""

    public init(
        conversation: MoodleConversation,
        viewModel: ClassroomViewModel,
        user: User?,
        onBack: @escaping () -> Void
    ) {
        self.conversation = conversation
        self.viewModel = viewModel
        self.user = user
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Conversation Header
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .frame(width: 40, height: 40)
                }

                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color(hex: conversation.themeColorHex))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Group {
                                if conversation.isGroup {
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                } else {
                                    Text(conversation.initials)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        )

                    if conversation.isOnline {
                        Circle()
                            .fill(GoogleClassroomTheme.green)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(conversation.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .lineLimit(1)

                    Text(conversation.isOnline ? "En línea • Moodle Digitech" : conversation.subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(conversation.isOnline ? GoogleClassroomTheme.green : GoogleClassroomTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 10)
            .frame(height: 58)
            .background(GoogleClassroomTheme.background)

            Divider()

            // Messages Stream
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        // Info Banner
                        HStack(spacing: 6) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 11))
                                .foregroundColor(GoogleClassroomTheme.blue)
                            Text("Chat sincronizado con Moodle (campus.digitechfp.com)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(GoogleClassroomTheme.chipBackground.opacity(0.6))
                        .clipShape(Capsule())
                        .padding(.top, 8)

                        ForEach(conversation.messages) { msg in
                            HStack(alignment: .bottom, spacing: 8) {
                                if msg.isFromCurrentUser {
                                    Spacer(minLength: 50)
                                }

                                VStack(alignment: msg.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                                    if conversation.isGroup && !msg.isFromCurrentUser {
                                        Text(msg.senderName)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(Color(hex: conversation.themeColorHex))
                                    }

                                    Text(msg.text)
                                        .font(.system(size: 14))
                                        .foregroundColor(msg.isFromCurrentUser ? .white : GoogleClassroomTheme.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(
                                            msg.isFromCurrentUser
                                                ? GoogleClassroomTheme.blue
                                                : GoogleClassroomTheme.background
                                        )
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    msg.isFromCurrentUser ? Color.clear : GoogleClassroomTheme.cardBorder,
                                                    lineWidth: 1
                                                )
                                        )

                                    Text(msg.formattedTime)
                                        .font(.system(size: 10))
                                        .foregroundColor(GoogleClassroomTheme.textTertiary)
                                        .padding(.horizontal, 4)
                                }

                                if !msg.isFromCurrentUser {
                                    Spacer(minLength: 50)
                                }
                            }
                            .id(msg.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(GoogleClassroomTheme.secondaryBackground)
                .onAppear {
                    if let lastId = conversation.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
                .onChange(of: conversation.messages.count) { _ in
                    if let lastId = conversation.messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Message Input Bar
            HStack(spacing: 10) {
                TextField("Escribe un mensaje en Moodle...", text: $messageText)
                    .font(.system(size: 14))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(GoogleClassroomTheme.secondaryBackground)
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                    )

                Button(action: sendCurrentMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? GoogleClassroomTheme.textTertiary.opacity(0.5)
                                : GoogleClassroomTheme.blue
                        )
                        .clipShape(Circle())
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSendingMessage)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(GoogleClassroomTheme.background)
        }
    }

    private func sendCurrentMessage() {
        let textToSend = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return }
        messageText = ""
        Task {
            await viewModel.sendMessage(text: textToSend, user: user)
        }
    }
}

