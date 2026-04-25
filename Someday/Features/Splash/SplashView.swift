import SwiftUI
internal import Combine

struct SplashView: View {
    @State private var phase: Double = 0

    var body: some View {
        ZStack {
            Color.nightSky.ignoresSafeArea()

            StarFieldView(count: 120)

            VStack {
                Spacer()
                NorthStarNode(size: 120, phase: phase) {}
                Spacer()
                Text("someday")
                    .font(.somedayDisplay)
                    .foregroundStyle(Color.starWhite)
                    .padding(.bottom, 60)
            }
        }
        .onReceive(
            Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()
        ) { _ in
            phase += 1.0 / 30.0
        }
    }
}

#Preview {
    SplashView()
}
