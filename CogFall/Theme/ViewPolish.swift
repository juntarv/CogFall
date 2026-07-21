import SwiftUI

extension View {
    /// Layered depth shadow on every content card.
    func premiumShadow(intensity: Double = 1.0) -> some View {
        self
            .shadow(color: .black.opacity(0.08 * intensity), radius: 2, y: 1)
            .shadow(color: .black.opacity(0.40 * intensity), radius: 16, y: 8)
    }

    /// Engraved plate eyebrow style (uppercase, tracked Copperplate).
    func eyebrow(_ color: Color = Palette.brass) -> some View {
        self
            .font(Typo.plate(12))
            .tracking(3)
            .textCase(.uppercase)
            .foregroundColor(color)
    }

    /// Double text shadow so short titles lift off decorated backgrounds.
    func liftedText() -> some View {
        self
            .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}

/// Full-screen themed background scene: teal wash + warm floor glow + grain + vignette.
struct SceneBackground: View {
    var glow: Bool = true
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Palette.sceneWash()
                    .frame(width: geo.size.width, height: geo.size.height)
                if glow {
                    RadialGradient(
                        colors: [Palette.power.opacity(0.16), .clear],
                        center: UnitPoint(x: 0.5, y: 1.12), startRadius: 20, endRadius: 460)
                }
                // inner vignette
                RadialGradient(colors: [.clear, .black.opacity(0.55)],
                               center: .center, startRadius: 180, endRadius: 560)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .allowsHitTesting(false)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }
}

/// Frosted glass card surface consistent with the design language.
struct GlassCard<Content: View>: View {
    var corner: CGFloat = 22
    var padding: CGFloat = 20
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.surface2.opacity(0.62),
                                                  Palette.bg.opacity(0.82)],
                                         startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(Palette.hairline, lineWidth: 1)
            )
            .premiumShadow()
    }
}
