import Foundation
import SwiftData

@Model
final class User {
    var northStar: String
    var ratioTarget: Double
    var nudgeTime: Date
    var nudgeEnabled: Bool
    var agingAlertsEnabled: Bool
    var onboardingCompleted: Bool
    var createdAt: Date

    init(
        northStar: String = "",
        ratioTarget: Double = 0.6,
        nudgeTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(),
        nudgeEnabled: Bool = true,
        agingAlertsEnabled: Bool = true,
        onboardingCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.northStar = northStar
        self.ratioTarget = ratioTarget
        self.nudgeTime = nudgeTime
        self.nudgeEnabled = nudgeEnabled
        self.agingAlertsEnabled = agingAlertsEnabled
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = createdAt
    }
}
