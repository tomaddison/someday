import Foundation
import SwiftData
import SwiftUI

enum SomedayStatus: String {
    case active
    case fading
    case archived
}

@Model
final class SomedayItem {
    var title: String
    var colorHex: String
    var why: String?
    var createdAt: Date
    var lastEngagedAt: Date
    var statusRaw: String
    var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \Moment.somedays)
    var moments: [Moment] = []

    var status: SomedayStatus {
        get { SomedayStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    init(
        title: String,
        colorHex: String = "#F2BFC0",
        why: String? = nil,
        createdAt: Date = Date(),
        lastEngagedAt: Date = Date(),
        status: SomedayStatus = .active,
        sortOrder: Int = 0
    ) {
        self.title = title
        self.colorHex = colorHex
        self.why = why
        self.createdAt = createdAt
        self.lastEngagedAt = lastEngagedAt
        self.statusRaw = status.rawValue
        self.sortOrder = sortOrder
    }

    var color: RadialGradient {
        let base = Color(hex: colorHex)
        // Deterministic gradient centre derived from the title hash - each Someday gets a unique-looking orb.
        let hash = title.hashValue
        let center = UnitPoint(
            x: Double(abs(hash % 100)) / 100.0,
            y: Double(abs((hash / 100) % 100)) / 100.0
        )
        return RadialGradient(
            colors: [base.softShift(by: 0.1), base],
            center: center,
            startRadius: 0,
            endRadius: 52
        )
    }

    var daysSinceEngaged: Int {
        Calendar.current.dateComponents([.day], from: lastEngagedAt, to: Date()).day ?? 0
    }

    var isFading: Bool {
        daysSinceEngaged >= Constants.Business.somedayFadeDays
    }

    var shouldPromptLetGo: Bool {
        daysSinceEngaged >= Constants.Business.somedayAlertDays
    }

    var agingOpacity: Double {
        if daysSinceEngaged < Constants.Business.somedayFadeDays { return 1.0 }
        let fadeDays = Double(min(daysSinceEngaged - Constants.Business.somedayFadeDays, 30))
        return max(0.4, 1.0 - (fadeDays / 60.0))
    }

    var agingSaturation: Double {
        if daysSinceEngaged < Constants.Business.somedayFadeDays { return 1.0 }
        let fadeDays = Double(min(daysSinceEngaged - Constants.Business.somedayFadeDays, 30))
        return max(0.3, 1.0 - (fadeDays / 50.0))
    }
}
