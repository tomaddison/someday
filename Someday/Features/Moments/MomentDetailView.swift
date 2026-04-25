import SwiftData
import SwiftUI

struct MomentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<SomedayItem> { $0.statusRaw != "archived" })
    private var allSomedays: [SomedayItem]

    @Bindable var moment: Moment

    @State private var showingSomedayPicker = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ZStack {
            Color.nightSky.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.starWhite)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Menu {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.starWhite)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text(moment.createdAt.momentTitleString)
                            .font(.somedayTitle)
                            .foregroundStyle(Color.starWhite)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if !moment.somedays.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Linked Somedays")
                                        .font(.somedayBody)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.starWhite)
                                    Spacer()
                                    Button {
                                        showingSomedayPicker = true
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(Color.starWhite.opacity(0.4))
                                    }
                                }
                                HStack(spacing: 12) {
                                    HStack(spacing: -6) {
                                        ForEach(moment.somedays) { someday in
                                            Circle()
                                                .fill(someday.color)
                                                .frame(width: 28, height: 28)
                                                .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 2))
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        ForEach(moment.somedays) { someday in
                                            Text(someday.title)
                                                .font(.somedayCaption)
                                                .foregroundStyle(Color.starWhite)
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Button {
                                showingSomedayPicker = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle")
                                    Text("Link to Somedays")
                                        .font(.somedayCaption)
                                }
                                .foregroundStyle(Color.starWhite.opacity(0.5))
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }

                        // Inline editable note - tap to edit like Apple Notes
                        ZStack(alignment: .topLeading) {
                            Text(moment.note.isEmpty ? " " : moment.note)
                                .font(.somedayBody)
                                .lineSpacing(6)
                                .foregroundStyle(Color.clear)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)

                            TextEditor(text: $moment.note)
                                .font(.somedayBody)
                                .foregroundStyle(Color.starWhite)
                                .scrollContentBackground(.hidden)
                                .lineSpacing(6)
                                .scrollDisabled(true)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingSomedayPicker) {
            MomentSomedayPickerView(moment: moment, allSomedays: allSomedays)
        }
        .alert("Delete Moment?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                modelContext.delete(moment)
                HapticManager.notification(.success)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This moment will be permanently removed.")
        }
    }
}

// MARK: - Someday Picker

struct MomentSomedayPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let moment: Moment
    let allSomedays: [SomedayItem]

    @State private var selectedIDs: Set<PersistentIdentifier> = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.nightSky.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(allSomedays) { someday in
                                let isSelected = selectedIDs.contains(someday.persistentModelID)
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(someday.color)
                                        .frame(width: 24, height: 24)
                                    Text(someday.title)
                                        .font(.somedayBody)
                                        .foregroundStyle(Color.starWhite)
                                    Spacer()
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(isSelected ? Color.starWhite : Color.dust)
                                }
                                .padding(16)
                                .background(isSelected ? Color.starWhite.opacity(0.15) : Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .onTapGesture {
                                    if isSelected {
                                        selectedIDs.remove(someday.persistentModelID)
                                    } else {
                                        selectedIDs.insert(someday.persistentModelID)
                                    }
                                }
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.starWhite)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        moment.somedays = allSomedays.filter { selectedIDs.contains($0.persistentModelID) }
                        dismiss()
                    }
                    .foregroundStyle(Color.starWhite)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            selectedIDs = Set(moment.somedays.map(\.persistentModelID))
        }
    }
}

private func pageTitle(_ text: String) -> some View {
    Text(text)
        .font(.somedayTitle)
        .foregroundStyle(Color.starWhite)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
}

#Preview("Moment Detail") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SomedayItem.self, Moment.self, configurations: config)
    let someday1 = SomedayItem(title: "Keep in touch with family", colorHex: "#7EC8E3")
    let someday2 = SomedayItem(title: "Write a novel", colorHex: "#C8A2C8")
    let moment = Moment(note: "Called my brother today and spoke about coming home in a couple of weeks.", createdAt: Date())
    moment.somedays = [someday1, someday2]
    container.mainContext.insert(someday1)
    container.mainContext.insert(someday2)
    container.mainContext.insert(moment)
    return MomentDetailView(moment: moment)
        .modelContainer(container)
}

#Preview("Someday Picker") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SomedayItem.self, Moment.self, configurations: config)
    let someday1 = SomedayItem(title: "Keep in touch with family", colorHex: "#7EC8E3")
    let someday2 = SomedayItem(title: "Write a novel", colorHex: "#C8A2C8")
    let moment = Moment(note: "Felt inspired today", createdAt: Date())
    container.mainContext.insert(someday1)
    container.mainContext.insert(someday2)
    container.mainContext.insert(moment)
    return MomentSomedayPickerView(moment: moment, allSomedays: [someday1, someday2])
        .modelContainer(container)
}
