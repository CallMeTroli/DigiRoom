import SwiftUI

public struct LoginView: View {
    @ObservedObject public var viewModel: AuthViewModel
    public let onLoginSuccess: () -> Void

    @State private var isPasswordVisible: Bool = false

    public init(viewModel: AuthViewModel, onLoginSuccess: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onLoginSuccess = onLoginSuccess
    }

    public var body: some View {
        ZStack {
            GoogleClassroomTheme.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header Brand
                    VStack(spacing: 12) {
                        // Google Classroom / Digitech Icon
                        ZStack {
                            Circle()
                                .fill(GoogleClassroomTheme.blue.opacity(0.12))
                                .frame(width: 80, height: 80)

                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 40))
                                .foregroundColor(GoogleClassroomTheme.blue)
                        }
                        .padding(.top, 40)

                        VStack(spacing: 4) {
                            Text("Google Classroom")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(GoogleClassroomTheme.textPrimary)

                            Text("Digitech Campus Virtual")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(GoogleClassroomTheme.green)

                            HStack(spacing: 4) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(GoogleClassroomTheme.textTertiary)
                                Text("https://campus.digitechfp.com")
                                    .font(.system(size: 12))
                                    .foregroundColor(GoogleClassroomTheme.textSecondary)
                            }
                            .padding(.top, 2)
                        }
                    }

                    // Login Card
                    VStack(spacing: 20) {
                        Text("Inicia sesión con tu cuenta")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(GoogleClassroomTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Error message if any
                        if let error = viewModel.errorMessage {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(GoogleClassroomTheme.red)

                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(GoogleClassroomTheme.red)
                                    .multilineTextAlignment(.leading)

                                Spacer()
                            }
                            .padding(12)
                            .background(GoogleClassroomTheme.red.opacity(0.1))
                            .cornerRadius(8)
                        }

                        // Username field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Nombre de usuario")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)

                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(GoogleClassroomTheme.textTertiary)
                                    .frame(width: 24)

                                TextField("Usuario del campus", text: $viewModel.username)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .font(.system(size: 15))
                            }
                            .padding(12)
                            .background(GoogleClassroomTheme.secondaryBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                            )
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Contraseña")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(GoogleClassroomTheme.textSecondary)

                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(GoogleClassroomTheme.textTertiary)
                                    .frame(width: 24)

                                if isPasswordVisible {
                                    TextField("Contraseña", text: $viewModel.password)
                                        .font(.system(size: 15))
                                } else {
                                    SecureField("Contraseña", text: $viewModel.password)
                                        .font(.system(size: 15))
                                }

                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 15))
                                        .foregroundColor(GoogleClassroomTheme.textTertiary)
                                }
                            }
                            .padding(12)
                            .background(GoogleClassroomTheme.secondaryBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                            )
                        }

                        // Remember username
                        Toggle(isOn: $viewModel.rememberUsername) {
                            Text("Recordar mi usuario")
                                .font(.system(size: 14))
                                .foregroundColor(GoogleClassroomTheme.textPrimary)
                        }
                        .tint(GoogleClassroomTheme.blue)

                        // Submit Button
                        Button(action: {
                            Task {
                                await viewModel.login()
                                if viewModel.isAuthenticated {
                                    onLoginSuccess()
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Acceder al Campus")
                                        .font(.system(size: 16, weight: .semibold))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(GoogleClassroomTheme.blue)
                            .cornerRadius(8)
                        }
                        .disabled(viewModel.isLoading)

                        // Divider
                        HStack {
                            Rectangle().fill(GoogleClassroomTheme.divider).frame(height: 1)
                            Text("o bien")
                                .font(.system(size: 12))
                                .foregroundColor(GoogleClassroomTheme.textTertiary)
                                .padding(.horizontal, 8)
                            Rectangle().fill(GoogleClassroomTheme.divider).frame(height: 1)
                        }
                        .padding(.vertical, 4)

                        // Demo Mode Button
                        Button(action: {
                            viewModel.loginDemo()
                            onLoginSuccess()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(GoogleClassroomTheme.green)
                                Text("Entrar en Modo Demo / Vista Previa")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(GoogleClassroomTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(GoogleClassroomTheme.secondaryBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                            )
                        }
                    }
                    .padding(24)
                    .background(GoogleClassroomTheme.background)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(GoogleClassroomTheme.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, 20)

                    // Footer notice
                    VStack(spacing: 4) {
                        Text("Acceso oficial para alumnos de Digitech FP")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(GoogleClassroomTheme.textSecondary)

                        Text("Servicios Web Moodle (moodle_mobile_app) sincronizados con tu expediente.")
                            .font(.system(size: 11))
                            .foregroundColor(GoogleClassroomTheme.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
