import SwiftUI

/// A 12-tooth cog silhouette (body + teeth unioned via non-zero winding).
struct GearShape: Shape {
    var teeth: Int = 12
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let R = min(rect.width, rect.height) / 2
        let bodyR = R * 0.74
        p.addEllipse(in: CGRect(x: c.x - bodyR, y: c.y - bodyR, width: bodyR * 2, height: bodyR * 2))
        let toothW = R * 0.26
        let toothH = R * 0.30
        for i in 0..<teeth {
            let a = CGFloat(i) / CGFloat(teeth) * 2 * .pi
            let base = Path(roundedRect: CGRect(x: -toothW / 2, y: -R + 1, width: toothW, height: toothH),
                            cornerSize: CGSize(width: toothW * 0.25, height: toothW * 0.25))
            let t = base
                .applying(CGAffineTransform(rotationAngle: a))
                .applying(CGAffineTransform(translationX: c.x, y: c.y))
            p.addPath(t)
        }
        return p
    }
}

/// A rendered brass/steel/dark gear with hub, spokes and optional glow.
struct GearView: View {
    enum Material { case brass, steel, dark, rust }
    var material: Material = .brass
    var glow: Bool = false
    var hubColor: Color = Palette.bg

    private var gradient: AnyShapeStyle {
        switch material {
        case .brass: return AnyShapeStyle(Palette.brassGear)
        case .steel: return AnyShapeStyle(Palette.steelGear)
        case .dark:  return AnyShapeStyle(Palette.darkGear)
        case .rust:  return AnyShapeStyle(RadialGradient(
            colors: [Color(hex: "#FF9E6E"), Palette.rust, Palette.rustDeep],
            center: UnitPoint(x: 0.36, y: 0.30), startRadius: 2, endRadius: 90))
        }
    }

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                GearShape()
                    .fill(gradient)
                Circle()
                    .stroke(Color.black.opacity(0.16), lineWidth: max(1, s * 0.02))
                    .frame(width: s * 0.52, height: s * 0.52)
                SpokesShape()
                    .stroke(Color.black.opacity(0.20), style: StrokeStyle(lineWidth: max(3, s * 0.06), lineCap: .round))
                    .frame(width: s * 0.6, height: s * 0.6)
                Circle().fill(hubColor).frame(width: s * 0.27, height: s * 0.27)
                Circle().stroke(Color.black.opacity(0.5), lineWidth: max(1, s * 0.018))
                    .frame(width: s * 0.27, height: s * 0.27)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .shadow(color: glow ? Palette.power.opacity(0.55) : .clear, radius: glow ? 18 : 0)
        }
    }
}

private struct SpokesShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        for i in 0..<4 {
            let a = CGFloat(i) / 4 * .pi
            let dx = cos(a) * r, dy = sin(a) * r
            p.move(to: CGPoint(x: c.x - dx, y: c.y - dy))
            p.addLine(to: CGPoint(x: c.x + dx, y: c.y + dy))
        }
        return p
    }
}

/// Continuously rotating gear decoration (respects the animations preference).
struct RotatingGear: View {
    var material: GearView.Material = .dark
    var duration: Double = 22
    var clockwise: Bool = true
    var animate: Bool = true
    @State private var spin = false
    var body: some View {
        GearView(material: material)
            .rotationEffect(.degrees(spin ? (clockwise ? 360 : -360) : 0))
            .onAppear {
                guard animate else { return }
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    spin = true
                }
            }
    }
}
