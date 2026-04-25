import SwiftData
import SwiftUI

struct NorthStarRevealView: View {
  let user: User?
  let somedays: [SomedayItem]
  var onDismiss: () -> Void

  @State private var appeared = false

  private var activeSomedaysThisMonth: [SomedayItem] {
    let now = Date()
    return somedays.filter { someday in
      someday.moments.contains { $0.createdAt.isSameMonth(as: now) }
    }
  }

  var body: some View {
    ZStack {
      Color.sun.ignoresSafeArea()

      TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
        let phase = timeline.date.timeIntervalSinceReferenceDate

        GeometryReader { geo in
          // Top-right - lighter
          Circle()
            .fill(Color.white.opacity(0.1))
            .frame(width: geo.size.width * 0.85)
            .colorEffect(ShaderLibrary.textureErosion(.boundingRect, .float(0.22)))
            .rotationEffect(.degrees(phase * 3))
            .position(x: geo.size.width * 0.87, y: geo.size.height * 0.08)

          // Top-left - slightly darker
          Circle()
            .fill(Color.sun.opacity(0.5))
            .frame(width: geo.size.width * 0.8)
            .colorEffect(ShaderLibrary.textureErosion(.boundingRect, .float(0.25)))
            .rotationEffect(.degrees(-phase * 2))
            .position(x: geo.size.width * 0.01, y: geo.size.height * 0.03)

          // Bottom - large lighter shape for text contrast
          Circle()
            .fill(Color.white.opacity(0.14))
            .frame(width: geo.size.width * 1.45)
            .colorEffect(ShaderLibrary.textureErosion(.boundingRect, .float(0.18)))
            .rotationEffect(.degrees(phase * 1.5))
            .position(x: geo.size.width * 0.5, y: geo.size.height * 0.97)
        }
        .opacity(appeared ? 1 : 0)
      }

      VStack(spacing: 32) {
        Spacer()

        Text("Your North Star")
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(Color.nearBlack.opacity(0.5))
          .opacity(appeared ? 1 : 0)
          .offset(y: appeared ? 0 : 10)

        Text("\u{201C}\(user?.northStar ?? "Set your North Star")\u{201D}")
          .font(.serifItalic(40))
          .foregroundStyle(Color.nearBlack.opacity(0.8))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 40)
          .opacity(appeared ? 1 : 0)
          .offset(y: appeared ? 0 : 15)

        Spacer()

        monthlyActivity
          .padding(.bottom, 80)
      }
    }
    .onTapGesture { onDismiss() }
    .onAppear {
      withAnimation(.easeOut(duration: 1.2).delay(0.5)) {
        appeared = true
      }
    }
  }

  // MARK: - Monthly Activity

  @ViewBuilder
  private var monthlyActivity: some View {
    let active = activeSomedaysThisMonth

    VStack(spacing: 16) {
      HStack(spacing: -6) {
        ForEach(active.prefix(5)) { someday in
          Circle()
            .fill(someday.color)
            .frame(width: 28, height: 28)
            .overlay(Circle().stroke(Color.sun, lineWidth: 2))
        }
      }
      .opacity(appeared ? 1 : 0)

      if !active.isEmpty {
        Text("You contributed to ^[\(active.count) someday](inflect: true) this month")
          .font(.somedayBody)
          .foregroundStyle(Color.nearBlack.opacity(0.6))
          .opacity(appeared ? 1 : 0)
      }
    }
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: User.self, SomedayItem.self, configurations: config)
  let user = User(northStar: "Be a force of positive change", onboardingCompleted: true)
  let someday1 = SomedayItem(title: "Learn to sail", colorHex: "#7EC8E3")
  let someday2 = SomedayItem(title: "Write a book", colorHex: "#C8A2C8")
  let someday3 = SomedayItem(title: "Run a marathon", colorHex: "#F2BFC0")
  container.mainContext.insert(user)
  container.mainContext.insert(someday1)
  container.mainContext.insert(someday2)
  container.mainContext.insert(someday3)
  return NorthStarRevealView(user: user, somedays: [someday1, someday2, someday3], onDismiss: {})
    .modelContainer(container)
}
