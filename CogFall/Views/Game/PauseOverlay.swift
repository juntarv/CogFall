import SwiftUI

struct PauseOverlay: View {
    @ObservedObject var vm: GameViewModel
    var onResume: () -> Void
    var onRestart: () -> Void
    var onQuit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 0) {
                ZStack {
                    GearView(material: .brass).frame(width: 108, height: 108)
                        .shadow(color: Palette.power.opacity(0.4), radius: 22)
                    HStack(spacing: 7) {
                        Capsule().fill(Palette.bg).frame(width: 10, height: 32)
                        Capsule().fill(Palette.bg).frame(width: 10, height: 32)
                    }
                }
                .padding(.bottom, 6)

                Text(vm.bayTitle.uppercased()).eyebrow().padding(.top, 4)
                Text("Paused").font(Typo.display(40)).foregroundColor(Palette.text).liftedText()
                Text("The mainspring holds. Catch your breath.")
                    .font(Typo.body(13)).foregroundColor(Palette.text2).padding(.top, 2)

                HStack(spacing: 0) {
                    statCell("Score", "\(vm.score)")
                    Divider().frame(height: 30).background(Palette.hairline)
                    statCell("Gears", "\(vm.gearsUsed)")
                    Divider().frame(height: 30).background(Palette.hairline)
                    statCell("Powered", timeString(vm.poweredSeconds))
                }
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(Capsule().fill(Palette.abyss.opacity(0.6)))
                .overlay(Capsule().strokeBorder(Palette.hairline, lineWidth: 1))
                .padding(.vertical, 20)

                VStack(spacing: 12) {
                    BrassButton(title: "Resume", systemIcon: "play.fill", height: 60, action: onResume)
                    GhostButton(title: "Restart bay", systemIcon: "arrow.counterclockwise", height: 56, action: onRestart)
                    Button(action: { Haptic.medium(); onQuit() }) {
                        HStack(spacing: 9) {
                            Image(systemName: "xmark.circle.fill").font(.system(size: 15))
                            Text("Quit to Conduit").font(Typo.plate(13)).tracking(1.2).textCase(.uppercase)
                        }
                        .foregroundColor(Color(hex: "#FFB98C"))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#421A10").opacity(0.55)))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Palette.rust.opacity(0.45), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.surface2.opacity(0.9), Palette.bg.opacity(0.96)], startPoint: .top, endPoint: .bottom))
            )
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).strokeBorder(Palette.brass.opacity(0.28), lineWidth: 1))
            .premiumShadow(intensity: 1.4)
            .padding(.horizontal, 28)
        }
    }

    private func statCell(_ k: String, _ v: String) -> some View {
        VStack(spacing: 2) {
            Text(k).font(Typo.plate(9)).tracking(1.2).textCase(.uppercase).foregroundColor(Palette.text3)
            Text(v).font(Typo.display(18)).foregroundColor(Palette.text)
        }
        .padding(.horizontal, 12)
    }

    private func timeString(_ s: Double) -> String {
        let t = Int(s)
        return String(format: "%d:%02d", t / 60, t % 60)
    }
}
