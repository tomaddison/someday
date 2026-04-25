import Foundation
import SwiftData
import SwiftUI

@Observable
final class SolarSystemViewModel {
  var showingAddSomeday = false
  var showingAddMoment = false
  var showingNorthStarReveal = false
  var showingMoments = false
  var selectedSomeday: SomedayItem?
  var zoomingSomeday: SomedayItem?

  var isZooming: Bool {
    showingNorthStarReveal || zoomingSomeday != nil
  }

  var scale: CGFloat = 1.0
  var offset: CGSize = .zero
  var lastScale: CGFloat = 1.0
  var lastOffset: CGSize = .zero

  let minScale = Constants.SolarSystem.minZoomScale
  let maxScale = Constants.SolarSystem.maxZoomScale

  // Zoom anchor - set eagerly before withAnimation so scaleEffect captures the right value.
  var zoomAnchor: UnitPoint = .center
  // The offset before a zoom-in, restored when the reveal is dismissed.
  var preZoomOffset: CGSize = .zero

  func resetView() {
    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
      scale = 1.0
      offset = .zero
      lastScale = 1.0
      lastOffset = .zero
      zoomAnchor = .center
      preZoomOffset = .zero
    }
  }

  func planetPosition(for someday: SomedayItem, index: Int, total: Int, in size: CGSize) -> CGPoint {
    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    let momentCount = someday.moments.count
    let shortSide = Double(min(size.width, size.height))
    let maxRadius = shortSide * 0.65
    let minRadius = shortSide * 0.45

    // More Moments = closer orbit (smaller radius), pulling the planet toward the North Star.
    let momentFactor = min(Double(momentCount) / 10.0, 1.0)
    let baseRadius = maxRadius - (momentFactor * (maxRadius - minRadius))

    // Fading Somedays drift outward as they age.
    let agingDrift = someday.isFading ? shortSide * 0.05 : 0.0
    let radius = baseRadius + agingDrift

    let angleStep = (2.0 * Double.pi) / max(Double(total), 1.0)
    let angle = angleStep * Double(index) + Double.pi / 4.0

    return CGPoint(
      x: center.x + CGFloat(radius * cos(angle)),
      y: center.y + CGFloat(radius * sin(angle))
    )
  }

  func moonPositions(count: Int, around center: CGPoint, planetRadius: CGFloat) -> [CGPoint] {
    guard count > 0 else { return [] }
    let displayCount = min(count, Constants.SolarSystem.moonDisplayCap)
    let moonOrbitRadius = Double(planetRadius) + Constants.SolarSystem.moonOrbitPadding
    let angleStep = (2 * Double.pi) / Double(displayCount)

    return (0..<displayCount).map { i in
      let angle = angleStep * Double(i) - Double.pi / 2
      return CGPoint(
        x: center.x + CGFloat(moonOrbitRadius * cos(angle)),
        y: center.y + CGFloat(moonOrbitRadius * sin(angle))
      )
    }
  }
}
