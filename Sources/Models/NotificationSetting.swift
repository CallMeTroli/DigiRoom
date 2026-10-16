import Foundation

public struct NotificationSetting: Codable, Equatable {
    public var isEnabled: Bool
    public var daysBefore: Int
    public var hoursBefore: Int
    public var preferredHourOfDay: Int
    public var preferredMinuteOfDay: Int
    public var notifyAtExactOffset: Bool // If true, dueDate - offset; If false, daysBefore at preferredHourOfDay
    public var soundEnabled: Bool
    public var perCourseToggles: [Int: Bool] // courseId -> isEnabled

    public init(
        isEnabled: Bool = true,
        daysBefore: Int = 2, // Default: 2 days before (user requirement)
        hoursBefore: Int = 0,
        preferredHourOfDay: Int = 9, // Default: 09:00 AM
        preferredMinuteOfDay: Int = 0,
        notifyAtExactOffset: Bool = false,
        soundEnabled: Bool = true,
        perCourseToggles: [Int: Bool] = [:]
    ) {
        self.isEnabled = isEnabled
        self.daysBefore = daysBefore
        self.hoursBefore = hoursBefore
        self.preferredHourOfDay = preferredHourOfDay
        self.preferredMinuteOfDay = preferredMinuteOfDay
        self.notifyAtExactOffset = notifyAtExactOffset
        self.soundEnabled = soundEnabled
        self.perCourseToggles = perCourseToggles
    }

    /// Calculate the reminder date for a given assignment deadline
    public func triggerDate(for dueDate: Date) -> Date? {
        guard isEnabled else { return nil }

        let calendar = Calendar.current
        var targetDate: Date

        if notifyAtExactOffset {
            // Exact offset in seconds: days * 86400 + hours * 3600
            let totalSeconds = TimeInterval(daysBefore * 86400 + hoursBefore * 3600)
            targetDate = dueDate.addingTimeInterval(-totalSeconds)
        } else {
            // Days before at the user's preferred hour of the day (e.g., 2 days before at 09:00 AM)
            guard let daysAgoDate = calendar.date(byAdding: .day, value: -daysBefore, to: dueDate) else {
                return nil
            }
            var components = calendar.dateComponents([.year, .month, .day], from: daysAgoDate)
            components.hour = preferredHourOfDay
            components.minute = preferredMinuteOfDay
            components.second = 0

            guard let calculated = calendar.date(from: components) else {
                return nil
            }
            targetDate = calculated
        }

        // Only return if it's in the future
        return targetDate > Date() ? targetDate : nil
    }

    /// Checks if a specific course should trigger notifications
    public func isCourseEnabled(courseId: Int) -> Bool {
        guard isEnabled else { return false }
        return perCourseToggles[courseId] ?? true
    }

    public var humanDescription: String {
        if daysBefore == 2 && hoursBefore == 0 {
            return "2 días antes (Recomendado)"
        } else if daysBefore == 1 && hoursBefore == 0 {
            return "1 día antes"
        } else if daysBefore == 3 && hoursBefore == 0 {
            return "3 días antes"
        } else if daysBefore == 0 && hoursBefore > 0 {
            return "\(hoursBefore) horas antes"
        } else {
            return "\(daysBefore) días y \(hoursBefore) horas antes"
        }
    }
}
