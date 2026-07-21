import SwiftUI

/// Primary brass CTA plate — engraved label, top/bottom bevels, pressed scale + haptic.
struct BrassButton: View {
    let title: String
    var systemIcon: String? = nil
    var trailingIcon: String? = nil
    var height: CGFloat = 60
    var action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: { Haptic.medium(); action() }) {
            HStack(spacing: 10) {
                if let icon = systemIcon {
                    Image(systemName: icon).font(.system(size: 16, weight: .bold))
                        .foregroundColor(Palette.engrave)
                }
                Text(title)
                    .font(Typo.display(19)).tracking(1).textCase(.uppercase)
                    .foregroundColor(Palette.engrave)
                    .lineLimit(1).minimumScaleFactor(0.7)
                if let t = trailingIcon {
                    Image(systemName: t).font(.system(size: 16, weight: .bold))
                        .foregroundColor(Palette.engrave)
                }
            }
            .frame(maxWidth: .infinity, minHeight: height)
            .background(
                ZStack {
                    Palette.brassPlate
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            LinearGradient(colors: [.white.opacity(0.55), Palette.brassEdge.opacity(0.6)],
                                           startPoint: .top, endPoint: .bottom), lineWidth: 1)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Palette.brass.opacity(0.4), radius: 16, y: 7)
            .shadow(color: .black.opacity(0.45), radius: 4, y: 2)
            .scaleEffect(pressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { pressed = false } }
        )
    }
}

/// Circular themed art button (settings / how-to corners, secondary actions).
struct CircleArtButton: View {
    var systemIcon: String
    var size: CGFloat = 48
    var tint: Color = Palette.brassHi
    var borderColor: Color = Palette.brass.opacity(0.5)
    var action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: { Haptic.light(); action() }) {
            ZStack {
                Circle().fill(
                    RadialGradient(colors: [Color(hex: "#1D4C53"), Color(hex: "#0D2A2F")],
                                   center: UnitPoint(x: 0.38, y: 0.30), startRadius: 2, endRadius: size))
                Circle().strokeBorder(borderColor, lineWidth: 1.5)
                Image(systemName: systemIcon)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundColor(tint)
            }
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
            .scaleEffect(pressed ? 0.9 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { pressed = false } }
        )
    }
}

/// Ghost / secondary pill button with subtle surface.
struct GhostButton: View {
    let title: String
    var systemIcon: String? = nil
    var tint: Color = Palette.text
    var height: CGFloat = 54
    var action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: { Haptic.light(); action() }) {
            HStack(spacing: 9) {
                if let icon = systemIcon {
                    Image(systemName: icon).font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Palette.brassHi)
                }
                Text(title).font(Typo.plate(13)).tracking(1.4).textCase(.uppercase)
                    .foregroundColor(tint).lineLimit(1).minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, minHeight: height)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Palette.surface2.opacity(0.6))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Palette.hairline, lineWidth: 1))
            )
            .scaleEffect(pressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { pressed = false } }
        )
    }
}
