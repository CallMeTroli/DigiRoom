import Foundation

public final class StorageService {
    public static let shared = StorageService()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let currentUser = "digimoodle_current_user"
        static let notificationSetting = "digimoodle_notification_setting"
        static let cachedCourses = "digimoodle_cached_courses"
        static let cachedAssignments = "digimoodle_cached_assignments"
        static let rememberCredentials = "digimoodle_remember_credentials"
        static let savedUsername = "digimoodle_saved_username"
    }

    private init() {}

    // MARK: - Current User
    public func saveUser(_ user: User?) {
        guard let user = user else {
            defaults.removeObject(forKey: Keys.currentUser)
            return
        }
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: Keys.currentUser)
        }
    }

    public func loadUser() -> User? {
        guard let data = defaults.data(forKey: Keys.currentUser) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    public func clearUser() {
        defaults.removeObject(forKey: Keys.currentUser)
    }

    // MARK: - Notification Setting
    public func saveNotificationSetting(_ setting: NotificationSetting) {
        if let data = try? JSONEncoder().encode(setting) {
            defaults.set(data, forKey: Keys.notificationSetting)
        }
    }

    public func loadNotificationSetting() -> NotificationSetting {
        guard let data = defaults.data(forKey: Keys.notificationSetting),
              let setting = try? JSONDecoder().decode(NotificationSetting.self, from: data) else {
            return NotificationSetting() // Default with 2 days before
        }
        return setting
    }

    // MARK: - Remember Username
    public func saveRememberUsername(_ username: String, remember: Bool) {
        defaults.set(remember, forKey: Keys.rememberCredentials)
        if remember {
            defaults.set(username, forKey: Keys.savedUsername)
        } else {
            defaults.removeObject(forKey: Keys.savedUsername)
        }
    }

    public func getRememberedUsername() -> (String, Bool) {
        let remember = defaults.bool(forKey: Keys.rememberCredentials)
        let username = defaults.string(forKey: Keys.savedUsername) ?? ""
        return (username, remember)
    }
}
