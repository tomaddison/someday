import SwiftUI

struct StarFieldView: View {
    private struct Star {
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let baseOpacity: Double
        let twinkleSpeed: Double
        let twinklePhase: Double
    }

    private let stars: [Star]

    init(count: Int = 80) {
        // Deterministic LCG so star positions and sizes are stable across redraws.
        var seed: UInt64 = 12345
        func next() -> Double {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return Double(seed >> 33) / Double(UInt64(1) << 31)
        }
        stars = (0..<count).map { _ in
            Star(
                x: next(),
                y: next(),
                size: 1.0 + next() * 1.5,
                baseOpacity: 0.3 + next() * 0.6,
                twinkleSpeed: 0.5 + next() * 1.5,
                twinklePhase: next() * .pi * 2
            )
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 10.0)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for star in stars {
                    let opacity = star.baseOpacity * (0.7 + 0.3 * sin(time * star.twinkleSpeed + star.twinklePhase))
                    let rect = CGRect(
                        x: star.x * size.width - star.size / 2,
                        y: star.y * size.height - star.size / 2,
                        width: star.size,
                        height: star.size
                    )
                    ctx.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        StarFieldView(count: 120)
    }
}
