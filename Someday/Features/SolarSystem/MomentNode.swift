import SwiftUI

struct MomentNode: View {
  let phase: Double
  let index: Int

  private var breathScale: CGFloat {
    let breath = sin(phase * 0.6 + Double(index) * 0.5) * 0.015
    return 1.0 + breath
  }

  var body: some View {
    Circle()
      .fill(Color.dust)
      .frame(width: 6, height: 6)
      .scaleEffect(breathScale)
  }
}
