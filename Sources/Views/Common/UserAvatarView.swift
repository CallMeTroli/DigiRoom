import SwiftUI

public struct UserAvatarView: View {
    public let user: User?
    public let size: CGFloat

    public init(user: User?, size: CGFloat = 36) {
        self.user = user
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(GoogleClassroomTheme.blue)
                .frame(width: size, height: size)

            Text(user?.initials ?? "U")
                .font(.system(size: size * 0.44, weight: .bold))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}
