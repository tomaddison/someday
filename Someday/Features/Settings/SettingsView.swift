import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var users: [User]
    @Query(filter: #Predicate<SomedayItem> { $0.statusRaw == "archived" })
    private var archivedSomedays: [SomedayItem]
    @Query(filter: #Predicate<SomedayItem> { $0.statusRaw == "active" })
    private var activeSomedays: [SomedayItem]

    @State private var northStar = ""
    @State private var nudgeTime = Date()
    @State private var nudgeEnabled = true
    @State private var agingAlertsEnabled = true
    #if DEBUG
    @State private var showingLoadSampleConfirm = false
    @State private var showingClearAllConfirm = false
    #endif

    private var user: User? { users.first }

    var body: some View {
        ZStack {
            Color.nightSky.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Settings")
                        .font(.somedayTitle)
                        .foregroundStyle(Color.starWhite)
                    Spacer()
                    Button("Done") { saveAndDismiss() }
                        .foregroundStyle(Color.starWhite)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 24) {
                        settingsSection(title: "North Star") {
                            TextField("Your North Star", text: $northStar)
                                .font(.somedayBody)
                                .foregroundStyle(Color.starWhite)
                                .onChange(of: northStar) { _, newValue in
                                    if newValue.count > Constants.Business.northStarCharLimit {
                                        northStar = String(newValue.prefix(Constants.Business.northStarCharLimit))
                                    }
                                }

                            Text("\(northStar.count)/\(Constants.Business.northStarCharLimit)")
                                .font(.somedaySmall)
                                .foregroundStyle(Color.dust)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        // Daily Nudge
                        settingsSection(title: "Daily Nudge") {
                            Toggle(isOn: $nudgeEnabled) {
                                Text("Enabled")
                                    .font(.somedayBody)
                                    .foregroundStyle(Color.starWhite)
                            }
                            .tint(Color.starWhite.opacity(0.6))

                            if nudgeEnabled {
                                Divider()

                                HStack {
                                    Text("Reminder time")
                                        .font(.somedayBody)
                                        .foregroundStyle(Color.starWhite)

                                    Spacer()

                                    DatePicker("", selection: $nudgeTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                }
                            }
                        }

                        // Aging Alerts
                        settingsSection(title: "Aging Alerts") {
                            Toggle(isOn: $agingAlertsEnabled) {
                                Text("Enabled")
                                    .font(.somedayBody)
                                    .foregroundStyle(Color.starWhite)
                            }
                            .tint(Color.starWhite.opacity(0.6))

                            if agingAlertsEnabled {
                                Divider()

                                Text("Get a nudge when a Someday hasn't had any activity in 90 days.")
                                    .font(.somedayCaption)
                                    .foregroundStyle(Color.starDim)
                            }
                        }

                        #if DEBUG
                        settingsSection(title: "Developer") {
                            Button {
                                showingLoadSampleConfirm = true
                            } label: {
                                HStack {
                                    Text("Load Sample Data")
                                        .font(.somedayBody)
                                        .foregroundStyle(Color.starWhite)
                                    Spacer()
                                }
                            }

                            Divider()

                            Button {
                                showingClearAllConfirm = true
                            } label: {
                                HStack {
                                    Text("Clear All Data")
                                        .font(.somedayBody)
                                        .foregroundStyle(Color.starWhite)
                                    Spacer()
                                }
                            }

                            Divider()

                            Text("Replaces all existing data. Debug builds only.")
                                .font(.somedayCaption)
                                .foregroundStyle(Color.starDim)
                        }
                        #endif

                        // Archived Somedays
                        settingsSection(title: "Archived Somedays") {
                            if archivedSomedays.isEmpty {
                                HStack {
                                    Text("No archived somedays")
                                        .font(.somedayCaption)
                                        .foregroundStyle(Color.dust)
                                    Spacer()
                                }
                            } else {
                                ForEach(archivedSomedays) { someday in
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(someday.color)
                                            .frame(width: 20, height: 20)
                                            .opacity(0.5)

                                        Text(someday.title)
                                            .font(.somedayBody)
                                            .foregroundStyle(Color.starWhite.opacity(0.5))

                                        Spacer()

                                        Button {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                someday.status = .active
                                                someday.lastEngagedAt = Date()
                                            }
                                        } label: {
                                            Text("Restore")
                                                .font(.somedayCaption)
                                                .foregroundStyle(Color.starWhite)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.white.opacity(0.1))
                                                .clipShape(Capsule())
                                        }
                                    }

                                    if someday.persistentModelID != archivedSomedays.last?.persistentModelID {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                        .padding(24)
                    }
                }
            }
            .onAppear {
                northStar = user?.northStar ?? ""
                nudgeTime = user?.nudgeTime ?? Date()
                nudgeEnabled = user?.nudgeEnabled ?? true
                agingAlertsEnabled = user?.agingAlertsEnabled ?? true
            }
        #if DEBUG
            .alert("Load Sample Data?", isPresented: $showingLoadSampleConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Load", role: .destructive) { loadSampleData() }
            } message: {
                Text("This replaces all existing Somedays, Moments, and the North Star with a demo dataset.")
            }
            .alert("Clear All Data?", isPresented: $showingClearAllConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) { clearAllData() }
            } message: {
                Text("This deletes every Someday, Moment, and the current North Star. The app will return to onboarding.")
            }
        #endif
    }

    #if DEBUG
    private func loadSampleData() {
        SampleData.populate(into: modelContext)
        if let user = users.first {
            let somedays = activeSomedays
            Task {
                await NotificationManager.shared.rescheduleAll(user: user, activeSomedays: somedays)
            }
        }
        dismiss()
    }

    private func clearAllData() {
        SampleData.clearAll(from: modelContext)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        dismiss()
    }
    #endif

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.somedayCaption)
                .foregroundStyle(Color.starWhite.opacity(0.6))

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func saveAndDismiss() {
        if let user {
            user.northStar = northStar.trimmingCharacters(in: .whitespacesAndNewlines)
            user.nudgeTime = nudgeTime
            user.nudgeEnabled = nudgeEnabled
            user.agingAlertsEnabled = agingAlertsEnabled
            let somedays = activeSomedays
            Task {
                await NotificationManager.shared.rescheduleAll(user: user, activeSomedays: somedays)
            }
        }
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, SomedayItem.self, Moment.self, configurations: config)
    SampleData.populate(into: container.mainContext)
    let archived = SomedayItem(title: "Learn to fly", colorHex: "#F2BFC0", status: .archived)
    container.mainContext.insert(archived)
    return SettingsView()
        .modelContainer(container)
}

