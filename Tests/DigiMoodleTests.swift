import XCTest
@testable import DigiMoodle

final class DigiMoodleTests: XCTestCase {

    func testDefaultNotificationSettingIsTwoDaysBefore() {
        let setting = NotificationSetting()
        XCTAssertTrue(setting.isEnabled)
        XCTAssertEqual(setting.daysBefore, 2, "Default notification must be 2 days before")
        XCTAssertEqual(setting.hoursBefore, 0)
        XCTAssertFalse(setting.isCustomOffset)
        XCTAssertEqual(setting.preferredHourOfDay, 9)
        XCTAssertEqual(setting.humanDescription, "2 días antes (Recomendado)")
    }

    func testNotificationTriggerDateCalculationTwoDaysBefore() {
        let setting = NotificationSetting(
            isEnabled: true,
            daysBefore: 2,
            hoursBefore: 0,
            preferredHourOfDay: 10,
            preferredMinuteOfDay: 0,
            notifyAtExactOffset: false
        )

        let calendar = Calendar.current
        // A deadline 5 days into the future
        let dueDate = calendar.date(byAdding: .day, value: 5, to: Date())!
        let triggerDate = setting.triggerDate(for: dueDate)

        XCTAssertNotNil(triggerDate, "Trigger date should be calculated for future deadline")
        if let trigger = triggerDate {
            let daysDifference = calendar.dateComponents([.day], from: calendar.startOfDay(for: trigger), to: calendar.startOfDay(for: dueDate)).day
            XCTAssertEqual(daysDifference, 2, "Trigger should be 2 days before the due date")

            let hour = calendar.component(.hour, from: trigger)
            XCTAssertEqual(hour, 10, "Trigger should be at the user's preferred hour (10:00 AM)")
        }
    }

    func testNotificationTriggerExactDeadlineTime() {
        let calendar = Calendar.current
        // Create a future deadline at 16:00 (4:00 PM)
        let futureBase = calendar.date(byAdding: .day, value: 5, to: Date())!
        var comps = calendar.dateComponents([.year, .month, .day], from: futureBase)
        comps.hour = 16
        comps.minute = 0
        comps.second = 0
        let dueDateAt4PM = calendar.date(from: comps)!

        let setting = NotificationSetting(
            isEnabled: true,
            daysBefore: 2,
            hoursBefore: 0,
            notifyAtExactOffset: true
        )

        let triggerDate = setting.triggerDate(for: dueDateAt4PM)
        XCTAssertNotNil(triggerDate)
        if let trigger = triggerDate {
            let daysDifference = calendar.dateComponents([.day], from: calendar.startOfDay(for: trigger), to: calendar.startOfDay(for: dueDateAt4PM)).day
            XCTAssertEqual(daysDifference, 2, "Should trigger 2 days before")
            XCTAssertEqual(calendar.component(.hour, from: trigger), 16, "Should trigger at 16:00 (4:00 PM), matching the exact deadline time")
            XCTAssertEqual(calendar.component(.minute, from: trigger), 0)
        }
    }

    func testCustomizableNotificationSettingsAndCustomMode() {
        var setting = NotificationSetting(isEnabled: true, daysBefore: 2)

        // Adjust to 1 day before
        setting.daysBefore = 1
        XCTAssertEqual(setting.humanDescription, "1 día antes")

        // Adjust to 3 days before
        setting.daysBefore = 3
        XCTAssertEqual(setting.humanDescription, "3 días antes")

        // Activate "A mi medida" with 5 days before
        setting.isCustomOffset = true
        setting.daysBefore = 5
        setting.hoursBefore = 0
        XCTAssertTrue(setting.isCustomOffset)
        XCTAssertEqual(setting.humanDescription, "5 días antes")

        // Adjust to custom days and hours
        setting.daysBefore = 4
        setting.hoursBefore = 6
        XCTAssertEqual(setting.humanDescription, "4 días y 6 horas antes")
    }

    func testOptimizedNotificationFormat() {
        // Create a date on a Thursday at 16:00
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 10
        comps.day = 22 // Oct 22, 2026 is a Thursday (Jueves)
        comps.hour = 16
        comps.minute = 0
        let thursday4PM = Calendar.current.date(from: comps)!

        let assignment = Assignment(
            id: 500,
            courseId: 1,
            courseName: "Programación Multimedia",
            name: "Práctica 3: SwiftUI",
            dueDate: thursday4PM
        )

        XCTAssertEqual(assignment.notificationTitle, "Entrega Programación Multimedia")
        XCTAssertEqual(assignment.notificationBody, "Jueves 16:00 - Práctica 3: SwiftUI")
    }

    func testPerCourseNotificationToggles() {
        var setting = NotificationSetting()
        XCTAssertTrue(setting.isCourseEnabled(courseId: 101), "Course should be enabled by default")

        // Silence course 101
        setting.perCourseToggles[101] = false
        XCTAssertFalse(setting.isCourseEnabled(courseId: 101), "Course 101 should now be silenced")
        XCTAssertTrue(setting.isCourseEnabled(courseId: 102), "Course 102 should still be enabled")
    }

    func testAssignmentStatus() {
        let future = Date().addingTimeInterval(86400 * 3)
        let past = Date().addingTimeInterval(-86400 * 3)

        // Assigned
        let taskAssigned = Assignment(id: 1, courseId: 1, name: "Tarea 1", dueDate: future, isSubmitted: false)
        XCTAssertEqual(taskAssigned.status, .assigned)

        // Submitted
        let taskSubmitted = Assignment(id: 2, courseId: 1, name: "Tarea 2", dueDate: future, isSubmitted: true)
        XCTAssertEqual(taskSubmitted.status, .submitted)

        // Missing / Late
        let taskMissing = Assignment(id: 3, courseId: 1, name: "Tarea 3", dueDate: past, isSubmitted: false)
        XCTAssertEqual(taskMissing.status, .missing)

        // Graded
        let taskGraded = Assignment(id: 4, courseId: 1, name: "Tarea 4", dueDate: past, isSubmitted: true, grade: "10 / 10")
        XCTAssertEqual(taskGraded.status, .graded)
    }

    func testMockDataContainsTwoDayDeadlineTask() {
        let courses = MockDataService.shared.getDemoCourses()
        XCTAssertFalse(courses.isEmpty, "Mock data should contain courses")

        let assignments = MockDataService.shared.getDemoAssignments()
        XCTAssertFalse(assignments.isEmpty, "Mock data should contain assignments")

        // Verify task with ~2 days deadline exists
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let hasTwoDayTask = assignments.contains { assign in
            guard let due = assign.dueDate else { return false }
            let dueDay = calendar.startOfDay(for: due)
            let days = calendar.dateComponents([.day], from: today, to: dueDay).day ?? 0
            return days >= 1 && days <= 2
        }
        XCTAssertTrue(hasTwoDayTask, "Demo dataset must have a task due in ~2 days to verify notification rule")
    }
}
