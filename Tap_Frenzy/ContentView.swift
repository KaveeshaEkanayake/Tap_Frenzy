import SwiftUI
import Combine

enum GamePhase {
    case idle, playing, over
}

struct ContentView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var phase: GamePhase = .idle
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

                switch phase {
                case .idle, .playing:
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
                    Text(phase == .idle ? "tap to start" : "\(timeRemaining)s")
                        .font(.title2.bold())
                        .foregroundStyle(.yellow)

                    // The big TAP button
                    Button {
                        if phase == .idle {
                            phase = .playing
                        }
                        score += 1
                    } label: {
                        Text("TAP")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 200, height: 200)
                            .background(Circle().fill(.pink))
                            .shadow(radius: 10)
                    }

                case .over:
                    // Game over screen
                    VStack(spacing: 20) {
                        Text("Time's up")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)

                        Text("YOUR SCORE")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))

                        Text("\(score)")
                            .font(.system(size: 80, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)

                        Button {
                            score = 0
                            timeRemaining = 10
                            phase = .idle
                        } label: {
                            Text("Play Again")
                                .font(.title2.bold())
                                .foregroundStyle(.purple)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(.white))
                        }
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if phase == .playing {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
                if timeRemaining == 0 {
                    phase = .over
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
