import Foundation

enum Constants {

    // MARK: - Business Logic

    enum Business {
        /// Days without engagement before a Someday begins to visually fade.
        static let somedayFadeDays = 60
        /// Days without engagement before the "Still want this?" prompt appears.
        static let somedayAlertDays = 90
        /// Maximum characters allowed in a North Star statement.
        static let northStarCharLimit = 120
        /// Number of daily nudge notifications pre-scheduled at a time.
        static let notificationBatchSize = 56
    }

    // MARK: - Solar System

    enum SolarSystem {
        static let minZoomScale: CGFloat = 0.5
        static let maxZoomScale: CGFloat = 3.0
        static let planetBaseSize: CGFloat = 80
        /// Hard cap on visible Moment moons per Someday planet.
        static let maxMoons = 30
        /// Max moons shown in the orbit ring layout (further moons are hidden).
        static let moonDisplayCap = 12
        /// Distance in points from the planet edge to the moon orbit centre.
        static let moonOrbitPadding: Double = 30
        /// Golden angle in radians - distributes moons evenly without clumping.
        static let goldenAngle: Double = 2.39996323
    }

    // MARK: - Layout

    enum Layout {
        static let standardPadding: CGFloat = 24
        static let buttonSize: CGFloat = 56
    }
}
