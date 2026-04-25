import SwiftData
import SwiftUI

struct AddMomentView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Query(filter: #Predicate<SomedayItem> { $0.statusRaw != "archived" })
  private var somedays: [SomedayItem]

  let preselectedSomeday: SomedayItem?
  var date: Date = Date()

  @State private var note = ""
  @State private var selectedSomedays: Set<PersistentIdentifier> = []

  private var orderedSomedays: [SomedayItem] {
    guard let preselected = preselectedSomeday else { return somedays }
    var result = somedays.filter { $0.persistentModelID != preselected.persistentModelID }
    result.insert(preselected, at: 0)
    return result
  }

  var body: some View {
    ZStack {
      Color.nightSky.ignoresSafeArea()

      VStack(alignment: .leading, spacing: 24) {
        HStack {
          Button("Cancel") { dismiss() }
            .foregroundStyle(Color.starWhite)
          Spacer()
          Button("Save") { save() }
            .foregroundStyle(note.isEmpty ? Color.starDim : Color.starWhite)
            .fontWeight(.semibold)
            .disabled(note.isEmpty)
        }

        pageTitle("New Moment")

        if let preselectedSomeday {
          HStack {
            HStack(spacing: 8) {
              Circle()
                .fill(preselectedSomeday.color)
                .frame(width: 16, height: 16)
              Text(preselectedSomeday.title)
                .font(.somedayCaption)
                .foregroundStyle(Color.starWhite)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AnyShapeStyle(preselectedSomeday.color.opacity(0.3)))
            .clipShape(Capsule())
            Spacer()
          }
        } else if !somedays.isEmpty {
          VStack(alignment: .leading, spacing: 12) {
            Text("Link to Somedays")
              .font(.somedayCaption)
              .foregroundStyle(Color.starDim)

            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 12) {
                ForEach(orderedSomedays) { someday in
                  let isSelected = selectedSomedays.contains(someday.persistentModelID)
                  HStack(spacing: 8) {
                    Circle()
                      .fill(someday.color)
                      .frame(width: 16, height: 16)
                    Text(someday.title)
                      .font(.somedayCaption)
                      .foregroundStyle(Color.starWhite)
                  }
                  .padding(.horizontal, 14)
                  .padding(.vertical, 10)
                  .background(
                    isSelected
                      ? AnyShapeStyle(someday.color.opacity(0.3))
                      : AnyShapeStyle(Color.white.opacity(0.1))
                  )
                  .clipShape(Capsule())
                  .opacity(isSelected ? 1.0 : 0.4)
                  .onTapGesture {
                    if isSelected {
                      selectedSomedays.remove(someday.persistentModelID)
                    } else {
                      selectedSomedays.insert(someday.persistentModelID)
                    }
                  }
                }
              }
            }
          }
        }

        ZStack(alignment: .topLeading) {
          if note.isEmpty {
            Text("What happened today?")
              .font(.somedayBody)
              .foregroundStyle(Color.starDim)
              .padding(.top, 8)
          }

          TextEditor(text: $note)
            .font(.somedayBody)
            .foregroundStyle(Color.starWhite)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 200)
        }

        Spacer()
      }
      .padding(24)
    }
    .onAppear {
      if let preselectedSomeday {
        selectedSomedays.insert(preselectedSomeday.persistentModelID)
      }
    }
  }

  private func save() {
    let linked = somedays.filter { selectedSomedays.contains($0.persistentModelID) }
    let moment = Moment(
      note: note.trimmingCharacters(in: .whitespacesAndNewlines),
      createdAt: date.isToday ? Date() : date,
      somedays: linked
    )
    modelContext.insert(moment)

    for someday in linked {
      someday.lastEngagedAt = Date()
      if someday.status == .fading {
        someday.status = .active
      }
    }

    HapticManager.notification(.success)
    dismiss()
  }
}

private func pageTitle(_ text: String) -> some View {
    Text(text)
        .font(.somedayTitle)
        .foregroundStyle(Color.starWhite)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
}

#Preview("No preselection") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SomedayItem.self, Moment.self, configurations: config)
    let someday1 = SomedayItem(title: "Keep in touch with family", colorHex: "#7EC8E3")
    let someday2 = SomedayItem(title: "Write a novel", colorHex: "#C8A2C8")
    container.mainContext.insert(someday1)
    container.mainContext.insert(someday2)
    return AddMomentView(preselectedSomeday: nil)
        .modelContainer(container)
}

#Preview("With preselection") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SomedayItem.self, Moment.self, configurations: config)
    let someday = SomedayItem(title: "Keep in touch with family", colorHex: "#7EC8E3")
    container.mainContext.insert(someday)
    return AddMomentView(preselectedSomeday: someday)
        .modelContainer(container)
}
