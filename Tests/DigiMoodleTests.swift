import XCTest
@testable import DigiMoodle

final class DigiMoodleTests: XCTestCase {

    func testDefaultNotificationSettingIsTwoDaysBefore() {
        let setting = NotificationSetting()
        XCTAssertTrue(setting.isEnabled)
        XCTAssertEqual(setting.daysBefore, 2, "Default notification must be 2 days before")
        XCTAssertEqual(setting.hoursBefore, 0)
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

    func testCustomizableNotificationSettings() {
        var setting = NotificationSetting(isEnabled: true, daysBefore: 2)

        // Adjust to 1 day before
        setting.daysBefore = 1
        XCTAssertEqual(setting.humanDescription, "1 día antes")

        // Adjust to 3 days before
        setting.daysBefore = 3
        XCTAssertEqual(setting.humanDescription, "3 días antes")

        // Adjust to custom days and hours
        setting.daysBefore = 4
        setting.hoursBefore = 6
        XCTAssertEqual(setting.humanDescription, "4 días y 6 horas antes")
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
