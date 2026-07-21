import SwiftUI
import SpriteKit

struct GamePlayView: View {
    let config: GameConfig
    @EnvironmentObject var store: Store
    @EnvironmentObject var router: AppRouter
    @StateObject private var vm: GameViewModel
    @State private var wired = false

    init(config: GameConfig) {
        self.config = config
        _vm = StateObject(wrappedValue: GameViewModel(config: config))
    }

    var body: some View {
        ZStack {
            SpriteView(scene: vm.scene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HUDBar(vm: vm) { vm.pause() }
                Spacer(minLength: 0)
                GearTray(vm: vm) { vm.drop() }
            }

            if vm.showPause {
                PauseOverlay(vm: vm,
                             onResume: { vm.resume() },
                             onRestart: { vm.restart() },
                             onQuit: { router.go(.conduit) })
                    .transition(.opacity)
            }

            if vm.showResult, let result = vm.result {
                ResultsOverlay(result: result,
                               onPrimary: { primaryAction(result) },
                               onReplay: { vm.restart() },
                               onConduit: { router.go(.conduit) })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.showPause)
        .animation(.easeInOut(duration: 0.3), value: vm.showResult)
        .onAppear {
            guard !wired else { return }
            wired = true
            if !Launch.screenshotTour {
                vm.onFinish = { [store] r in store.persist(r) }
            }
        }
    }

    private func primaryAction(_ r: GameResult) {
        if r.mode == .campaign && r.solved {
            let next = min(24, r.levelIndex + 1)
            router.play(GameConfig(mode: .campaign, levelIndex: next))
        } else {
            vm.restart()
        }
    }
}

// MARK: - HUD
private struct HUDBar: View {
    @ObservedObject var vm: GameViewModel
    var onPause: () -> Void
    @State private var pulse = false

    private var overloaded: Bool { vm.load > vm.capacity }

    var body: some View {
        // Side clusters sit in the HStack; the score is centred on the SCREEN via
        // an overlay so it never drifts with the differing widths of the sides.
        HStack(spacing: 10) {
            bayChip
            Spacer(minLength: 0)
            heatMeter
            pauseButton
        }
        .overlay(scoreBlock)
        .padding(.horizontal, 16)
        .frame(height: 54)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) { pulse = true }
        }
    }

    private var bayChip: some View {
        VStack(spacing: 1) {
            Text(vm.config.mode == .overdrive ? "Mode" : "Bay")
                .font(Typo.plate(9)).tracking(1.4).textCase(.uppercase).foregroundColor(Palette.text3)
            Text(vm.bayLabel).font(Typo.display(16)).foregroundColor(Palette.text)
        }
        .frame(width: 54, height: 46)
        .background(hudChip)
    }

    private var scoreBlock: some View {
        VStack(spacing: 0) {
            Text("\(vm.score)")
                .font(Typo.display(30)).foregroundColor(Palette.text)
                .lineLimit(1).minimumScaleFactor(0.6)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.score)
                .liftedText()
            Text(String(format: "×%.1f spin", vm.multiplier))
                .font(Typo.plate(10)).tracking(1.6).textCase(.uppercase).foregroundColor(Palette.brass)
                .lineLimit(1).fixedSize()
        }
        .frame(width: 150)
        .allowsHitTesting(false)
    }

    private var heatMeter: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Naming the cause teaches the system: heat climbs because the spindle
            // is turning more gears than it has torque for.
            Text(overloaded ? "Overload" : "Heat")
                .font(Typo.plate(9)).tracking(1).textCase(.uppercase)
                .foregroundColor(overloaded ? Palette.brassHi : Palette.rust)
                .lineLimit(1).minimumScaleFactor(0.75)
                .opacity(overloaded && pulse ? 0.45 : 1)
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.abyss.opacity(0.6))
                Capsule().fill(LinearGradient(colors: [Palette.brass, Palette.rust], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(3, 54 * vm.heat))
                    .animation(.easeOut(duration: 0.3), value: vm.heat)
            }
            .frame(width: 54, height: 7)
            .overlay(Capsule().strokeBorder(Palette.rust.opacity(0.35), lineWidth: 1))
        }
        .frame(width: 54, height: 46, alignment: .trailing)
    }

    private var pauseButton: some View {
        Button(action: { Haptic.light(); onPause() }) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous).fill(hudChipStyle)
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Palette.brass.opacity(0.4), lineWidth: 1)
                Image(systemName: "pause.fill").font(.system(size: 17)).foregroundColor(Palette.brassHi)
            }
            .frame(width: 46, height: 46)
        }
        .buttonStyle(.plain)
    }

    private var hudChipStyle: LinearGradient {
        LinearGradient(colors: [Palette.surface2.opacity(0.92), Palette.bg.opacity(0.95)], startPoint: .top, endPoint: .bottom)
    }
    private var hudChip: some View {
        RoundedRectangle(cornerRadius: 14).fill(hudChipStyle)
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Palette.hairline, lineWidth: 1))
    }
}

// MARK: - Tray
private struct GearTray: View {
    @ObservedObject var vm: GameViewModel
    var onDrop: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            inHand
            Rectangle().fill(Palette.hairline).frame(width: 1, height: 62)
            nextUp
            DropButton(enabled: vm.state == .aiming, action: onDrop)
        }
        .padding(.horizontal, 14)
        .frame(height: 116)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: [Palette.surface2.opacity(0.92), Palette.bg.opacity(0.96)], startPoint: .top, endPoint: .bottom))
        )
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))
        .premiumShadow()
        .padding(.horizontal, 16).padding(.bottom, 24)
    }

    // Fixed-width so the flexible NEXT UP lane, not this block, absorbs slack.
    private var inHand: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(RadialGradient(colors: [Color(hex: "#1D5058"), Color(hex: "#0E2C31")],
                                             center: .init(x: 0.4, y: 0.32), startRadius: 2, endRadius: 48))
                Circle().strokeBorder(Palette.brass.opacity(0.25), lineWidth: 2)
                // Feed clock — drains while you aim, then the gear drops itself.
                Circle()
                    .trim(from: 0, to: vm.shotFraction)
                    .stroke(vm.shotFraction < 0.3 ? Palette.rust : Palette.brass,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.2), value: vm.shotFraction)
                GearView(material: .brass).frame(width: 46, height: 46)
            }
            .frame(width: 66, height: 66)
            .shadow(color: Palette.brass.opacity(0.3), radius: 10)
            Text(inHandCaption)
                .font(Typo.plate(9)).tracking(1.2).textCase(.uppercase)
                .foregroundColor(Palette.brass)
                .lineLimit(1).minimumScaleFactor(0.7)
        }
        .frame(width: 76)
    }

    private var inHandCaption: String {
        vm.gearsLeft >= 0 ? "\(vm.inHand.label) · \(vm.gearsLeft) left" : "In hand · \(vm.inHand.label)"
    }

    private var nextUp: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Next up").font(Typo.plate(9)).tracking(1.8).textCase(.uppercase)
                .foregroundColor(Palette.text3).lineLimit(1)
            HStack(spacing: 8) {
                ForEach(Array(vm.queuePreview.enumerated()), id: \.offset) { pair in
                    ZStack {
                        RoundedRectangle(cornerRadius: 11, style: .continuous).fill(Palette.abyss.opacity(0.5))
                        RoundedRectangle(cornerRadius: 11, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1)
                        GearView(material: pair.offset == 0 ? .brass : .steel)
                            .frame(width: sizeFor(pair.element), height: sizeFor(pair.element))
                    }
                    .frame(width: 38, height: 38)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sizeFor(_ s: GearSize) -> CGFloat {
        switch s { case .small: return 22; case .medium: return 28; case .large: return 34 }
    }
}

private struct DropButton: View {
    var enabled: Bool
    var action: () -> Void
    @State private var pressed = false
    var body: some View {
        Button(action: { if enabled { Haptic.light(); action() } }) {
            Text("Drop")
                .font(Typo.display(16)).tracking(1.4).textCase(.uppercase)
                .foregroundColor(Palette.engrave)
                // Never let the tray squeeze the label into a stack of letters.
                .lineLimit(1).fixedSize()
                .frame(width: 88, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.brassPlate)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Palette.brass.opacity(enabled ? 0.45 : 0), radius: 10, y: 3)
                .opacity(enabled ? 1 : 0.45)
                .saturation(enabled ? 1 : 0.4)
                .scaleEffect(pressed && enabled ? 0.94 : 1)
        }
        .fixedSize()
        .buttonStyle(.plain)
        .disabled(!enabled)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { pressed = true } }
            .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { pressed = false } })
    }
}
