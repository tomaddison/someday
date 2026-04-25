import SwiftData
import SwiftUI

struct SolarSystemView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(filter: #Predicate<SomedayItem> { $0.statusRaw != "archived" })
  private var somedays: [SomedayItem]
  @Query private var users: [User]

  @State private var viewModel = SolarSystemViewModel()
  @State private var viewSize: CGSize = .zero
  private var user: User? { users.first }

  var body: some View {
    GeometryReader { geometry in
      let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

      ZStack {
        Color.nightSky.ignoresSafeArea()
        StarFieldView()
          .offset(
            x: viewModel.offset.width * 0.05,
            y: viewModel.offset.height * 0.05
          )
          .scaleEffect(1.0 + (viewModel.scale - 1.0) * 0.05)
          .ignoresSafeArea()

        solarSystem(center: center, size: geometry.size)
          .scaleEffect(viewModel.isZooming ? 5.0 : viewModel.scale, anchor: viewModel.zoomAnchor)
          .blur(radius: viewModel.isZooming ? 30 : 0)
          .opacity(viewModel.isZooming ? 0 : 1)
          .offset(viewModel.offset)
          .allowsHitTesting(!viewModel.isZooming)

        if viewModel.showingNorthStarReveal {
          NorthStarRevealView(user: user, somedays: somedays) {
            viewModel.offset = viewModel.preZoomOffset
            viewModel.lastOffset = viewModel.preZoomOffset
            viewModel.zoomAnchor = .center
            withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
              viewModel.showingNorthStarReveal = false
            }
          }
          .transition(.opacity)
          .zIndex(10)
        }

        if let someday = viewModel.zoomingSomeday {
          SomedayRevealView(someday: someday) {
            // Zoom-out originates from the planet, then re-anchors to centre while preserving any pan mid-animation.
            withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
              viewModel.zoomingSomeday = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
              let s = viewModel.scale
              let anchor = viewModel.zoomAnchor
              let w = geometry.size.width
              let h = geometry.size.height
              let dx = (anchor.x * w - w / 2) * (s - 1)
              let dy = (anchor.y * h - h / 2) * (s - 1)
              viewModel.offset = CGSize(
                width: viewModel.offset.width - dx,
                height: viewModel.offset.height - dy
              )
              viewModel.lastOffset = viewModel.offset
              viewModel.zoomAnchor = .center
            }
          }
          .transition(.opacity)
          .zIndex(10)
        }

        VStack {
          Spacer()
          bottomBar
        }
        .opacity(viewModel.isZooming ? 0 : 1)
      }
      .simultaneousGesture(viewModel.isZooming ? nil : dragGesture(in: geometry.size))
      .simultaneousGesture(viewModel.isZooming ? nil : magnifyGesture(in: geometry.size))
      .onAppear { viewSize = geometry.size }
      .onChange(of: geometry.size) { _, newSize in viewSize = newSize }
    }
    .sheet(isPresented: $viewModel.showingAddSomeday) { AddSomedayView() }
    .sheet(isPresented: $viewModel.showingAddMoment) { AddMomentView(preselectedSomeday: nil) }
    .sheet(isPresented: $viewModel.showingMoments) { MomentsView() }
  }

  // MARK: - Solar System Content

  private func solarSystem(center: CGPoint, size: CGSize) -> some View {
    TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
      let phase = timeline.date.timeIntervalSinceReferenceDate

      ZStack {
        NorthStarNode(size: 140, phase: phase) {
          zoomToNorthStar(in: size)
        }
        .position(center)

        ForEach(Array(somedays.enumerated()), id: \.element.persistentModelID) { index, someday in
          SomedayNode(
            someday: someday,
            position: viewModel.planetPosition(
              for: someday, index: index, total: somedays.count, in: size),
            phase: phase,
            onTap: {
              zoomToSomeday(someday, index: index, in: size)
            }
          )
        }

        if somedays.isEmpty {
          Text("It's looking pretty empty out here.")
            .font(.somedayCaption)
            .foregroundStyle(Color.starDim)
            .position(x: size.width / 2, y: size.height / 2 + 110)
        }
      }
    }
  }

  // MARK: - Zoom

  private func zoomToSomeday(_ someday: SomedayItem, index: Int, in size: CGSize) {
    let planetPos = viewModel.planetPosition(for: someday, index: index, total: somedays.count, in: size)
    let s = viewModel.scale

    viewModel.preZoomOffset = viewModel.offset

    // Switch from centre anchor to planet anchor without a visual jump.
    let dx = (planetPos.x - size.width / 2) * (s - 1)
    let dy = (planetPos.y - size.height / 2) * (s - 1)
    viewModel.zoomAnchor = UnitPoint(x: planetPos.x / size.width, y: planetPos.y / size.height)
    viewModel.offset.width += dx
    viewModel.offset.height += dy
    viewModel.lastOffset = viewModel.offset

    withAnimation(.easeIn(duration: 0.5)) {
      viewModel.zoomingSomeday = someday
    }
  }

  private func zoomToNorthStar(in size: CGSize) {
    viewModel.preZoomOffset = viewModel.offset
    viewModel.zoomAnchor = .center
    withAnimation(.easeIn(duration: 0.5)) {
      viewModel.showingNorthStarReveal = true
    }
  }

  // MARK: - Gestures

  private func dragGesture(in size: CGSize) -> some Gesture {
    DragGesture(minimumDistance: 10)
      .onChanged { value in
        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.9)) {
          viewModel.offset = CGSize(
            width: viewModel.lastOffset.width + value.translation.width,
            height: viewModel.lastOffset.height + value.translation.height
          )
        }
      }
      .onEnded { _ in
        viewModel.lastOffset = viewModel.offset
      }
  }

  private func magnifyGesture(in size: CGSize) -> some Gesture {
    MagnifyGesture()
      .onChanged { value in
        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.9)) {
          let newScale = viewModel.lastScale * value.magnification
          viewModel.scale = min(max(newScale, viewModel.minScale), viewModel.maxScale)
        }
      }
      .onEnded { _ in
        viewModel.lastScale = viewModel.scale
      }
  }

  // MARK: - Navigation

  private var northStarOffScreen: Bool {
    guard viewSize != .zero else { return false }
    return abs(viewModel.offset.width) > viewSize.width / 2 + 60
        || abs(viewModel.offset.height) > viewSize.height / 2 + 60
  }

  private func returnToCenter() {
    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
      viewModel.offset = .zero
      viewModel.lastOffset = .zero
    }
  }

  // MARK: - Bottom Bar

  private var bottomBar: some View {
    HStack {
      Button {
        viewModel.showingMoments = true
      } label: {
        Image(systemName: "book.closed")
          .font(.system(size: 22))
          .foregroundStyle(Color.starWhite)
          .frame(width: 56, height: 56)
          .background(Color.white.opacity(0.15))
          .clipShape(Circle())
      }
      Spacer()
      Button {
        returnToCenter()
      } label: {
        Image(systemName: "scope")
          .font(.system(size: 22))
          .foregroundStyle(Color.starWhite)
          .frame(width: 56, height: 56)
          .background(Color.white.opacity(0.15))
          .clipShape(Circle())
      }
      .opacity(northStarOffScreen ? 1 : 0)
      .animation(.spring(response: 0.4, dampingFraction: 0.8), value: northStarOffScreen)
      .allowsHitTesting(northStarOffScreen)
      Spacer()
      Menu {
        Button {
          viewModel.showingAddSomeday = true
        } label: {
          Label("New Someday", systemImage: "microbe")
        }
        Button {
          viewModel.showingAddMoment = true
        } label: {
          Label("New Moment", systemImage: "square.and.pencil")
        }
      } label: {
        Image(systemName: "plus")
          .font(.system(size: 22, weight: .medium))
          .foregroundStyle(Color.starWhite)
          .frame(width: 56, height: 56)
          .background(Color.white.opacity(0.15))
          .clipShape(Circle())
      }
    }
    .padding(.horizontal, 24).padding(.bottom, 16)
  }

}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: User.self, SomedayItem.self, Moment.self, configurations: config)
  let user = User(northStar: "Be a force of positive change", onboardingCompleted: true)
  let someday1 = SomedayItem(title: "Keep in touch with family", colorHex: "#7EC8E3")
  let someday2 = SomedayItem(title: "Write a novel", colorHex: "#C8A2C8")
  let someday3 = SomedayItem(title: "Make time for playing piano", colorHex: "#F2BFC0")
  container.mainContext.insert(user)
  container.mainContext.insert(someday1)
  container.mainContext.insert(someday2)
  container.mainContext.insert(someday3)
  return SolarSystemView()
    .modelContainer(container)
}
