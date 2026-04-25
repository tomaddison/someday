import SwiftUI

struct NorthStarNode: View {
  let size: CGFloat
  let phase: Double
  let onTap: () -> Void

  private var breathScale: CGFloat {
    let breath = sin(phase * 0.8) * 0.05
    return 1.0 + breath
  }

  var body: some View {
    ZStack {

      Circle()
        .fill(Color.sun.opacity(0.2))
        .frame(width: size * 1.3, height: size * 1.3)
        .colorEffect(ShaderLibrary.textureErosion(.boundingRect, .float(0.2)))
        .rotationEffect(.degrees(phase * 2))

      Circle()
        .fill(Color.sun.opacity(0.25))
        .frame(width: size * 1.3, height: size * 1.3)
        .colorEffect(ShaderLibrary.textureErosion(.boundingRect, .float(0.2)))
        .rotationEffect(.degrees(-phase * 1.5))

      Circle()
        .fill(Color.sun.opacity(0.25))
        .frame(width: size * 1.15, height: size * 1.3)
        .colorEffect(ShaderLibrary.textureErosion(.boundingRect, .float(0.2)))
        .rotationEffect(.degrees(phase * 1))

      Circle()
        .fill(Color.sun.opacity(0.3))
        .frame(width: size * 1.15, height: size * 1.3)
        .colorEffect(ShaderLibrary.textureErosion(.boundingRect, .float(0.2)))
        .rotationEffect(.degrees(-phase * 1.25))

      Circle()
        .fill(Color.sun)
        .frame(width: size, height: size * 1.3)
        .colorEffect(ShaderLibrary.textureErosion(.boundingRect, .float(1)))
        .rotationEffect(.degrees(phase * 0.5))
    }
    .scaleEffect(breathScale)
    .onTapGesture {
      HapticManager.impact(.medium)
      onTap()
    }
  }
}
