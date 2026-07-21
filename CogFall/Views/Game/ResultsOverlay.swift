import SwiftUI

struct ResultsOverlay: View {
    let result: GameResult
    var onPrimary: () -> Void
    var onReplay: () -> Void
    var onConduit: () -> Void

    @State private var starsShown = 0
    @State private var appear = false

    private var isOverdrive: Bool { result.mode == .overdrive }
    private var title: String {
        if result.solved { return isOverdrive ? "Overdrive run" : "\(result.bayName) ticks!" }
        return result.reason.title
    }
    private var eyebrowText: String {
        if isOverdrive { return "Endless mode" }
        return result.solved ? "Bay \(String(format: "%02d", result.levelIndex)) complete" : "Bay \(String(format: "%02d", result.levelIndex)) failed"
    }
    private var primaryLabel: String {
        if result.mode == .campaign && result.solved { return "Next bay" }
        return isOverdrive ? "Run again" : "Retry"
    }

    var body: some View {
        ZStack {
            SceneBackground()
                .overlay(Color.black.opacity(0.35).ignoresSafeArea())

            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                ZStack {
                    RaysView().frame(width: 320, height: 320).opacity(0.16)
                    GearView(material: result.solved ? .brass : .rust, glow: result.solved)
                        .frame(width: 140, height: 140)
                        .shadow(color: (result.solved ? Palette.power : Palette.rust).opacity(0.55), radius: 28)
                    Image(systemName: result.solved ? result.fixture : "exclamationmark.triangle.fill")
                        .font(.system(size: 46, weight: .medium))
                        .foregroundColor(Palette.engrave)
                }
                .scaleEffect(appear ? 1 : 0.7)

                Text(eyebrowText.uppercased()).eyebrow(result.solved ? Palette.brass : Color(hex: "#FFB98C"))
                    .padding(.top, 8)
                Text(title)
                    .font(Typo.display(32)).foregroundColor(Palette.text).multilineTextAlignment(.center)
                    .liftedText().padding(.horizontal, 30).padding(.top, 8)

                if !result.solved {
                    Text(result.reason.detail)
                        .font(Typo.body(13)).foregroundColor(Palette.text2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Palette.abyss.opacity(0.55)))
                        .padding(.horizontal, 34).padding(.top, 10)
                }

                if !isOverdrive {
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < starsShown ? "star.fill" : "star")
                                .font(.system(size: 28))
                                .foregroundColor(i < starsShown ? Palette.brass : Palette.text3.opacity(0.4))
                                .scaleEffect(i < starsShown ? 1 : 0.8)
                                .shadow(color: i < starsShown ? Palette.brass.opacity(0.5) : .clear, radius: 8)
                        }
                    }
                    .padding(.top, 16)
                }

                // breakdown
                VStack(spacing: 0) {
                    row("clock.fill", "Powered for", timeString(result.secondsPowered))
                    Divider().background(Palette.hairline)
                    row("gearshape.2.fill", "Gears meshed", "\(result.gearsMeshed)")
                    Divider().background(Palette.hairline)
                    if result.solved {
                        row("bolt.fill", "Spare-gear bonus", "+\(ScoreEngine.spareBonus(result.gearsSpare))")
                        Divider().background(Palette.hairline)
                    }
                    HStack {
                        Text("Total score").font(Typo.plate(12)).tracking(1.4).textCase(.uppercase).foregroundColor(Palette.text)
                        Spacer()
                        Text("\(result.score)").font(Typo.display(26)).foregroundColor(Palette.brass)
                            .contentTransition(.numericText())
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal, 22).padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 24).fill(LinearGradient(colors: [Palette.surface2.opacity(0.7), Palette.bg.opacity(0.86)], startPoint: .top, endPoint: .bottom)))
                .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(Palette.hairline, lineWidth: 1))
                .premiumShadow()
                .padding(.horizontal, 24).padding(.top, 22)

                Spacer()

                VStack(spacing: 12) {
                    BrassButton(title: primaryLabel, trailingIcon: result.mode == .campaign && result.solved ? "arrow.right" : nil,
                                height: 64, action: onPrimary)
                    HStack(spacing: 12) {
                        GhostButton(title: "Replay", systemIcon: "arrow.counterclockwise", action: onReplay)
                        GhostButton(title: "Conduit", systemIcon: "point.3.connected.trianglepath.dotted", action: onConduit)
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { appear = true }
            if result.solved && !isOverdrive {
                for i in 1...max(1, result.stars) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.22) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { starsShown = i }
                        Haptic.light()
                    }
                }
            }
        }
    }

    private func row(_ icon: String, _ k: String, _ v: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(Palette.brass)
            Text(k).font(Typo.body(14)).foregroundColor(Palette.text2)
            Spacer()
            Text(v).font(Typo.display(17)).foregroundColor(Palette.text)
        }
        .padding(.vertical, 10)
    }

    private func timeString(_ s: Double) -> String {
        let t = Int(s)
        return String(format: "%d:%02d", t / 60, t % 60)
    }
}

/// Radiant celebration rays.
struct RaysView: View {
    var body: some View {
        GeometryReader { geo in
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let r = min(geo.size.width, geo.size.height) / 2
            Path { p in
                for i in 0..<16 {
                    let a = CGFloat(i) / 16 * 2 * .pi
                    p.move(to: c)
                    p.addLine(to: CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r))
                }
            }
            .stroke(Palette.power, lineWidth: 1.4)
        }
    }
}
