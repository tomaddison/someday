import SwiftData
import UserNotifications

extension Notification.Name {
    static let nudgeTapped = Notification.Name("SomedayNudgeTapped")
}

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func rescheduleAll(user: User, activeSomedays: [SomedayItem]) async {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }
        center.removeAllPendingNotificationRequests()
        if user.nudgeEnabled {
            await scheduleDailyNudges(at: user.nudgeTime, somedays: activeSomedays)
        }
        if user.agingAlertsEnabled {
            await scheduleAgingAlerts(for: activeSomedays)
        }
    }

    // MARK: - Daily Nudge

    private func scheduleDailyNudges(at time: Date, somedays: [SomedayItem]) async {
        guard !somedays.isEmpty else { return }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        var requests: [UNNotificationRequest] = []

        for day in 0..<Constants.Business.notificationBatchSize {
            guard let fireDate = calendar.date(byAdding: .day, value: day, to: Date()),
                  let trigger = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: fireDate)
            else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Someday"
            content.body = "Take a moment to reflect on the things that matter most."
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: trigger)
            let notifTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            requests.append(UNNotificationRequest(identifier: "nudge.\(day)", content: content, trigger: notifTrigger))
        }

        for request in requests {
            try? await center.add(request)
        }
    }

    // MARK: - Aging Alerts

    private func scheduleAgingAlerts(for somedays: [SomedayItem]) async {
        let now = Date()
        var requests: [UNNotificationRequest] = []

        for someday in somedays {
            guard let fireDate = Calendar.current.date(
                byAdding: .day,
                value: Constants.Business.somedayAlertDays,
                to: someday.lastEngagedAt
            ), fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = someday.title
            content.body = "You haven't visited this in a while. Is it still something you want?"
            content.sound = .default

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            // Use createdAt timestamp for a stable, unique ID that doesn't change if the title is edited.
            let id = "aging.\(Int(someday.createdAt.timeIntervalSince1970))"
            requests.append(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }

        for request in requests {
            try? await center.add(request)
        }
    }

    // MARK: - Delegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let id = response.notification.request.identifier
        if id.hasPrefix("nudge.") || id.hasPrefix("aging.") {
            NotificationCenter.default.post(name: .nudgeTapped, object: nil)
        }
        completionHandler()
    }
}
