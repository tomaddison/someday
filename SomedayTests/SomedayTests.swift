import Testing
import Foundation
import SwiftData
@testable import Someday

// MARK: - SomedayItem Aging

@Suite("SomedayItem aging logic")
@MainActor
struct SomedayItemAgingTests {

    // Each test gets its own suite instance, so each gets its own container.
    // Storing it here keeps it alive for the duration of the test.
    let container: ModelContainer

    init() throws {
        container = try ModelContainer(
            for: SomedayItem.self, Moment.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private func makeItem(daysAgo: Int) -> SomedayItem {
        let lastEngaged = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        let item = SomedayItem(title: "Test", lastEngagedAt: lastEngaged)
        container.mainContext.insert(item)
        return item
    }

    @Test func freshItemIsNotFading() {
        let item = makeItem(daysAgo: 0)
        #expect(!item.isFading)
        #expect(!item.shouldPromptLetGo)
        #expect(item.agingOpacity == 1.0)
        #expect(item.agingSaturation == 1.0)
    }

    @Test func itemFadesAfter60Days() {
        let item = makeItem(daysAgo: 61)
        #expect(item.isFading)
        #expect(!item.shouldPromptLetGo)
        #expect(item.agingOpacity < 1.0)
        #expect(item.agingSaturation < 1.0)
    }

    @Test func itemPromptsLetGoAfter90Days() {
        let item = makeItem(daysAgo: 91)
        #expect(item.isFading)
        #expect(item.shouldPromptLetGo)
    }

    @Test func agingOpacityNeverFallsBelowMinimum() {
        let item = makeItem(daysAgo: 365)
        #expect(item.agingOpacity >= 0.4)
    }

    @Test func agingSaturationNeverFallsBelowMinimum() {
        let item = makeItem(daysAgo: 365)
        #expect(item.agingSaturation >= 0.3)
    }

    @Test func fadingThresholdMatchesConstant() {
        let itemBefore = makeItem(daysAgo: Constants.Business.somedayFadeDays - 1)
        let itemAt = makeItem(daysAgo: Constants.Business.somedayFadeDays)
        #expect(!itemBefore.isFading)
        #expect(itemAt.isFading)
    }

    @Test func alertThresholdMatchesConstant() {
        let itemBefore = makeItem(daysAgo: Constants.Business.somedayAlertDays - 1)
        let itemAt = makeItem(daysAgo: Constants.Business.somedayAlertDays)
        #expect(!itemBefore.shouldPromptLetGo)
        #expect(itemAt.shouldPromptLetGo)
    }
}

// MARK: - Date Helpers

@Suite("Date helpers")
struct DateHelperTests {

    @Test func isSameDayTrueForSameDay() {
        let date = Date()
        #expect(date.isSameDay(as: date))
    }

    @Test func isSameDayFalseForDifferentDays() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        #expect(!today.isSameDay(as: yesterday))
    }

    @Test func isSameMonthTrueForSameMonth() {
        let date = Date()
        let sameMonth = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        // Only reliable within-month, so use start of month
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
        #expect(date.isSameMonth(as: startOfMonth))
    }

    @Test func isSameMonthFalseAcrossMonths() {
        let date = Date()
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        #expect(!date.isSameMonth(as: nextMonth))
    }

    @Test func weekDatesAlwaysHasSevenDays() {
        let dates = Date().weekDates
        #expect(dates.count == 7)
    }

    @Test func weekDatesAreConsecutive() {
        let dates = Date().weekDates
        for i in 1..<dates.count {
            let diff = Calendar.current.dateComponents([.day], from: dates[i - 1], to: dates[i]).day
            #expect(diff == 1)
        }
    }

    @Test func isTodayForCurrentDate() {
        #expect(Date().isToday)
    }

    @Test func isTodayFalseForYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        #expect(!yesterday.isToday)
    }
}
