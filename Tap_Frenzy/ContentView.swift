import SwiftUI
import Combine

enum GamePhase {
    case idle, playing, over
}

struct ContentView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var phase: GamePhase = .idle
    @State private var combo = 1
    @State private var lastTapTime: Date? = nil
    @State private var isTrap = false
    @State private var buttonOffset = CGSize.zero
    @AppStorage("highScore") private var highScore = 0
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

                        HStack(alignment: .firstTextBaseline) {
                            Text("\(score)")
                                .font(.system(size: 80, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)

                            // C1: combo label
                            Text("x\(combo)!")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(.orange)
                                .opacity(combo > 1 ? 1 : 0)
                        }
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

                        // C2: Trap - tapping now costs points
                        if isTrap {
                            score = max(score - 2, 0)
                            combo = 1
                            lastTapTime = nil
                            return
                        }

                        // C1: Combo
                        let now = Date()
                        if let last = lastTapTime, now.timeIntervalSince(last) < 0.3 {
                            combo = min(combo + 1, 3)
                        } else {
                            combo = 1
                        }
                        lastTapTime = now

                        score += combo
                    } label: {
                        Text(isTrap ? "STOP" : "TAP")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 200, height: 200)
                            .background(Circle().fill(isTrap ? .red : .pink))
                            .shadow(radius: 10)
                    }
                    .offset(buttonOffset)   // C3: moving target

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

                        Text("Best: \(highScore)")
                            .font(.title3.bold())
                            .foregroundStyle(.yellow)

                        Button {
                            score = 0
                            timeRemaining = 10
                            phase = .idle
                            combo = 1
                            lastTapTime = nil
                            isTrap = false
                            buttonOffset = .zero
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

                // C2: 1 in 3 chance to start a trap
                if timeRemaining > 0 && Int.random(in: 1...3) == 1 {
                    isTrap = true
                    Task {
                        try? await Task.sleep(for: .seconds(0.5))
                        isTrap = false
                    }
                }

                // C3: move the button to a random spot
                if timeRemaining > 0 {
                    withAnimation(.spring(duration: 0.3)) {
                        buttonOffset = CGSize(
                            width: Double.random(in: -80...80),
                            height: Double.random(in: -50...80)
                        )
                    }
                }

                if timeRemaining == 0 {
                    if score > highScore {
                        highScore = score
                    }
                    isTrap = false
                    buttonOffset = .zero
                    phase = .over
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
