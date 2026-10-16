import Foundation
import Combine
import UserNotifications

@MainActor
public final class NotificationViewModel: ObservableObject {
    @Published public var setting: NotificationSetting
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published public var isScheduling: Bool = false
    @Published public var showTestSuccessAlert: Bool = false
    @Published public var showPermissionDeniedAlert: Bool = false
    @Published public var pendingCount: Int = 0

    private let notificationManager = NotificationManager.shared
    private let storageService = StorageService.shared

    public init() {
        self.setting = storageService.loadNotificationSetting()
        Task {
            await checkStatus()
            await updatePendingCount()
        }
    }

    public func checkStatus() async {
        authorizationStatus = await notificationManager.checkAuthorizationStatus()
    }

    public func requestPermissions() async {
        let granted = await notificationManager.requestAuthorization()
        await checkStatus()
        if !granted {
            showPermissionDeniedAlert = true
        }
    }

    public func updateOffset(days: Int, hours: Int = 0) {
        setting.daysBefore = days
        setting.hoursBefore = hours
        saveAndApply()
    }

    public func updatePreferredTime(hour: Int, minute: Int) {
        setting.preferredHourOfDay = hour
        setting.preferredMinuteOfDay = minute
        saveAndApply()
    }

    public func toggleMaster(enabled: Bool) {
        setting.isEnabled = enabled
        saveAndApply()
    }

    public func toggleCourse(courseId: Int, enabled: Bool) {
        setting.perCourseToggles[courseId] = enabled
        saveAndApply()
    }

    public func toggleSound(enabled: Bool) {
        setting.soundEnabled = enabled
        saveAndApply()
    }

    public func sendTestNotification() async {
        let success = await notificationManager.sendTestNotification(setting: setting)
        if success {
            showTestSuccessAlert = true
            await updatePendingCount()
        } else {
            showPermissionDeniedAlert = true
        }
    }

    public func applyToAssignments(_ assignments: [Assignment]) async {
        isScheduling = true
        await notificationManager.scheduleReminders(for: assignments, setting: setting)
        await updatePendingCount()
        isScheduling = false
    }

    private func saveAndApply() {
        storageService.saveNotificationSetting(setting)
    }

    private func updatePendingCount() async {
        pendingCount = await notificationManager.getPendingNotificationsCount()
    }
}
