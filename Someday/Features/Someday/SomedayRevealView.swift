import SwiftData
import SwiftUI

struct SomedayRevealView: View {
  @Environment(\.modelContext) private var modelContext
  let someday: SomedayItem
  var onDismiss: () -> Void

  @State private var appeared = false
  @State private var showingAddMoment = false
  @State private var showingDeleteConfirmation = false
  @State private var isEditingTitle = false
  @State private var editingTitle = ""
  @FocusState private var titleFieldFocused: Bool

  private var baseColor: Color {
    Color(hex: someday.colorHex)
  }

  private var sortedMoments: [Moment] {
    someday.moments.sorted { $0.createdAt > $1.createdAt }
  }

  private var groupedMoments: [(String, [Moment])] {
    func key(for moment: Moment) -> String {
      moment.createdAt.isToday ? "Today" : moment.createdAt.monthSectionTitle
    }
    let grouped = Dictionary(grouping: sortedMoments, by: key)

    var seen: [String] = []
    for moment in sortedMoments {
      let k = key(for: moment)
      if !seen.contains(k) { seen.append(k) }
    }

    return seen.compactMap { k in
      grouped[k].map { (k, $0) }
    }
  }

  var body: some View {
    NavigationStack {
      ZStack {
        baseColor.opacity(0.25).ignoresSafeArea()

        VStack(alignment: .leading, spacing: 0) {
          // Header
          VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 16) {
              Circle()
                .fill(someday.color)
                .frame(width: 60, height: 60)

              VStack(alignment: .leading, spacing: 4) {
                if isEditingTitle {
                  TextField("Title", text: $editingTitle)
                    .font(.somedayDetailTitle)
                    .foregroundStyle(Color.starWhite)
                    .focused($titleFieldFocused)
                    .onSubmit { commitTitleEdit() }
                    .onChange(of: titleFieldFocused) { _, focused in
                      if !focused { commitTitleEdit() }
                    }
                } else {
                  Text(someday.title)
                    .font(.somedayDetailTitle)
                    .foregroundStyle(Color.starWhite)
                    .onTapGesture { startTitleEdit() }
                }

                if let why = someday.why, !why.isEmpty {
                  Text(why)
                    .font(.somedayCaption)
                    .foregroundStyle(Color.starWhite.opacity(0.6))
                }
              }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 15)

            if !someday.moments.isEmpty {
              Text("^[\(someday.moments.count) moment](inflect: true) logged")
                .font(.somedayCaption)
                .foregroundStyle(Color.starWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(baseColor.opacity(0.3))
                .clipShape(Capsule())
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
            }
          }
          .padding(.horizontal, 24)
          .padding(.top, 16)
          .padding(.bottom, 16)

          // Moments list with swipe-to-delete
          List {
            ForEach(groupedMoments, id: \.0) { group in
              Section {
                ForEach(group.1) { moment in
                  ZStack {
                    // NavigationLink wrapping EmptyView gives tap-to-navigate without a disclosure indicator.
                    NavigationLink(destination: MomentDetailView(moment: moment)) {
                      EmptyView()
                    }
                    .opacity(0)

                    momentRow(moment)
                  }
                  .listRowBackground(Color.clear)
                  .listRowSeparator(.hidden)
                  .listRowInsets(EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24))
                }
                .onDelete { offsets in
                  for index in offsets {
                    let moment = group.1[index]
                    modelContext.delete(moment)
                  }
                  HapticManager.notification(.success)
                }
              } header: {
                Text(group.0)
                  .font(.somedayCaption)
                  .foregroundStyle(Color.starWhite.opacity(0.6))
                  .textCase(nil)
                  .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 4, trailing: 24))
              }
              .listSectionSeparator(.hidden)
            }

            if sortedMoments.isEmpty {
              Text("No moments yet")
                .font(.somedayCaption)
                .foregroundStyle(Color.starWhite.opacity(0.5))
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.top, 20)
            }
          }
          .listStyle(.plain)
          .scrollContentBackground(.hidden)
          .opacity(appeared ? 1 : 0)
        }

        // FAB
        VStack {
          Spacer()
          HStack {
            Spacer()
            Button {
              showingAddMoment = true
            } label: {
              Image(systemName: "square.and.pencil")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.starWhite)
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            }
            .padding(.trailing, 24)
            .padding(.bottom, 16)
            .opacity(appeared ? 1 : 0)
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Menu {
            Button {
              withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                someday.status = .archived
              }
              onDismiss()
            } label: {
              Label("Archive", systemImage: "archivebox")
            }
            Button(role: .destructive) {
              showingDeleteConfirmation = true
            } label: {
              Label("Delete", systemImage: "trash")
            }
          } label: {
            Image(systemName: "ellipsis")
              .font(.system(size: 16, weight: .medium))
              .foregroundStyle(Color.starWhite.opacity(0.6))
          }
          .opacity(appeared ? 1 : 0)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            onDismiss()
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(Color.starWhite.opacity(0.6))
          }
          .opacity(appeared ? 1 : 0)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.hidden, for: .navigationBar)
    }
    .sheet(isPresented: $showingAddMoment) {
      AddMomentView(preselectedSomeday: someday)
    }
    .alert("Delete Someday?", isPresented: $showingDeleteConfirmation) {
      Button("Delete", role: .destructive) {
        modelContext.delete(someday)
        onDismiss()
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("This will permanently delete \"\(someday.title)\" and all its moments.")
    }
    .onAppear {
      withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
        appeared = true
      }
    }
  }

  // MARK: - Title Editing

  private func startTitleEdit() {
    editingTitle = someday.title
    isEditingTitle = true
    titleFieldFocused = true
  }

  private func commitTitleEdit() {
    let trimmed = editingTitle.trimmingCharacters(in: .whitespaces)
    if !trimmed.isEmpty {
      someday.title = trimmed
    }
    isEditingTitle = false
  }

  // MARK: - Moment Row

  private func momentRow(_ moment: Moment) -> some View {
    HStack(spacing: 16) {
      Text("\(moment.createdAt.dayOfMonth, format: .number.grouping(.never))")
        .font(.system(size: 20, weight: .bold))
        .foregroundStyle(Color.starWhite)
        .frame(width: 30)

      Text(moment.note)
        .font(.somedayBody)
        .foregroundStyle(Color.starWhite)
        .lineLimit(1)
        .truncationMode(.tail)

      Spacer()
    }
    .padding(16)
    .background(Color.white.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: SomedayItem.self, configurations: config)
  let someday = SomedayItem(title: "Learn to sail", colorHex: "#7EC8E3", why: "Freedom on the water")
  container.mainContext.insert(someday)
  return SomedayRevealView(someday: someday, onDismiss: {})
    .modelContainer(container)
}
