import SwiftUI
import SwiftData

struct AddSomedayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var why = ""
    @State private var selectedColorHex = Color.somedayPaletteHex[0]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.nightSky.ignoresSafeArea()

                VStack(spacing: 32) {
                    pageTitle("New Someday")

                    // Color picker
                    VStack(spacing: 16) {
                        Circle()
                            .fill(somedayGradient(for: selectedColorHex))
                            .frame(width: 80, height: 80)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                            ForEach(Color.somedayPaletteHex, id: \.self) { hex in
                                Circle()
                                    .fill(somedayGradient(for: hex))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.starWhite, lineWidth: selectedColorHex == hex ? 2 : 0)
                                            .frame(width: 46, height: 46)
                                    )
                                    .onTapGesture {
                                        selectedColorHex = hex
                                    }
                            }
                        }
                    }

                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's your someday?")
                            .font(.somedayCaption)
                            .foregroundStyle(Color.starDim)

                        TextField("e.g. Keep in touch with family", text: $title)
                            .font(.somedayBody)
                            .foregroundStyle(Color.starWhite)
                            .padding(16)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Why
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why does it matter? (optional)")
                            .font(.somedayCaption)
                            .foregroundStyle(Color.starDim)

                        TextField("Because...", text: $why, axis: .vertical)
                            .font(.somedayBody)
                            .foregroundStyle(Color.starWhite)
                            .lineLimit(3...6)
                            .padding(16)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Spacer()
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.starWhite)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .foregroundStyle(title.isEmpty ? Color.starDim : Color.starWhite)
                        .fontWeight(.semibold)
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func somedayGradient(for hex: String) -> RadialGradient {
        let base = Color(hex: hex)
        return RadialGradient(
            colors: [base.softShift(by: 0.1), base],
            center: .center,
            startRadius: 0,
            endRadius: 52
        )
    }

    private func save() {
        let trimmedWhy = why.trimmingCharacters(in: .whitespacesAndNewlines)
        let someday = SomedayItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            colorHex: selectedColorHex,
            why: trimmedWhy.isEmpty ? nil : trimmedWhy
        )
        modelContext.insert(someday)
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SomedayItem.self, Moment.self, configurations: config)
    return AddSomedayView()
        .modelContainer(container)
}
