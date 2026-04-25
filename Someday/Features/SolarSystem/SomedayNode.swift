import SwiftUI

struct SomedayNode: View {
  let someday: SomedayItem
  let position: CGPoint
  let phase: Double
  let onTap: () -> Void

  private let orbitSpeed: Double = 0.04

  // MARK: - Animations

  private var breathScale: CGFloat {
    let seed = Double(someday.title.hashValue % 100) * 0.1
    return CGFloat(1.0 + sin((phase * 0.8) + seed) * 0.02)
  }

  private var swayOffset: CGSize {
    let seed = Double(someday.title.hashValue % 1000) * 0.01
    return CGSize(
      width: CGFloat(sin((phase * 0.15) + seed) * 3),
      height: CGFloat(cos((phase * 0.12) + (seed * 1.3)) * 3)
    )
  }

  // MARK: - Body

  var body: some View {
    let displayCount = min(someday.moments.count, Constants.SolarSystem.maxMoons)

    ZStack {
      ForEach(0..<displayCount, id: \.self) { index in
        MomentNode(phase: phase, index: index)
          .scaleEffect(0.85 + (Double(index % 3) * 0.1))
          .opacity(moonOpacity(for: index))
          .offset(moonOffset(for: index, total: displayCount))
      }

      Circle()
        .fill(someday.color)
        .frame(width: Constants.SolarSystem.planetBaseSize, height: Constants.SolarSystem.planetBaseSize)
        .overlay(grainOverlay)
        .drawingGroup()  // Flattens gradient + noise into a single GPU layer.
        .opacity(someday.agingOpacity)
        .saturation(someday.agingSaturation)
        .scaleEffect(breathScale)
        .offset(swayOffset)
        .onTapGesture {
          HapticManager.selection()
          onTap()
        }
    }
    .position(position)
  }

  // MARK: - Texture

  private var grainOverlay: some View {
    Circle()
      .fill(.white.opacity(0.08))
      .overlay(
        Image(systemName: "circle.fill")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .opacity(0.05)
          .blendMode(.multiply)
      )
      .blur(radius: 0.5)
  }

  // MARK: - Helpers

  private func moonOpacity(for index: Int) -> Double {
    0.6 + (sin((phase * 0.5) + Double(index) * 1.5) * 0.3)
  }

  private func moonOffset(for index: Int, total: Int) -> CGSize {
    let i = Double(index)
    let distance = Double(Constants.SolarSystem.planetBaseSize / 2) + 14.0 + (sqrt(i + 0.5) * 7.0)
    let angle =
      ((i + Double(total) * 0.1) * Constants.SolarSystem.goldenAngle)
      + (phase * orbitSpeed * (25.0 / pow(distance, 0.5)))

    return CGSize(width: CGFloat(cos(angle) * distance), height: CGFloat(sin(angle) * distance))
  }
}
