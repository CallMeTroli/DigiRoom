import Foundation
import Combine

@MainActor
public final class AuthViewModel: ObservableObject {
    @Published public var currentUser: User?
    @Published public var isAuthenticated: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    @Published public var username: String = ""
    @Published public var password: String = ""
    @Published public var rememberUsername: Bool = true

    private let apiService = MoodleAPIService.shared
    private let storageService = StorageService.shared

    public init() {
        let (savedUser, remember) = storageService.getRememberedUsername()
        self.username = savedUser
        self.rememberUsername = remember

        if let user = storageService.loadUser() {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    public func login() async {
        let trimmedUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUser.isEmpty else {
            errorMessage = "Introduce tu nombre de usuario del campus"
            return
        }
        guard !trimmedPass.isEmpty else {
            errorMessage = "Introduce tu contraseña del campus"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await apiService.login(username: trimmedUser, password: trimmedPass)
            self.currentUser = user
            self.isAuthenticated = true
            self.storageService.saveUser(user)
            self.storageService.saveRememberUsername(trimmedUser, remember: rememberUsername)
            self.password = ""
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    public func loginDemo() {
        let demoUser = MockDataService.shared.getDemoUser()
        self.currentUser = demoUser
        self.isAuthenticated = true
        self.storageService.saveUser(demoUser)
        self.errorMessage = nil
    }

    public func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
        self.storageService.clearUser()
        self.password = ""
        self.errorMessage = nil
    }
}
