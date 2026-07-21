import SwiftUI

struct FoundryView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var router: AppRouter

    private var records: [AchievementRecord] { store.achievements() }
    private var forged: Int { records.filter { $0.unlocked }.count }
    private let cols = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack {
            SceneBackground()

            VStack(spacing: 0) {
                ScreenHeader(eyebrow: "Earned marques", title: "The Foundry",
                             onBack: { router.backToMenu() })

                // summary strip
                HStack(spacing: 14) {
                    GearView(material: .brass).frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.5), radius: 3, y: 2)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Marques forged").font(Typo.plate(9)).tracking(1.4).textCase(.uppercase).foregroundColor(Palette.text3)
                        HStack(spacing: 3) {
                            Text("\(forged)").font(Typo.display(22)).foregroundColor(Palette.text)
                            Text("/ \(records.count)").font(Typo.bodyBold(13)).foregroundColor(Palette.brass)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("Gears meshed").font(Typo.plate(9)).tracking(1.4).textCase(.uppercase).foregroundColor(Palette.text3)
                        Text("\(Int(store.stats().totalGearsMeshed))").font(Typo.display(22)).foregroundColor(Palette.text)
                    }
                }
                .padding(.horizontal, 20).frame(height: 66)
                .background(RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [Palette.surface2.opacity(0.9), Palette.bg.opacity(0.94)], startPoint: .top, endPoint: .bottom)))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Palette.brass.opacity(0.3), lineWidth: 1))
                .premiumShadow()
                .padding(.horizontal, 20).padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: cols, spacing: 14) {
                        ForEach(Array(records.enumerated()), id: \.element.objectID) { pair in
                            MarqueBadge(record: pair.element)
                                .modifier(StaggerIn(index: pair.offset))
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 16)
                    Spacer(minLength: 110)
                }
            }
        }
    }
}

/// Stagger-in on first appearance.
private struct StaggerIn: ViewModifier {
    let index: Int
    @State private var shown = false
    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 16)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05)) {
                    shown = true
                }
            }
    }
}

private struct MarqueBadge: View {
    let record: AchievementRecord

    private var on: Bool { record.unlocked }
    private var progress: Double { min(1, record.target > 0 ? record.progress / record.target : 0) }
    private var icon: String {
        switch record.key ?? "" {
        case "first_bite": return "gearshape.2.fill"
        case "clean_machine": return "sparkles"
        case "overdrive_30k": return "bolt.fill"
        case "no_jam": return "checkmark.shield.fill"
        case "full_train": return "gearshape.fill"
        case "master_wright": return "crown.fill"
        case "warm_up": return "flag.fill"
        case "conduit_5", "conduit_12": return "point.3.connected.trianglepath.dotted"
        case "spinner": return "tornado"
        case "tinkerer": return "hammer.fill"
        case "marathon": return "hourglass"
        default: return "star.fill"
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(on
                          ? AnyShapeStyle(RadialGradient(colors: [Color(hex: "#FFE7B4"), Palette.brass, Color(hex: "#8A5410")],
                                                         center: .init(x: 0.38, y: 0.30), startRadius: 2, endRadius: 60))
                          : AnyShapeStyle(RadialGradient(colors: [Color(hex: "#1D5058"), Color(hex: "#0E2C31")],
                                                         center: .init(x: 0.38, y: 0.30), startRadius: 2, endRadius: 60)))
                    .frame(width: 78, height: 78)
                Circle().strokeBorder(on ? Palette.brassHi : Palette.steelEdge.opacity(0.6), lineWidth: 2)
                    .frame(width: 78, height: 78)
                Image(systemName: icon).font(.system(size: 30, weight: .medium))
                    .foregroundColor(on ? Palette.engrave : Palette.steel)
            }
            .shadow(color: on ? Palette.brass.opacity(0.5) : .black.opacity(0.4), radius: on ? 16 : 6, y: 5)

            Text(record.title ?? "")
                .font(Typo.plate(12)).tracking(0.6).textCase(.uppercase)
                .foregroundColor(on ? Palette.text : Palette.text2)
                .lineLimit(1).minimumScaleFactor(0.7)
            Text(record.detail ?? "")
                .font(Typo.body(11)).foregroundColor(Palette.text3)
                .multilineTextAlignment(.center).lineLimit(2)
                .frame(height: 30, alignment: .top)

            if on {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 11)).foregroundColor(Palette.power)
                    Text("Forged").font(Typo.plate(10)).tracking(1.2).textCase(.uppercase).foregroundColor(Palette.power)
                }
            } else if progress > 0 {
                VStack(spacing: 5) {
                    ZStack(alignment: .leading) {
                        Capsule().fill(Palette.abyss.opacity(0.6)).frame(height: 6)
                        Capsule().fill(LinearGradient(colors: [Palette.brassDeep, Palette.brassHi], startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(6, 120 * progress), height: 6)
                    }
                    .frame(maxWidth: .infinity)
                    Text(progressLabel).font(Typo.display(11)).foregroundColor(Palette.brass)
                }
            } else {
                Text("Locked").font(Typo.plate(10)).tracking(1.2).textCase(.uppercase).foregroundColor(Palette.text3)
            }
        }
        .padding(.vertical, 16).padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 210)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: on ? [Color(hex: "#283A32").opacity(0.6), Color(hex: "#142220").opacity(0.85)]
                                                : [Palette.surface2.opacity(0.55), Palette.bg.opacity(0.8)],
                                     startPoint: .top, endPoint: .bottom))
        )
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(on ? Palette.brass.opacity(0.45) : Palette.hairline, lineWidth: 1))
        .premiumShadow()
    }

    private var progressLabel: String {
        let cur = Int(record.progress), tgt = Int(record.target)
        return "\(min(cur, tgt)) / \(tgt)"
    }
}
