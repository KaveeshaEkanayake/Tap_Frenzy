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
    @State private var buttonScale = 1.0
    @State private var showBonus = false
    @State private var bonusPosition = CGSize.zero
    @State private var scorePop = false          // Stretch 2
    @AppStorage("highScore") private var highScore = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Stretch 1: timer colour changes as time runs out
    var timerColor: Color {
        if phase == .idle {
            return .white
        } else if timeRemaining > 6 {
            return .green
        } else if timeRemaining > 3 {
            return .orange
        } else {
            return .red
        }
    }

    // Stretch 2: make the score pop, then shrink back
    func popScore() {
        withAnimation(.spring(duration: 0.15)) {
            scorePop = true
        }
        Task {
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.spring(duration: 0.2)) {
                scorePop = false
            }
        }
    }

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
                                .contentTransition(.numericText())   // Stretch 2: rolling digits
                                .scaleEffect(scorePop ? 1.3 : 1.0)    // Stretch 2: bounce

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
                        .foregroundStyle(timerColor)

                    // The big TAP button
                    Button {
                        if phase == .idle {
                            phase = .playing
                        }

                        // C2: Trap - tapping now costs points
                        if isTrap {
                            withAnimation {
                                score = max(score - 2, 0)
                            }
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

                        // Stretch 2: animated score
                        withAnimation(.spring(duration: 0.15)) {
                            score += combo
                        }
                        popScore()

                        // C4: shrink a little on every good tap
                        withAnimation(.easeOut(duration: 0.1)) {
                            buttonScale = max(buttonScale - 0.03, 0.5)
                        }
                    } label: {
                        Text(isTrap ? "STOP" : "TAP")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 200, height: 200)
                            .background(Circle().fill(isTrap ? .red : .pink))
                            .shadow(radius: 10)
                    }
                    .scaleEffect(buttonScale)   // C4: shrinking button
                    .offset(buttonOffset)       // C3: moving target

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
                            buttonScale = 1.0
                            showBonus = false
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

            // LAYER 3: C5 bonus burst (on top of everything)
            if showBonus && phase == .playing {
                Button {
                    // Stretch 2: animate the bonus too
                    withAnimation(.spring(duration: 0.15)) {
                        score += 5
                        showBonus = false
                    }
                    popScore()
                } label: {
                    Text("+5")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(width: 60, height: 60)
                        .background(Circle().fill(.yellow))
                        .shadow(color: .orange, radius: 10)
                }
                .offset(bonusPosition)
                .transition(.scale)
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

                // C5: every 2 seconds, 1 in 2 chance of a bonus
                if timeRemaining > 1 && timeRemaining % 2 == 0 && Bool.random() {
                    bonusPosition = CGSize(
                        width: Double.random(in: -140...140),
                        height: Double.random(in: -250...250)
                    )
                    withAnimation {
                        showBonus = true
                    }
                    Task {
                        try? await Task.sleep(for: .seconds(1.5))
                        withAnimation {
                            showBonus = false
                        }
                    }
                }

                if timeRemaining == 0 {
                    if score > highScore {
                        highScore = score
                    }
                    isTrap = false
                    buttonOffset = .zero
                    showBonus = false
                    phase = .over
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
