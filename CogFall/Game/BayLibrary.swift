import CoreGraphics

/// A campaign bay definition. Layout is normalized (0…1) within the bay rect.
struct BayDef {
    let index: Int          // 1…24
    let name: String
    let fixture: String     // SF Symbol standing in for the driven fixture
    let gearBudget: Int     // gears you are given
    let parGears: Int       // used <= par (+0 jams) → 3 stars
    let targets: Int        // number of target lamps to power
    let spindleX: CGFloat   // normalized x of the power spindle
    let reachRows: Int      // gear-rows above the spindle the lamps sit at
    let torque: Int         // powered gears the spindle turns before overheating
    let shotClock: Double   // seconds to aim before the gear feeds itself
}

enum BayLibrary {
    static let fixtures = ["bird.fill", "circle.hexagongrid.fill", "gearshape.2.fill",
                           "sun.max.fill", "drop.fill", "moon.stars.fill",
                           "leaf.fill", "flame.fill", "hare.fill", "sparkles",
                           "wind", "bell.fill"]

    static let names = [
        "Wind-Up Lark", "Brass Orrery", "Escapement Gate", "Sunflower Rig",
        "Tidal Regulator", "Moonphase Dial", "Ivy Governor", "Ember Bellows",
        "Leaping Automaton", "Starlight Cam", "Zephyr Fan", "Chime Tower",
        "Carillon Drum", "Ratchet Warren", "Pendulum Court", "Solar Capstan",
        "Frost Ratchet", "Amber Turbine", "Meridian Wheel", "Lantern Winch",
        "Aurora Spindle", "Grand Escapement", "Clockheart Core", "Prime Mover"
    ]

    /// Vertical distance one stacked gear adds — lamp heights and gear budgets are
    /// both derived from it so every bay is reachable with the gears it hands you.
    static let rowHeight: CGFloat = 52

    static let all: [BayDef] = (1...24).map { i in
        let idx0 = i - 1
        let targets = min(3, 1 + idx0 / 9)          // 1 → 2 → 3
        let reachRows = 2 + idx0 / 4                // 2 → 7 rows above the spindle
        let perTarget = reachRows + 1               // gears needed to reach one lamp
        let par = targets * perTarget
        let slack = max(2, 6 - idx0 / 5)            // spare gears, tightening
        let budget = par + slack
        // Torque sits just above par: a clean solution never overheats, but every
        // wasted gear eats into the margin, so sloppy play burns the machine down.
        let torque = par + max(1, 3 - idx0 / 8)
        let shotClock = max(4.5, 11.0 - Double(idx0) * 0.28)
        let spindleX: CGFloat = [0.22, 0.5, 0.78, 0.35, 0.65][idx0 % 5]
        return BayDef(
            index: i,
            name: names[idx0 % names.count],
            fixture: fixtures[idx0 % fixtures.count],
            gearBudget: budget,
            parGears: par,
            targets: targets,
            spindleX: spindleX,
            reachRows: reachRows,
            torque: torque,
            shotClock: shotClock)
    }

    static func bay(_ index: Int) -> BayDef {
        all.first(where: { $0.index == index }) ?? all[0]
    }
}
