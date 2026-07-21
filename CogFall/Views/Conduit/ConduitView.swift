import SwiftUI

struct ConduitView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var router: AppRouter

    private var levels: [MechanismLevel] { store.levels() }
    private var completed: Int { levels.filter { $0.completed }.count }

    var body: some View {
        ZStack {
            SceneBackground()

            VStack(spacing: 0) {
                ScreenHeader(eyebrow: "Campaign", title: "The Conduit",
                             onBack: { router.backToMenu() },
                             trailing: AnyView(
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text("Mechanisms").font(Typo.plate(9)).tracking(1.4).textCase(.uppercase).foregroundColor(Palette.text3)
                                    Text("\(completed) / \(levels.count)").font(Typo.display(20)).foregroundColor(Palette.brass)
                                }
                             ))

                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .top) {
                        // central conduit rail
                        Rectangle()
                            .fill(Palette.teal.opacity(0.5))
                            .frame(width: 12)
                            .overlay(Rectangle().fill(Palette.brass.opacity(0.18))
                                .frame(width: 2))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)

                        VStack(spacing: 26) {
                            ForEach(Array(levels.enumerated()), id: \.element.objectID) { pair in
                                ConduitNode(level: pair.element, side: pair.offset % 2 == 0 ? .trailing : .leading) {
                                    tap(pair.element)
                                }
                            }
                        }
                        .padding(.top, 24)
                        .padding(.horizontal, 20)
                    }
                    Spacer(minLength: 120)
                }

                Spacer(minLength: 0)
            }

            // Overdrive endless rail (fixed bottom)
            VStack {
                Spacer()
                OverdriveRail(high: Int(store.stats().bestOverdriveScore)) {
                    router.play(GameConfig(mode: .overdrive, levelIndex: 0))
                }
                .padding(.horizontal, 20).padding(.bottom, 30)
            }
        }
    }

    private func tap(_ level: MechanismLevel) {
        if level.unlocked {
            router.play(GameConfig(mode: .campaign, levelIndex: Int(level.levelIndex)))
        } else {
            Haptic.warning()
        }
    }
}

private struct ConduitNode: View {
    let level: MechanismLevel
    let side: HorizontalAlignment
    var action: () -> Void

    private var isCurrent: Bool { level.unlocked && !level.completed }

    var body: some View {
        HStack {
            if side == .leading { content; Spacer() } else { Spacer(); content }
        }
    }

    private var content: some View {
        Button(action: { Haptic.light(); action() }) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color(hex: "#1D5058"), Color(hex: "#0E2C31")],
                                             center: .init(x: 0.38, y: 0.30), startRadius: 2, endRadius: 90))
                        .frame(width: isCurrent ? 100 : 84, height: isCurrent ? 100 : 84)
                    Circle().strokeBorder(borderColor, lineWidth: 2)
                        .frame(width: isCurrent ? 100 : 84, height: isCurrent ? 100 : 84)
                    GearView(material: level.completed ? .brass : (level.unlocked ? .brass : .dark))
                        .frame(width: isCurrent ? 66 : 56, height: isCurrent ? 66 : 56)
                        .opacity(level.unlocked ? 1 : 0.7)

                    // number badge
                    Text(String(format: "%02d", Int(level.levelIndex)))
                        .font(Typo.display(12)).foregroundColor(Palette.engrave)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Capsule().fill(Palette.brassPlate))
                        .offset(x: 34, y: -34)

                    if !level.unlocked {
                        Image(systemName: "lock.fill").font(.system(size: 12))
                            .foregroundColor(Palette.text2)
                            .padding(6)
                            .background(Circle().fill(Palette.bg))
                            .overlay(Circle().strokeBorder(Palette.steelEdge, lineWidth: 1))
                            .offset(x: 30, y: 30)
                    }
                }
                .shadow(color: isCurrent ? Palette.power.opacity(0.5) : .black.opacity(0.5),
                        radius: isCurrent ? 22 : 10, y: 6)

                Text(level.name ?? "Bay")
                    .font(Typo.plate(11)).tracking(1).textCase(.uppercase)
                    .foregroundColor(level.unlocked ? Palette.text : Palette.text3)
                    .lineLimit(1).minimumScaleFactor(0.7)

                if level.completed {
                    StarRow(count: Int(level.bestStars))
                } else if isCurrent {
                    Text("Resume")
                        .font(Typo.plate(10)).tracking(1).textCase(.uppercase).foregroundColor(Palette.engrave)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Capsule().fill(Palette.brassPlate))
                        .shadow(color: Palette.brass.opacity(0.4), radius: 8, y: 3)
                }
            }
            .frame(width: 150)
        }
        .buttonStyle(.plain)
    }

    private var borderColor: Color {
        if isCurrent { return Palette.power }
        if level.completed { return Palette.brass.opacity(0.55) }
        return Palette.steelEdge.opacity(0.7)
    }
}

struct StarRow: View {
    var count: Int
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < count ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundColor(i < count ? Palette.brass : Palette.text3.opacity(0.5))
            }
        }
    }
}

private struct OverdriveRail: View {
    var high: Int
    var action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: { Haptic.medium(); action() }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(RadialGradient(colors: [Palette.rust, Palette.rustDeep],
                                                 center: .init(x: 0.4, y: 0.32), startRadius: 1, endRadius: 40))
                        .frame(width: 56, height: 56)
                    Image(systemName: "bolt.fill").font(.system(size: 24)).foregroundColor(Color(hex: "#FFE7B4"))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Endless mode").font(Typo.plate(9)).tracking(1.6).textCase(.uppercase).foregroundColor(Color(hex: "#FFB98C"))
                    Text("Overdrive").font(Typo.display(22)).foregroundColor(Palette.text)
                    Text("Keep it spinning · high \(high)").font(Typo.body(11)).foregroundColor(Palette.text2)
                        .lineLimit(1).minimumScaleFactor(0.7)
                }
                Spacer()
                Text("Run").font(Typo.display(15)).textCase(.uppercase).foregroundColor(Palette.engrave)
                    .padding(.horizontal, 18).padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Palette.brassPlate))
                    .shadow(color: Palette.brass.opacity(0.4), radius: 8, y: 3)
            }
            .padding(.horizontal, 20)
            .frame(height: 88)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: "#3F2014").opacity(0.94), Color(hex: "#1E0F09").opacity(0.96)],
                                         startPoint: .top, endPoint: .bottom))
            )
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Palette.brass.opacity(0.4), lineWidth: 1))
            .premiumShadow()
            .scaleEffect(pressed ? 0.98 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { pressed = true } }
            .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { pressed = false } })
    }
}
