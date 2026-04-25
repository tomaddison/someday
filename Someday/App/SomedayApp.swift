import SwiftUI
import SwiftData

@main
struct SomedayApp: App {
    init() {
        configureNavigationBarAppearance()
        _ = NotificationManager.shared
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            SomedayItem.self,
            Moment.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
