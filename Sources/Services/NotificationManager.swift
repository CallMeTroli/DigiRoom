import Foundation
import UserNotifications

public final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    override private init() {
        super.init()
        center.delegate = self
    }

    // MARK: - Permissions
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error solicitando permisos de notificación: \(error)")
            return false
        }
    }

    public func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule Reminders for Assignments
    public func scheduleReminders(
        for assignments: [Assignment],
        setting: NotificationSetting
    ) async {
        guard setting.isEnabled else {
            await clearAllScheduledNotifications()
            return
        }

        // Clean up previous assignment notifications
        await clearAllScheduledNotifications()

        for assignment in assignments {
            guard let dueDate = assignment.dueDate, !assignment.isSubmitted else { continue }
            guard setting.isCourseEnabled(courseId: assignment.courseId) else { continue }
            guard let reminderDate = setting.triggerDate(for: dueDate) else { continue }

            let content = UNMutableNotificationContent()
            // Optimized format:
            // Entrega [clase]
            // [dia de la semana que se entrega] [hora de entrega] - [nombre la tarea]
            content.title = assignment.notificationTitle
            content.body = assignment.notificationBody
            content.sound = setting.soundEnabled ? .default : nil
            content.badge = 1
            content.userInfo = [
                "assignmentId": assignment.id,
                "courseId": assignment.courseId,
                "type": "assignment_reminder"
            ]

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: reminderDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "assignment_\(assignment.id)",
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
            } catch {
                print("Error programando notificación para tarea \(assignment.id): \(error)")
            }
        }
    }

    // MARK: - Test Notification
    public func sendTestNotification(
        setting: NotificationSetting,
        sampleAssignment: Assignment? = nil
    ) async -> Bool {
        let status = await checkAuthorizationStatus()
        if status == .notDetermined {
            let granted = await requestAuthorization()
            guard granted else { return false }
        } else if status == .denied {
            return false
        }

        let content = UNMutableNotificationContent()
        if let sample = sampleAssignment, sample.dueDate != nil {
            content.title = sample.notificationTitle
            content.body = sample.notificationBody
        } else {
            content.title = "Entrega Programación Multimedia y Dispositivos Móviles"
            content.body = "Jueves 16:00 - Práctica 3: Interfaz iOS compatible con Google Classroom"
        }
        content.sound = setting.soundEnabled ? .default : nil
        content.badge = 1

        // Trigger in 3 seconds for instant testing
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_notification_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            return true
        } catch {
            print("Error enviando notificación de prueba: \(error)")
            return false
        }
    }

    // MARK: - Cancellation
    public func cancelNotification(for assignmentId: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["assignment_\(assignmentId)"])
    }

    public func clearAllScheduledNotifications() async {
        center.removeAllPendingNotificationRequests()
    }

    public func getPendingNotificationsCount() async -> Int {
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }

    // MARK: - UNUserNotificationCenterDelegate
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play sound even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
