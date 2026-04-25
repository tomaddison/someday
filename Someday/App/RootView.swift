import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var users: [User]
    @Query(filter: #Predicate<SomedayItem> { $0.statusRaw == "active" })
    private var activeSomedays: [SomedayItem]

    @State private var hasCompletedOnboarding = false
    @State private var showAddMomentFromNudge = false
    @State private var showingSplash = true

    private var user: User? { users.first }

    // Daily nudge taps open AddMomentView pre-selected on the Someday with least engagement.
    private var fewestMomentsSomeday: SomedayItem? {
        activeSomedays.min(by: { $0.moments.count < $1.moments.count })
    }

    var body: some View {
        Group {
            if showingSplash {
                SplashView()
                    .transition(.opacity)
            } else if user?.onboardingCompleted == true || hasCompletedOnboarding {
                SolarSystemView()
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeInOut(duration: 0.4)) {
                showingSplash = false
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAddMomentFromNudge) {
            AddMomentView(preselectedSomeday: fewestMomentsSomeday)
        }
        .onReceive(NotificationCenter.default.publisher(for: .nudgeTapped)) { _ in
            showAddMomentFromNudge = true
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, let user, user.onboardingCompleted else { return }
            let somedays = activeSomedays
            Task {
                await NotificationManager.shared.rescheduleAll(user: user, activeSomedays: somedays)
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [
            User.self,
            SomedayItem.self,
            Moment.self,
        ], inMemory: true)
}
