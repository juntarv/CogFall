import SwiftUI

struct OnboardingSlide {
    let eyebrow: String
    let title: String
    let emphasis: String
    let body: String
    let variant: Int
}

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var index = 0

    private let slides: [OnboardingSlide] = [
        .init(eyebrow: "How it works · 1 of 3",
              title: "Drop gears so their teeth",
              emphasis: "bite.",
              body: "Aim, then let a gear fall. When it settles beside another within a tooth's reach, they lock and spin as one.",
              variant: 0),
        .init(eyebrow: "How it works · 2 of 3",
              title: "Build a train to the",
              emphasis: "power spindle.",
              body: "The spindle never stops turning. Chain meshed gears back to it and the whole train comes alive.",
              variant: 1),
        .init(eyebrow: "How it works · 3 of 3",
              title: "Light every target — spare your",
              emphasis: "gears.",
              body: "Reach each target lamp to finish the mechanism. Fewer gears and zero jams earn more stars.",
              variant: 2)
    ]

    private var isLast: Bool { index == slides.count - 1 }

    var body: some View {
        ZStack {
            SceneBackground()

            VStack(spacing: 0) {
                // skip
                HStack {
                    Spacer()
                    Button(action: { Haptic.light(); onComplete() }) {
                        Text("Skip").font(Typo.plate(11)).tracking(2).textCase(.uppercase)
                            .foregroundColor(Palette.text2)
                    }
                    .accessibilityIdentifier("skip_button")
                }
                .padding(.horizontal, 24).padding(.top, 20)

                OnboardingHero(variant: slides[index].variant)
                    .frame(height: 360)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .id(index)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)))

                GlassCard(corner: 22, padding: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(slides[index].eyebrow).eyebrow()
                        (Text(slides[index].title + " ")
                            .foregroundColor(Palette.text)
                         + Text(slides[index].emphasis)
                            .foregroundColor(Palette.brass))
                            .font(Typo.display(30))
                            .lineSpacing(2)
                        Text(slides[index].body)
                            .font(Typo.body(15))
                            .foregroundColor(Palette.text2)
                            .lineSpacing(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .id("card\(index)")
                .transition(.opacity)

                Spacer()

                // dots
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Capsule()
                            .fill(i == index
                                  ? AnyShapeStyle(LinearGradient(colors: [Palette.brass, Palette.brassHi], startPoint: .leading, endPoint: .trailing))
                                  : AnyShapeStyle(Palette.text.opacity(0.22)))
                            .frame(width: i == index ? 26 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: index)
                    }
                }
                .padding(.bottom, 18)

                // CTA
                Group {
                    if isLast {
                        BrassButton(title: "Start", trailingIcon: "arrow.right", height: 64) {
                            onComplete()
                        }
                        .accessibilityIdentifier("start_button")
                    } else {
                        BrassButton(title: "Next", trailingIcon: "arrow.right", height: 64) {
                            withAnimation(.easeInOut(duration: 0.35)) { index += 1 }
                        }
                        .accessibilityIdentifier("next_button")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
    }
}

/// Diorama: falling ghost gear → meshed train → glowing spindle & target lamp.
struct OnboardingHero: View {
    var variant: Int
    @State private var drift = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: "#0F353C"), Color(hex: "#0B2429")],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(RoundedRectangle(cornerRadius: 26).strokeBorder(Palette.hairline, lineWidth: 1))
                .premiumShadow()

            GeometryReader { geo in
                let w = geo.size.width, h = geo.size.height
                ZStack {
                    // ghost falling gear (variant 0 emphasises the drop)
                    GearView(material: .brass)
                        .frame(width: 62, height: 62)
                        .opacity(0.55)
                        .position(x: w * 0.34, y: drift ? h * 0.24 : h * 0.16)
                        .shadow(color: Palette.power.opacity(0.4), radius: 10)

                    // meshed train
                    GearView(material: .steel)
                        .frame(width: 84, height: 84)
                        .position(x: w * 0.36, y: h * 0.6)
                    GearView(material: .brass, glow: variant >= 1)
                        .frame(width: 108, height: 108)
                        .position(x: w * 0.56, y: h * 0.68)
                    GearView(material: .brass, glow: variant >= 1)
                        .frame(width: 72, height: 72)
                        .position(x: w * 0.22, y: h * 0.74)

                    // spindle
                    Circle().fill(Palette.power)
                        .frame(width: 12, height: 12)
                        .shadow(color: Palette.power, radius: 10)
                        .position(x: w * 0.56, y: h * 0.88)

                    // target lamp (variant 2 lit)
                    Circle()
                        .fill(variant >= 2 ? Palette.power : Palette.surface2)
                        .frame(width: 26, height: 26)
                        .overlay(Circle().strokeBorder(variant >= 2 ? Palette.brass : Palette.steelEdge, lineWidth: 2))
                        .shadow(color: variant >= 2 ? Palette.power.opacity(0.6) : .clear, radius: 12)
                        .position(x: w * 0.8, y: h * 0.2)

                    Text(variant >= 2 ? "POWERED" : "TARGET")
                        .font(Typo.plate(9)).tracking(1.5)
                        .foregroundColor(variant >= 2 ? Palette.power : Palette.text3)
                        .position(x: w * 0.8, y: h * 0.32)
                }
            }
            .padding(10)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { drift = true }
        }
    }
}
