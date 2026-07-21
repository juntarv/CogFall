import SwiftUI

// MARK: - Color from hex
extension Color {
    init(hex: String, alpha: Double = 1.0) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r, g, b: Double
        if s.count == 6 {
            r = Double((v & 0xFF0000) >> 16) / 255.0
            g = Double((v & 0x00FF00) >> 8) / 255.0
            b = Double(v & 0x0000FF) / 255.0
        } else {
            r = 0; g = 0; b = 0
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Palette (source of truth: design-tokens.css)
enum Palette {
    // dominant: deep teal / oiled metal
    static let abyss     = Color(hex: "#08191C")
    static let bg        = Color(hex: "#0C2529")
    static let surface   = Color(hex: "#123138")
    static let surface2  = Color(hex: "#17414A")
    static let teal      = Color(hex: "#1C6E74")
    static let tealDeep  = Color(hex: "#124A50")

    // accent: brass amber
    static let brass     = Color(hex: "#F2A93B")
    static let brassHi   = Color(hex: "#FFCE7A")
    static let brassDeep = Color(hex: "#B9761E")
    static let brassEdge = Color(hex: "#7A4B12")
    static let power     = Color(hex: "#FFD27A")

    // steel (idle gears)
    static let steel     = Color(hex: "#7C9EA3")
    static let steelEdge = Color(hex: "#274A50")

    // functional-only
    static let rust      = Color(hex: "#C4502E")
    static let rustDeep  = Color(hex: "#7C2E19")

    // text on dark
    static let text      = Color(hex: "#F4E9D6")
    static let text2     = Color(hex: "#93B2B6")
    static let text3     = Color(hex: "#5E7B80")
    static let hairline  = Color(hex: "#F4E9D6", alpha: 0.10)

    // engraved-dark text used on brass plates
    static let engrave   = Color(hex: "#3A2408")

    // gradients
    static let brassPlate = LinearGradient(
        colors: [Color(hex: "#FFDC8E"), Color(hex: "#F2A93B"), Color(hex: "#C9861F")],
        startPoint: .top, endPoint: .bottom)
    static let brassGear = RadialGradient(
        colors: [Color(hex: "#FFE7B4"), Color(hex: "#F2A93B"), Color(hex: "#B9761E"), Color(hex: "#6E430E")],
        center: UnitPoint(x: 0.36, y: 0.30), startRadius: 2, endRadius: 90)
    static let steelGear = RadialGradient(
        colors: [Color(hex: "#D4E8EA"), Color(hex: "#7C9EA3"), Color(hex: "#274A50")],
        center: UnitPoint(x: 0.36, y: 0.30), startRadius: 2, endRadius: 90)
    static let darkGear = RadialGradient(
        colors: [Color(hex: "#255057"), Color(hex: "#0C282D")],
        center: UnitPoint(x: 0.36, y: 0.30), startRadius: 2, endRadius: 90)

    static func sceneWash(top: Double = -0.12) -> RadialGradient {
        RadialGradient(
            colors: [Color(hex: "#1E535A"), Color(hex: "#0F2E33"), Color(hex: "#08181B")],
            center: UnitPoint(x: 0.5, y: top), startRadius: 40, endRadius: 720)
    }
}

// MARK: - Typography (Futura display / Avenir body / Copperplate plate)
enum Typo {
    static func display(_ size: CGFloat) -> Font { .custom("Futura-Bold", size: size) }
    static func displayMed(_ size: CGFloat) -> Font { .custom("Futura-Medium", size: size) }
    static func plate(_ size: CGFloat) -> Font { .custom("Copperplate-Bold", size: size) }
    static func body(_ size: CGFloat) -> Font { .custom("AvenirNext-Medium", size: size) }
    static func bodyThin(_ size: CGFloat) -> Font { .custom("AvenirNext-UltraLight", size: size) }
    static func bodyBold(_ size: CGFloat) -> Font { .custom("AvenirNext-DemiBold", size: size) }
}

// MARK: - Launch arguments
enum Launch {
    static var skipSplash: Bool { ProcessInfo.processInfo.arguments.contains("-skipSplash") }
    static var demoMode: Bool { ProcessInfo.processInfo.arguments.contains("-demoMode") }
    static var screenshotTour: Bool { ProcessInfo.processInfo.arguments.contains("-screenshotTour") }
}
