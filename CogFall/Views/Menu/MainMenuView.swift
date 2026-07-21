import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var router: AppRouter
    @State private var showHelp = false
    @State private var glow = false

    private var currentBay: Int {
        let ls = store.levels()
        if let firstOpen = ls.first(where: { $0.unlocked && !$0.completed }) { return Int(firstOpen.levelIndex) }
        if let lastUnlocked = ls.last(where: { $0.unlocked }) { return Int(lastUnlocked.levelIndex) }
        return 1
    }
    private var completedCount: Int { store.levels().filter { $0.completed }.count }
    private var bestStars: Int { Int(store.levels().map { $0.bestStars }.max() ?? 0) }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                SceneBackground()

                // ambient decor
                RotatingGear(material: .dark, duration: 40)
                    .frame(width: 230, height: 230).opacity(0.18)
                    .position(x: 40, y: 70)
                RotatingGear(material: .dark, duration: 55, clockwise: false)
                    .frame(width: 200, height: 200).opacity(0.14)
                    .position(x: 350, y: 560)

                VStack(spacing: 0) {
                    // top corners
                    HStack {
                        CircleArtButton(systemIcon: "questionmark", size: 48) { showHelp = true }
                        Spacer()
                        CircleArtButton(systemIcon: "gearshape.fill", size: 48) { router.go(.settings) }
                    }
                    .padding(.horizontal, 24).padding(.top, 16)

                    // logo
                    ZStack {
                        RotatingGear(material: .brass, duration: 26)
                            .frame(width: 150, height: 150).opacity(0.4)
                            .shadow(color: Palette.power.opacity(0.35), radius: 24)
                            .offset(y: -6)
                        VStack(spacing: 14) {
                            Text("COGFALL")
                                .font(Typo.display(58))
                                .foregroundStyle(Palette.brassPlate)
                                .liftedText()
                            Text("Drop · Mesh · Power the machine")
                                .font(Typo.plate(10)).tracking(2.5).textCase(.uppercase)
                                .foregroundColor(Palette.text2)
                                .padding(.horizontal, 16).padding(.vertical, 7)
                                .background(Capsule().fill(Palette.abyss.opacity(0.5)))
                                .overlay(Capsule().strokeBorder(Palette.hairline, lineWidth: 1))
                        }
                    }
                    .padding(.top, 22)

                    Spacer(minLength: 8)

                    // PLAY plate
                    MenuPlayPlate(subtitle: "Campaign · Bay \(String(format: "%02d", currentBay)) ready", glow: glow) {
                        router.play(GameConfig(mode: .campaign, levelIndex: currentBay))
                    }
                    .padding(.horizontal, 32)

                    // medallions
                    HStack(spacing: 20) {
                        MenuMedallion(title: "Conduit", subtitle: "Level map", icon: "point.3.connected.trianglepath.dotted") {
                            router.go(.conduit)
                        }
                        MenuMedallion(title: "Foundry", subtitle: "Achievements", icon: "medal.fill") {
                            router.go(.foundry)
                        }
                    }
                    .padding(.horizontal, 32).padding(.top, 22)

                    Spacer(minLength: 12)

                    // best rail
                    BestRail(completed: completedCount, stars: bestStars,
                             overdrive: Int(store.stats().bestOverdriveScore),
                             gears: Int(store.stats().totalGearsMeshed))
                        .padding(.horizontal, 24).padding(.bottom, 30)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { glow = true }
            }
            .sheet(isPresented: $showHelp) { HelpSheet() }
        }
    }
}

private struct MenuPlayPlate: View {
    var subtitle: String
    var glow: Bool
    var action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: { Haptic.medium(); action() }) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subtitle)
                        .font(Typo.plate(10)).tracking(2).textCase(.uppercase)
                        .foregroundColor(Color(hex: "#6E430E"))
                        .lineLimit(1).minimumScaleFactor(0.7)
                    Text("PLAY")
                        .font(Typo.display(40))
                        .foregroundColor(Palette.engrave)
                }
                Spacer()
                ZStack {
                    Circle().fill(RadialGradient(colors: [Color(hex: "#3A2408"), Color(hex: "#1C1204")],
                                                 center: .init(x: 0.4, y: 0.32), startRadius: 1, endRadius: 30))
                        .frame(width: 56, height: 56)
                    Image(systemName: "play.fill").font(.system(size: 22)).foregroundColor(Palette.brassHi)
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, minHeight: 96)
            .background(
                ZStack {
                    Palette.brassPlate
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(LinearGradient(colors: [.white.opacity(0.55), Palette.brassEdge.opacity(0.6)],
                                                     startPoint: .top, endPoint: .bottom), lineWidth: 1)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Palette.brass.opacity(glow ? 0.55 : 0.35), radius: glow ? 22 : 14, y: 8)
            .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
            .scaleEffect(pressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { pressed = true } }
            .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { pressed = false } })
    }
}

private struct MenuMedallion: View {
    var title: String
    var subtitle: String
    var icon: String
    var action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: { Haptic.light(); action() }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle().fill(RadialGradient(colors: [Color(hex: "#1D5058"), Color(hex: "#0E2C31")],
                                                 center: .init(x: 0.38, y: 0.30), startRadius: 2, endRadius: 120))
                        .frame(width: 116, height: 116)
                    Circle().strokeBorder(Palette.brass.opacity(0.55), lineWidth: 2).frame(width: 116, height: 116)
                    Circle().strokeBorder(Palette.brass.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [3, 5]))
                        .frame(width: 98, height: 98)
                    Image(systemName: icon).font(.system(size: 42, weight: .regular)).foregroundColor(Palette.brass)
                }
                .shadow(color: .black.opacity(0.5), radius: 12, y: 6)
                VStack(spacing: 1) {
                    Text(title).font(Typo.plate(12)).tracking(1.4).textCase(.uppercase).foregroundColor(Palette.text)
                    Text(subtitle).font(Typo.body(11)).foregroundColor(Palette.text2)
                }
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(pressed ? 0.95 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { pressed = true } }
            .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { pressed = false } })
    }
}

private struct BestRail: View {
    var completed: Int
    var stars: Int
    var overdrive: Int
    var gears: Int

    var body: some View {
        HStack(spacing: 14) {
            GearView(material: .brass).frame(width: 44, height: 44)
                .shadow(color: .black.opacity(0.5), radius: 3, y: 2)
            VStack(alignment: .leading, spacing: 1) {
                Text("Best mechanism").font(Typo.plate(9)).tracking(1.6).textCase(.uppercase).foregroundColor(Palette.text3)
                HStack(spacing: 3) {
                    Text("\(completed)").font(Typo.display(24)).foregroundColor(Palette.text)
                    Text("×\(stars)★").font(Typo.bodyBold(12)).foregroundColor(Palette.brass)
                }
            }
            Rectangle().fill(Palette.hairline).frame(width: 1, height: 40)
            VStack(alignment: .leading, spacing: 1) {
                Text("Overdrive high").font(Typo.plate(9)).tracking(1.6).textCase(.uppercase).foregroundColor(Palette.text3)
                Text("\(overdrive)").font(Typo.display(22)).foregroundColor(Palette.text)
                    .contentTransition(.numericText())
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text("Gears meshed").font(Typo.plate(9)).tracking(1.6).textCase(.uppercase).foregroundColor(Palette.text3)
                Text("\(gears)").font(Typo.display(22)).foregroundColor(Palette.text)
                    .contentTransition(.numericText())
            }
        }
        .padding(.horizontal, 22)
        .frame(height: 78)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [Palette.surface2.opacity(0.94), Palette.bg.opacity(0.96)],
                                     startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Palette.brass.opacity(0.32), lineWidth: 1)
                .mask(RoundedRectangle(cornerRadius: 18).stroke(lineWidth: 1).padding(.bottom, 60))
        )
        .premiumShadow()
    }
}

private struct HelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            SceneBackground()
            VStack(alignment: .leading, spacing: 18) {
                Text("How to play").eyebrow()
                Text("Build the machine")
                    .font(Typo.display(30)).foregroundColor(Palette.text).liftedText()
                HelpRow(icon: "hand.tap.fill", title: "Aim & drop", text: "Drag to aim the held gear, tap Drop to release it into the bay.")
                HelpRow(icon: "gearshape.2.fill", title: "Mesh", text: "Land a gear within a tooth's reach of the powered train so it locks on.")
                HelpRow(icon: "bolt.fill", title: "Power", text: "Chain gears from the glowing spindle to every target lamp to win the bay.")
                HelpRow(icon: "flame.fill", title: "Watch the heat", text: "Loose gears that never connect raise Heat. Fill it and the bay resets.")
                Spacer()
                BrassButton(title: "Got it", height: 60) { dismiss() }
            }
            .padding(24)
        }
    }
}

private struct HelpRow: View {
    var icon: String
    var title: String
    var text: String
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Palette.surface2.opacity(0.7))
                    .frame(width: 44, height: 44)
                Image(systemName: icon).foregroundColor(Palette.brassHi).font(.system(size: 18, weight: .semibold))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(Typo.bodyBold(16)).foregroundColor(Palette.text)
                Text(text).font(Typo.body(13)).foregroundColor(Palette.text2).lineSpacing(2)
            }
        }
    }
}
