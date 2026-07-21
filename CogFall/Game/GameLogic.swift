import CoreGraphics
import Foundation

/// Deterministic RNG so -demoMode / -screenshotTour produce identical frames.
struct SeededRNG {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
    mutating func int(_ range: Range<Int>) -> Int {
        let span = UInt64(range.upperBound - range.lowerBound)
        return range.lowerBound + Int(next() % max(1, span))
    }
    mutating func cgFloat(_ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        let t = CGFloat(next() % 10_000) / 10_000
        return lo + (hi - lo) * t
    }
}

/// Gear sizes = tooth count = radius = reach.
enum GearSize: Int, CaseIterable {
    case small, medium, large
    var radius: CGFloat {
        switch self {
        case .small: return 20
        case .medium: return 28
        case .large: return 36
        }
    }
    var label: String {
        switch self {
        case .small: return "S"
        case .medium: return "M"
        case .large: return "L"
        }
    }
}

/// Distance-based meshing test (pure, testable — no SpriteKit).
enum MeshRules {
    static let tolerance: CGFloat = 12

    static func meshes(centerA: CGPoint, radiusA: CGFloat,
                       centerB: CGPoint, radiusB: CGFloat) -> Bool {
        let d = hypot(centerA.x - centerB.x, centerA.y - centerB.y)
        let ideal = radiusA + radiusB
        return d <= ideal + tolerance && d >= ideal * 0.5
    }
}

/// Drive-train pressure model: the spindle can only turn so many gears before
/// the machine overheats. Pure and testable — no SpriteKit.
enum LoadModel {
    /// Seconds an unpowered settled gear may sit before it rusts solid.
    static let seizeDelay: TimeInterval = 5.0
    /// Heat added per second, per gear over the torque capacity.
    static let overloadRate: Double = 0.05
    /// Heat added per second by each seized gear.
    static let seizedRate: Double = 0.012
    /// Heat shed per second by the cooling system.
    static let coolRate: Double = 0.075
    /// Discrete penalties.
    static let jamHeat: Double = 0.10
    static let seizeHeat: Double = 0.08
    static let clockHeat: Double = 0.06

    /// Signed heat change for one frame. Cooling runs constantly, so a couple of
    /// mistakes are survivable and only sustained overload actually burns you out.
    static func heatDelta(load: Int, capacity: Int, seized: Int, dt: TimeInterval) -> Double {
        let over = max(0, load - capacity)
        let gain = Double(over) * overloadRate + Double(seized) * seizedRate
        return (gain - coolRate) * dt
    }

    /// 0…1 fill of the load ring; >1 means overloaded.
    static func loadFraction(load: Int, capacity: Int) -> Double {
        guard capacity > 0 else { return 1 }
        return Double(load) / Double(capacity)
    }
}

/// Why a run ended — drives the results copy.
enum FailReason: String, Equatable {
    case burnout      // heat hit 1.0
    case overflow     // stack crossed the bay ceiling
    case outOfGears   // campaign budget spent without lighting every lamp
    case none

    var title: String {
        switch self {
        case .burnout: return "Burnout"
        case .overflow: return "Bay overflow"
        case .outOfGears: return "Out of gears"
        case .none: return "Mechanism jammed"
        }
    }
    var detail: String {
        switch self {
        case .burnout: return "The drive-train overheated — too much load on the spindle."
        case .overflow: return "The stack reached the bay ceiling and jammed the housing."
        case .outOfGears: return "The last gear was spent with lamps still dark."
        case .none: return "The mechanism seized."
        }
    }
}

/// Scoring & star thresholds (pure, testable).
enum ScoreEngine {
    static func meshPoints(chainLength: Int, multiplier: Double) -> Int {
        Int(Double(90 + chainLength * 12) * multiplier)
    }
    static func spareBonus(_ spare: Int) -> Int { max(0, spare) * 300 }
    static func timeBonus(_ seconds: Double) -> Int { Int(seconds * 25) }

    static func stars(used: Int, par: Int, budget: Int, jams: Int, solved: Bool) -> Int {
        guard solved else { return 0 }
        if used <= par && jams == 0 { return 3 }
        if used <= budget && jams <= 1 { return 2 }
        return 1
    }
}

/// Spawn queue generator. Later gears skew larger for tension.
enum SpawnTable {
    static func queue(count: Int, seed: UInt64, ramp: Bool) -> [GearSize] {
        var rng = SeededRNG(seed: seed)
        var out: [GearSize] = []
        for i in 0..<count {
            let roll = rng.int(0..<100)
            let size: GearSize
            if ramp {
                let large = min(55, 20 + i * 2)
                if roll < large { size = .large }
                else if roll < large + 40 { size = .medium }
                else { size = .small }
            } else {
                size = roll < 34 ? .small : (roll < 72 ? .medium : .large)
            }
            out.append(size)
        }
        return out
    }
}
