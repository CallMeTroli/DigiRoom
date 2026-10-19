import Foundation

public struct NotificationSetting: Codable, Equatable {
    public var isEnabled: Bool
    public var daysBefore: Int
    public var hoursBefore: Int
    public var isCustomOffset: Bool
    public var preferredHourOfDay: Int
    public var preferredMinuteOfDay: Int
    public var notifyAtExactOffset: Bool // If true, notifies at the exact deadline time X days before; If false, at preferredHourOfDay
    public var soundEnabled: Bool
    public var perCourseToggles: [Int: Bool] // courseId -> isEnabled

    public init(
        isEnabled: Bool = true,
        daysBefore: Int = 2, // Default: 2 days before (user requirement)
        hoursBefore: Int = 0,
        isCustomOffset: Bool = false,
        preferredHourOfDay: Int = 9, // Default: 09:00 AM
        preferredMinuteOfDay: Int = 0,
        notifyAtExactOffset: Bool = false,
        soundEnabled: Bool = true,
        perCourseToggles: [Int: Bool] = [:]
    ) {
        self.isEnabled = isEnabled
        self.daysBefore = daysBefore
        self.hoursBefore = hoursBefore
        self.isCustomOffset = isCustomOffset
        self.preferredHourOfDay = preferredHourOfDay
        self.preferredMinuteOfDay = preferredMinuteOfDay
        self.notifyAtExactOffset = notifyAtExactOffset
        self.soundEnabled = soundEnabled
        self.perCourseToggles = perCourseToggles
    }

    public enum CodingKeys: String, CodingKey {
        case isEnabled
        case daysBefore
        case hoursBefore
        case isCustomOffset
        case preferredHourOfDay
        case preferredMinuteOfDay
        case notifyAtExactOffset
        case soundEnabled
        case perCourseToggles
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        let decodedDays = try container.decodeIfPresent(Int.self, forKey: .daysBefore) ?? 2
        let decodedHours = try container.decodeIfPresent(Int.self, forKey: .hoursBefore) ?? 0
        self.daysBefore = decodedDays
        self.hoursBefore = decodedHours
        let defaultIsCustom = !((decodedDays == 1 || decodedDays == 2 || decodedDays == 3) && decodedHours == 0)
        self.isCustomOffset = try container.decodeIfPresent(Bool.self, forKey: .isCustomOffset) ?? defaultIsCustom
        self.preferredHourOfDay = try container.decodeIfPresent(Int.self, forKey: .preferredHourOfDay) ?? 9
        self.preferredMinuteOfDay = try container.decodeIfPresent(Int.self, forKey: .preferredMinuteOfDay) ?? 0
        self.notifyAtExactOffset = try container.decodeIfPresent(Bool.self, forKey: .notifyAtExactOffset) ?? false
        self.soundEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? true
        self.perCourseToggles = try container.decodeIfPresent([Int: Bool].self, forKey: .perCourseToggles) ?? [:]
    }

    /// Calculate the reminder date for a given assignment deadline
    public func triggerDate(for dueDate: Date) -> Date? {
        guard isEnabled else { return nil }

        let calendar = Calendar.current
        var targetDate: Date

        if notifyAtExactOffset {
            // Exact same time of the deadline, X days (and Y hours) before.
            // E.g. if task closes Thursday at 16:00 and daysBefore = 2, notification arrives Tuesday at 16:00.
            var offsetComponents = DateComponents()
            offsetComponents.day = -daysBefore
            offsetComponents.hour = -hoursBefore
            guard let calculated = calendar.date(byAdding: offsetComponents, to: dueDate) else {
                return nil
            }
            targetDate = calculated
        } else {
            // Days before at the user's preferred hour of the day (e.g., 2 days before at 09:00 AM)
            guard let daysAgoDate = calendar.date(byAdding: .day, value: -daysBefore, to: dueDate) else {
                return nil
            }
            var components = calendar.dateComponents([.year, .month, .day], from: daysAgoDate)
            components.hour = preferredHourOfDay
            components.minute = preferredMinuteOfDay
            components.second = 0

            guard var calculated = calendar.date(from: components) else {
                return nil
            }
            if hoursBefore > 0, let withHours = calendar.date(byAdding: .hour, value: -hoursBefore, to: calculated) {
                calculated = withHours
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
        if !isCustomOffset && daysBefore == 2 && hoursBefore == 0 {
            return "2 días antes (Recomendado)"
        } else if daysBefore == 1 && hoursBefore == 0 {
            return "1 día antes"
        } else if daysBefore > 1 && hoursBefore == 0 {
            return "\(daysBefore) días antes"
        } else if daysBefore == 0 && hoursBefore > 0 {
            return "\(hoursBefore) \(hoursBefore == 1 ? "hora" : "horas") antes"
        } else {
            let dLabel = daysBefore == 1 ? "día" : "días"
            let hLabel = hoursBefore == 1 ? "hora" : "horas"
            return "\(daysBefore) \(dLabel) y \(hoursBefore) \(hLabel) antes"
        }
    }

    public var timePreferenceDescription: String {
        if notifyAtExactOffset {
            return "exactamente a la hora de cierre de la tarea"
        } else {
            return String(format: "a las %02d:%02d", preferredHourOfDay, preferredMinuteOfDay)
        }
    }
}
