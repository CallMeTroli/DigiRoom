import SwiftUI

public struct UserProfileSheet: View {
    public let user: User?
    public let onLogout: () -> Void
    public let onClose: () -> Void

    public init(user: User?, onLogout: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.user = user
        self.onLogout = onLogout
        self.onClose = onClose
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Close header
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                        .padding(8)
                }
            }

            // Avatar & Name
            VStack(spacing: 12) {
                UserAvatarView(user: user, size: 72)

                VStack(spacing: 4) {
                    Text(user?.fullname ?? "Estudiante")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)

                    Text(user?.username ?? "campus@digitechfp.com")
                        .font(.system(size: 14))
                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                }

                // Digitech Badge
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundColor(GoogleClassroomTheme.green)
                    Text("Campus Oficial Digitech FP")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(GoogleClassroomTheme.green)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(GoogleClassroomTheme.green.opacity(0.12))
                .cornerRadius(12)
            }

            Divider()

            // Server Info
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "server.rack")
                        .foregroundColor(GoogleClassroomTheme.blue)
                    Text("Servidor Campus Moodle:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                    Spacer()
                    Text("campus.digitechfp.com")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(GoogleClassroomTheme.textPrimary)
                }

                HStack {
                    Image(systemName: "key.fill")
                        .foregroundColor(GoogleClassroomTheme.orange)
                    Text("Estado de sesión:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(GoogleClassroomTheme.textSecondary)
                    Spacer()
                    Text(user?.isDemo == true ? "Modo Demo" : "Ficha REST activa")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(user?.isDemo == true ? GoogleClassroomTheme.orange : GoogleClassroomTheme.green)
                }
            }
            .padding(14)
            .background(GoogleClassroomTheme.secondaryBackground)
            .cornerRadius(8)

            Spacer()

            // Logout Button
            Button(action: onLogout) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 16))
                    Text("Cerrar sesión en este dispositivo")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(GoogleClassroomTheme.red)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(GoogleClassroomTheme.red.opacity(0.4), lineWidth: 1)
                )
            }
        }
        .padding(24)
        .background(GoogleClassroomTheme.background)
    }
}
