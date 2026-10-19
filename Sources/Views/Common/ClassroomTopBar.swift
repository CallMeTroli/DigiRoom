import SwiftUI

public struct ClassroomTopBar: View {
    public let user: User?
    public let title: String
    public let subtitle: String?
    public let showBackButton: Bool
    public let unreadChatCount: Int
    public let onMenuTapped: () -> Void
    public let onBackTapped: () -> Void
    public let onChatTapped: (() -> Void)?
    public let onAvatarTapped: () -> Void

    public init(
        user: User?,
        title: String = "Google Classroom",
        subtitle: String? = nil,
        showBackButton: Bool = false,
        unreadChatCount: Int = 0,
        onMenuTapped: @escaping () -> Void = {},
        onBackTapped: @escaping () -> Void = {},
        onChatTapped: (() -> Void)? = nil,
        onAvatarTapped: @escaping () -> Void = {}
    ) {
        self.user = user
        self.title = title
        self.subtitle = subtitle
        self.showBackButton = showBackButton
        self.unreadChatCount = unreadChatCount
        self.onMenuTapped = onMenuTapped
        self.onBackTapped = onBackTapped
        self.onChatTapped = onChatTapped
        self.onAvatarTapped = onAvatarTapped
    }

    public var body: some View {
        HStack(spacing: 12) {
            if showBackButton {
                Button(action: onBackTapped) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .frame(width: 44, height: 44)
                }
            } else {
                Button(action: onMenuTapped) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .frame(width: 44, height: 44)
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    if !showBackButton {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 16))
                            .foregroundColor(GoogleClassroomTheme.green)
                    }
                    Text(title)
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                        .lineLimit(1)
                }

                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let onChatTapped = onChatTapped {
                Button(action: onChatTapped) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(GoogleClassroomTheme.textPrimary)
                            .frame(width: 38, height: 38)

                        if unreadChatCount > 0 {
                            Text("\(unreadChatCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1.5)
                                .background(GoogleClassroomTheme.blue)
                                .clipShape(Capsule())
                                .offset(x: 4, y: 2)
                        }
                    }
                }
            }

            Button(action: onAvatarTapped) {
                UserAvatarView(user: user, size: 34)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 56)
        .background(GoogleClassroomTheme.background)
        .overlay(
            Rectangle()
                .fill(GoogleClassroomTheme.divider)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

