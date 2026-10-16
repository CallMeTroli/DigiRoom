import SwiftUI
import UserNotifications

@main
struct DigiMoodleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        return true
    }
}
