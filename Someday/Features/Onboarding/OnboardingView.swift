import SwiftData
import SwiftUI

struct OnboardingView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var users: [User]
  @Query(filter: #Predicate<SomedayItem> { $0.statusRaw == "active" })
  private var activeSomedays: [SomedayItem]

  @State private var currentStep = 0
  @State private var northStar = ""
  @State private var firstSomedayTitle = ""
  @State private var firstSomedayColor = Color.somedayPaletteHex[0]
  @State private var nudgeTime =
    Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()

  let onComplete: () -> Void

  var body: some View {
    ZStack {
      Color.nightSky.ignoresSafeArea()
      StarFieldView().ignoresSafeArea()

      VStack {
        // Progress dots
        HStack(spacing: 8) {
          ForEach(0..<4, id: \.self) { index in
            Circle()
              .fill(index <= currentStep ? Color.starWhite : Color.white.opacity(0.3))
              .frame(width: 8, height: 8)
          }
        }
        .padding(.top, 24)

        Spacer()

        // Steps
        Group {
          switch currentStep {
          case 0:
            welcomeStep
          case 1:
            northStarStep
          case 2:
            firstSomedayStep
          case 3:
            notificationStep
          default:
            EmptyView()
          }
        }
        .transition(
          .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
          ))

        Spacer()

        // Navigation
        VStack(spacing: 16) {
          Button {
            advance()
          } label: {
            Text(currentStep == 3 ? "Get Started" : "Continue")
              .font(.somedayBody)
              .fontWeight(.semibold)
              .foregroundStyle(canAdvance ? Color.nightSky : Color.starDim)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .background(canAdvance ? Color.starWhite : Color.white.opacity(0.15))
              .clipShape(RoundedRectangle(cornerRadius: 20))
          }
          .disabled(!canAdvance)

          if currentStep > 1 && currentStep < 3 {
            Button {
              skip()
            } label: {
              Text("Skip for now")
                .font(.somedayCaption)
                .foregroundStyle(Color.starDim)
            }
          }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
      }
    }
  }

  // MARK: - Steps

  private var welcomeStep: some View {
    VStack(spacing: 16) {
        NorthStarNode(size: 80, phase: 0) {

        }

      Text("Someday")
        .font(.somedayTitle)
        .foregroundStyle(Color.starWhite)

      Text("The journal that keeps you pointed north.")
        .font(.somedayBody)
        .foregroundStyle(Color.starDim)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 32)
  }

  private var northStarStep: some View {
    VStack(spacing: 24) {
      Text("What are you ultimately\nworking toward?")
        .font(.somedayHeadline)
        .foregroundStyle(Color.starWhite)
        .multilineTextAlignment(.center)

      Text("Your North Star. Aspirations, goals, or dreams.")
        .font(.somedayCaption)
        .foregroundStyle(Color.starDim)
        .multilineTextAlignment(.center)

      TextField("e.g. Be a force of positivity", text: $northStar)
        .font(.somedayBody)
        .foregroundStyle(Color.starWhite)
        .multilineTextAlignment(.center)
        .padding(16)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 24)

      Text("\(northStar.count)/\(Constants.Business.northStarCharLimit)")
        .font(.somedaySmall)
        .foregroundStyle(northStar.count > Constants.Business.northStarCharLimit ? .red : Color.starDim)
    }
    .padding(.horizontal, 32)
    .onChange(of: northStar) { _, newValue in
      if newValue.count > Constants.Business.northStarCharLimit {
        northStar = String(newValue.prefix(Constants.Business.northStarCharLimit))
      }
    }
  }

  private var firstSomedayStep: some View {
    VStack(spacing: 24) {
      Text("Add your first Someday")
        .font(.somedayHeadline)
        .foregroundStyle(Color.starWhite)

      Text("A long-term aspiration. Could be a task, or something you want your life to contain.")
        .font(.somedayCaption)
        .foregroundStyle(Color.starDim)
        .multilineTextAlignment(.center)

      TextField("e.g. Keep in touch with family", text: $firstSomedayTitle)
        .font(.somedayBody)
        .foregroundStyle(Color.starWhite)
        .multilineTextAlignment(.center)
        .padding(16)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))

      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
        ForEach(Color.somedayPaletteHex, id: \.self) { hex in
          Circle()
            .fill(Color(hex: hex))
            .frame(width: 40, height: 40)
            .overlay(
              Circle()
                .stroke(Color.starWhite, lineWidth: firstSomedayColor == hex ? 2 : 0)
                .frame(width: 46, height: 46)
            )
            .onTapGesture {
              firstSomedayColor = hex
            }
        }
      }
    }
    .padding(.horizontal, 32)
  }

  private var notificationStep: some View {
    VStack(spacing: 24) {
      Text("When should we nudge you?")
        .font(.somedayHeadline)
        .foregroundStyle(Color.starWhite)

      Text("A gentle daily reminder about one of\nyour somedays.")
        .font(.somedayCaption)
        .foregroundStyle(Color.starDim)
        .multilineTextAlignment(.center)

      DatePicker("", selection: $nudgeTime, displayedComponents: .hourAndMinute)
        .datePickerStyle(.wheel)
        .labelsHidden()
        .colorScheme(.dark)
    }
    .padding(.horizontal, 32)
  }

  // MARK: - Logic

  private var canAdvance: Bool {
    switch currentStep {
    case 0: return true
    case 1: return !northStar.trimmingCharacters(in: .whitespaces).isEmpty
    case 2: return true  // Skippable
    case 3: return true
    default: return false
    }
  }

  private func advance() {
    if currentStep == 3 {
      completeOnboarding()
      return
    }

    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
      currentStep += 1
    }
  }

  private func skip() {
    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
      currentStep = 3
    }
  }

  private func completeOnboarding() {
    let user: User
    if let existing = users.first {
      user = existing
    } else {
      user = User()
      modelContext.insert(user)
    }

    user.northStar = northStar.trimmingCharacters(in: .whitespacesAndNewlines)
    user.nudgeTime = nudgeTime
    user.onboardingCompleted = true

    // Create first someday if title provided
    let trimmedTitle = firstSomedayTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmedTitle.isEmpty {
      let someday = SomedayItem(title: trimmedTitle, colorHex: firstSomedayColor)
      modelContext.insert(someday)
    }

    HapticManager.notification(.success)

    let somedays = activeSomedays
    Task {
      let granted = await NotificationManager.shared.requestAuthorization()
      if granted {
        await NotificationManager.shared.rescheduleAll(user: user, activeSomedays: somedays)
      }
    }

    onComplete()
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: User.self, SomedayItem.self, Moment.self, configurations: config)
  return OnboardingView(onComplete: {})
    .modelContainer(container)
}
