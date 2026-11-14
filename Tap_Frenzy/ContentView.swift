import SwiftUI
import SwiftUI
import Combine

struct ContentView: View {
    @State private var score = 0
        @State private var timeRemaining = 10
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // LAYER 1: the background colour (fills the whole screen)
            LinearGradient(
                colors: [.indigo, .purple],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // LAYER 2: everything else, stacked top to bottom
            VStack(spacing: 30) {

                // Title
                Text("Tap Frenzy")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                // Score
                VStack {
                    Text("SCORE")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("\(score)")
                        .font(.system(size: 80, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }

                // Timer
                Text("10s")
                    .font(.title2.bold())
                    .foregroundStyle(.yellow)

                // The big TAP button
                Button {
                score += 1
                } label: {
                    Text("TAP")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 200)
                        .background(Circle().fill(.pink))
                        .shadow(radius: 10)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
