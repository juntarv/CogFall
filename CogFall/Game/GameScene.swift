import SpriteKit
import SwiftUI

/// A target lamp that lights when a powered gear reaches it.
private final class TargetLamp {
    let node: SKShapeNode
    let position: CGPoint
    let reach: CGFloat
    var lit = false
    init(position: CGPoint, reach: CGFloat) {
        self.position = position
        self.reach = reach
        node = SKShapeNode(circleOfRadius: 17)
        node.position = position
        node.fillColor = UIColor(Palette.surface2)
        node.strokeColor = UIColor(Palette.steelEdge)
        node.lineWidth = 2
        node.zPosition = 2
    }
    func setLit(_ on: Bool) {
        guard on != lit else { return }
        lit = on
        node.fillColor = on ? UIColor(Palette.power) : UIColor(Palette.surface2)
        node.strokeColor = on ? UIColor(Palette.brass) : UIColor(Palette.steelEdge)
        if on {
            node.run(.sequence([.scale(to: 1.35, duration: 0.12), .scale(to: 1.0, duration: 0.16)]))
            node.glowUp()
        }
    }
}

private extension SKShapeNode {
    func glowUp() {
        let halo = SKShapeNode(circleOfRadius: 26)
        halo.fillColor = UIColor(Palette.power).withAlphaComponent(0.4)
        halo.strokeColor = .clear
        halo.zPosition = -1
        addChild(halo)
        halo.run(.sequence([.group([.scale(to: 1.8, duration: 0.5), .fadeOut(withDuration: 0.5)]), .removeFromParent()]))
    }
}

final class GameScene: SKScene {

    // Wiring
    weak var model: GameViewModel?
    let config: GameConfig
    let bay: BayDef
    var autoplay: Bool = false

    // Layout
    private var bayRect: CGRect = .zero
    /// Rect of the housing the bay sits inside — aligned with the SwiftUI HUD/tray.
    private var housingRect: CGRect = .zero
    private var aimLane: SKShapeNode?
    private let spindleRadius: CGFloat = 30
    private var spindlePos: CGPoint = .zero
    private var targets: [TargetLamp] = []
    private let cam = SKCameraNode()

    // State
    private(set) var runState: GameState = .aiming
    private var activeGears: [GearNode] = []
    private var pool: [GearNode] = []
    private var currentGear: GearNode?
    private var droppingGear: GearNode?
    private var queue: [GearSize] = []
    private var queueIndex = 0
    private var aimX: CGFloat = 0

    // Pressure systems
    /// Stack crossing this line jams the housing.
    private var ceilingY: CGFloat { bayRect.maxY - 30 }
    private var ceilingLine: SKShapeNode?
    private var loadRing: SKShapeNode?
    private var torqueCapacity: Int = 12
    private var shotClock: Double = 10
    private var shotRemaining: Double = 10
    private var failReason: FailReason = .none

    // Scoring
    private var score = 0
    private var multiplier: Double = 1
    private var gearsUsed = 0
    private var jams = 0
    private var peakMultiplier: Double = 1
    private var poweredSeconds: Double = 0

    // Timing
    private var lastUpdate: TimeInterval = 0
    private var lastAuto: TimeInterval = 0
    private var lastPublish: TimeInterval = 0
    private var autoRNG = SeededRNG(seed: 20260718)
    private var started = false

    init(config: GameConfig) {
        self.config = config
        self.bay = BayLibrary.bay(max(1, config.levelIndex))
        super.init(size: CGSize(width: 390, height: 700))
        scaleMode = .resizeFill
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    // MARK: Setup
    override func didMove(to view: SKView) {
        guard !started else { return }
        started = true
        physicsWorld.gravity = CGVector(dx: 0, dy: -5.6)
        camera = cam
        cam.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cam)
        layoutChrome(safeArea: view.safeAreaInsets)
        addBackground()
        layoutBay()
        addWalls()
        addAimLane()
        addCeilingLine()
        configurePressure()
        addSpindle()
        buildQueue()
        configureTargets()
        // Pre-allocate a pool of reusable gear nodes (no allocation during update).
        for _ in 0..<48 { pool.append(GearNode()) }
        aimX = spindlePos.x
        spawnNextHeld()
    }

    /// The housing is pinned to the same gutters the SwiftUI chrome uses, so the
    /// playfield reads as one panel with the HUD and tray instead of floating.
    private func layoutChrome(safeArea: UIEdgeInsets) {
        let side: CGFloat = 16              // GamePlayView horizontal padding
        let hudBlock: CGFloat = 54          // HUDBar height
        let trayBlock: CGFloat = 116 + 24   // GearTray height + bottom padding
        let gap: CGFloat = 10
        let bottom = safeArea.bottom + trayBlock + gap
        let top = safeArea.top + hudBlock + gap
        housingRect = CGRect(x: side, y: bottom,
                             width: size.width - side * 2,
                             height: max(200, size.height - top - bottom))
    }

    private func addBackground() {
        let bg = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        bg.zPosition = -100
        bg.fillColor = UIColor(Palette.bg)
        bg.strokeColor = .clear
        addChild(bg)

        let frame = SKShapeNode(rect: housingRect, cornerRadius: 22)
        frame.fillColor = UIColor(Palette.surface).withAlphaComponent(0.55)
        frame.strokeColor = UIColor(Palette.brass).withAlphaComponent(0.16)
        frame.lineWidth = 1.5
        frame.zPosition = -90
        addChild(frame)
        addHousingGrid()
        addHousingRivets()
    }

    /// Faint machined grid so the empty bay has surface instead of dead space.
    private func addHousingGrid() {
        let step: CGFloat = 44
        let path = CGMutablePath()
        var x = housingRect.minX + step
        while x < housingRect.maxX - 4 {
            path.move(to: CGPoint(x: x, y: housingRect.minY + 10))
            path.addLine(to: CGPoint(x: x, y: housingRect.maxY - 10))
            x += step
        }
        var y = housingRect.minY + step
        while y < housingRect.maxY - 4 {
            path.move(to: CGPoint(x: housingRect.minX + 10, y: y))
            path.addLine(to: CGPoint(x: housingRect.maxX - 10, y: y))
            y += step
        }
        let grid = SKShapeNode(path: path)
        grid.strokeColor = UIColor(Palette.text).withAlphaComponent(0.045)
        grid.lineWidth = 1
        grid.zPosition = -89
        addChild(grid)
    }

    private func addHousingRivets() {
        let inset: CGFloat = 14
        for p in [CGPoint(x: housingRect.minX + inset, y: housingRect.minY + inset),
                  CGPoint(x: housingRect.maxX - inset, y: housingRect.minY + inset),
                  CGPoint(x: housingRect.minX + inset, y: housingRect.maxY - inset),
                  CGPoint(x: housingRect.maxX - inset, y: housingRect.maxY - inset)] {
            let rivet = SKShapeNode(circleOfRadius: 3)
            rivet.position = p
            rivet.fillColor = UIColor(Palette.brass).withAlphaComponent(0.5)
            rivet.strokeColor = .clear
            rivet.zPosition = -88
            addChild(rivet)
        }
    }

    private func layoutBay() {
        bayRect = housingRect.insetBy(dx: 10, dy: 10)
        spindlePos = CGPoint(x: bayRect.minX + bay.spindleX * bayRect.width,
                             y: bayRect.minY + 34)
    }

    /// The line the stack must not cross.
    private func addCeilingLine() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: bayRect.minX + 2, y: ceilingY))
        path.addLine(to: CGPoint(x: bayRect.maxX - 2, y: ceilingY))
        let line = SKShapeNode(path: path.copy(dashingWithPhase: 0, lengths: [10, 6]))
        line.strokeColor = UIColor(Palette.rust).withAlphaComponent(0.35)
        line.lineWidth = 2
        line.zPosition = 0.4
        addChild(line)
        ceilingLine = line
    }

    private func configurePressure() {
        torqueCapacity = config.mode == .campaign ? bay.torque : 12
        shotClock = config.mode == .campaign ? bay.shotClock : 8.0
        shotRemaining = shotClock
        addLoadRing()
    }

    /// Diegetic torque gauge: an arc around the spindle that fills with load and
    /// burns red past capacity, so the risk lives where the drive comes from.
    private func addLoadRing() {
        let ring = SKShapeNode()
        ring.strokeColor = UIColor(Palette.brass)
        ring.lineWidth = 4
        ring.lineCap = .round
        ring.fillColor = .clear
        ring.position = spindlePos
        ring.zPosition = 2
        addChild(ring)
        loadRing = ring
        updateLoadRing()
    }

    private func updateLoadRing() {
        guard let ring = loadRing else { return }
        let frac = LoadModel.loadFraction(load: poweredCount(), capacity: torqueCapacity)
        let sweep = CGFloat(min(1.0, frac)) * 2 * .pi
        guard sweep > 0.01 else { ring.path = nil; return }
        let r = spindleRadius + 12
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: r, startAngle: .pi / 2,
                    endAngle: .pi / 2 - sweep, clockwise: true)
        ring.path = path
        let over = frac > 1.0
        ring.strokeColor = UIColor(over ? Palette.rust : (frac > 0.8 ? Palette.brassHi : Palette.brass))
        if over && ring.action(forKey: "warn") == nil {
            ring.run(.repeatForever(.sequence([.fadeAlpha(to: 0.35, duration: 0.3),
                                               .fadeAlpha(to: 1.0, duration: 0.3)])), withKey: "warn")
        } else if !over {
            ring.removeAction(forKey: "warn")
            ring.alpha = 1
        }
    }

    /// Dashed guide showing where the held gear will land.
    private func addAimLane() {
        let lane = SKShapeNode()
        lane.strokeColor = UIColor(Palette.brass).withAlphaComponent(0.28)
        lane.lineWidth = 1.5
        lane.zPosition = 0.5
        addChild(lane)
        aimLane = lane
        updateAimLane()
    }

    private func updateAimLane() {
        guard let lane = aimLane else { return }
        lane.isHidden = runState != .aiming
        guard !lane.isHidden else { return }
        let line = CGMutablePath()
        line.move(to: CGPoint(x: aimX, y: bayRect.minY + 4))
        line.addLine(to: CGPoint(x: aimX, y: bayRect.maxY - 8))
        lane.path = line.copy(dashingWithPhase: 0, lengths: [7, 7])
    }

    private func addWalls() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: bayRect.minX, y: bayRect.maxY + 40))
        path.addLine(to: CGPoint(x: bayRect.minX, y: bayRect.minY))
        path.addLine(to: CGPoint(x: bayRect.maxX, y: bayRect.minY))
        path.addLine(to: CGPoint(x: bayRect.maxX, y: bayRect.maxY + 40))
        let walls = SKNode()
        let pb = SKPhysicsBody(edgeChainFrom: path)
        pb.categoryBitMask = PhysicsCategory.wall
        pb.friction = 0.6
        walls.physicsBody = pb
        addChild(walls)
    }

    private func addSpindle() {
        let node = SKShapeNode()
        node.path = GearNode.gearPath(radius: spindleRadius)
        node.fillColor = UIColor(Palette.brass)
        node.strokeColor = UIColor(Palette.brassEdge)
        node.lineWidth = 2
        node.position = spindlePos
        node.zPosition = 1
        node.run(.repeatForever(.rotate(byAngle: .pi, duration: 2.4)))
        // Layered falloff — a single flat disc reads as a khaki blob, not a glow.
        for (scale, alpha) in [(2.0, 0.06), (1.6, 0.09), (1.28, 0.13)] as [(CGFloat, CGFloat)] {
            let halo = SKShapeNode(circleOfRadius: spindleRadius * scale)
            halo.fillColor = UIColor(Palette.power).withAlphaComponent(alpha)
            halo.strokeColor = .clear
            halo.zPosition = -1
            node.addChild(halo)
        }
        // hub
        let hub = SKShapeNode(circleOfRadius: spindleRadius * 0.3)
        hub.fillColor = UIColor(Palette.bg)
        hub.strokeColor = UIColor.black.withAlphaComponent(0.5)
        node.addChild(hub)
        // static physics so gears rest against it
        let sb = SKPhysicsBody(circleOfRadius: spindleRadius * 0.95)
        sb.isDynamic = false
        sb.categoryBitMask = PhysicsCategory.spindle
        node.physicsBody = sb
        addChild(node)
    }

    private func buildQueue() {
        let count = config.mode == .campaign ? bay.gearBudget : 40
        let seed: UInt64 = config.mode == .campaign ? UInt64(9000 + bay.index * 131) : 424242
        queue = SpawnTable.queue(count: count, seed: seed, ramp: config.mode == .overdrive)
        queueIndex = 0
    }

    /// Lamps sit at a height the bay's gear budget can actually reach — a lamp
    /// pinned to the ceiling with six gears in hand is not a level, it's a wall.
    private func configureTargets() {
        targets.forEach { $0.node.removeFromParent() }
        targets.removeAll()
        let n = config.mode == .campaign ? bay.targets : 1
        let rows = config.mode == .campaign ? bay.reachRows : 3
        for i in 0..<n {
            // Lamps ring the spindle: the first sits straight above it, later ones
            // lean further out so they demand a staircase, not just a tower. Drive
            // has to flow from the spindle, so distance from it IS the difficulty.
            let dx = CGFloat((i + 1) / 2) * 66 * (i % 2 == 0 ? 1 : -1)
            let x = min(bayRect.maxX - 40, max(bayRect.minX + 40, spindlePos.x + dx))
            let y = min(ceilingY - 30, spindlePos.y + CGFloat(max(2, rows - i)) * BayLibrary.rowHeight)
            let lamp = TargetLamp(position: CGPoint(x: x, y: y), reach: 36)
            targets.append(lamp)
            addChild(lamp.node)
        }
    }

    // MARK: Queue / spawn
    private func nextSize() -> GearSize {
        if queueIndex >= queue.count {
            // extend endlessly for overdrive
            queue.append(contentsOf: SpawnTable.queue(count: 12, seed: UInt64(700 + queueIndex), ramp: true))
        }
        let s = queue[min(queueIndex, queue.count - 1)]
        queueIndex += 1
        return s
    }

    private func upcomingPreview() -> [GearSize] {
        var out: [GearSize] = []
        for k in 0..<3 {
            let idx = queueIndex + k
            if idx < queue.count { out.append(queue[idx]) }
        }
        return out
    }

    private func dequeueGear() -> GearNode {
        if let g = pool.popLast() { return g }
        return GearNode()
    }

    private func spawnNextHeld() {
        if config.mode == .campaign && queueIndex >= queue.count {
            finishGameOver(reason: .outOfGears); return
        }
        let size = nextSize()
        let g = dequeueGear()
        g.configure(size: size)
        g.position = CGPoint(x: aimX, y: bayRect.maxY - size.radius - 2)
        g.zPosition = 3
        addChild(g)
        currentGear = g
        runState = .aiming
        shotRemaining = shotClock
        publishState(.aiming)
        model?.inHand = size
        model?.shotFraction = 1
        model?.queuePreview = upcomingPreview()
        model?.gearsLeft = config.mode == .campaign ? max(0, bay.gearBudget - gearsUsed) : -1
    }

    // MARK: Input intents (called from HUD / touches)
    func dropCurrent() {
        guard runState == .aiming, let g = currentGear else { return }
        currentGear = nil
        g.attachPhysics(dynamic: true)
        g.physicsBody?.velocity = CGVector(dx: 0, dy: -40)
        g.isLive = true
        g.dropTime = lastUpdate
        g.settleTimer = 0
        droppingGear = g
        activeGears.append(g)
        gearsUsed += 1
        runState = .dropping
        publishState(.dropping)
        model?.gearsUsed = gearsUsed
        Haptic.light()
    }

    func setAim(x: CGFloat) {
        aimX = min(bayRect.maxX - 40, max(bayRect.minX + 40, x))
        updateAimLane()
    }

    func resumeAiming() { /* physics resumes automatically via isPaused = false */ }

    func restart() {
        for g in activeGears { g.recycle(); pool.append(g) }
        activeGears.removeAll()
        currentGear?.recycle()
        currentGear = nil
        droppingGear = nil
        score = 0; multiplier = 1; peakMultiplier = 1; gearsUsed = 0; jams = 0; poweredSeconds = 0; currentHeat = 0
        failReason = .none
        torqueCapacity = config.mode == .campaign ? bay.torque : 12
        shotClock = config.mode == .campaign ? bay.shotClock : 8.0
        shotRemaining = shotClock
        buildQueue()
        configureTargets()
        updateLoadRing()
        publishHUD()
        aimX = spindlePos.x
        spawnNextHeld()
    }

    // MARK: Settle resolution
    private func settleCurrent() {
        guard let g = droppingGear else { return }
        droppingGear = nil
        g.isLive = false
        g.isSettled = true
        g.physicsBody?.isDynamic = false   // pin: becomes a stable platform
        resolveSettle(g)
    }

    private func resolveSettle(_ g: GearNode) {
        recomputePower()
        updateTargets()

        // Stacking is the main way to reach the lamps — and the main way to die.
        if g.position.y + g.radius >= ceilingY {
            spawnSpark(at: g.position, color: Palette.rust)
            shake()
            finishGameOver(reason: .overflow)
            return
        }

        if g.isPowered {
            let meshed = poweredCount()
            score += ScoreEngine.meshPoints(chainLength: meshed, multiplier: multiplier)
            multiplier = min(5.0, multiplier + 0.1)
            peakMultiplier = max(peakMultiplier, multiplier)
            spawnSpark(at: g.position, color: Palette.power)
            g.run(.sequence([.scale(to: 1.14, duration: 0.08), .scale(to: 1.0, duration: 0.12)]))
            Haptic.medium()
        } else {
            jams += 1
            heatUp(LoadModel.jamHeat)
            multiplier = max(1.0, multiplier - 0.2)
            spawnSpark(at: g.position, color: Palette.rust)
            shake()
            Haptic.warning()
        }
        updateLoadRing()
        publishHUD()

        if allTargetsLit() {
            if config.mode == .campaign { finishSolved(); return }
            else {
                score += 500
                multiplier = min(6.0, multiplier + 0.3)
                // Each lamp buys a little more torque, but the chain grows faster.
                torqueCapacity += 2
                shotClock = max(3.5, shotClock - 0.35)
                addOverdriveTarget()
                publishHUD()
            }
        }
        if currentHeat >= 1.0 { finishGameOver(reason: .burnout); return }
        if config.mode == .campaign && gearsUsed >= bay.gearBudget && !allTargetsLit() {
            finishGameOver(reason: .outOfGears); return
        }
        spawnNextHeld()
    }

    // MARK: Power propagation
    private func computePoweredSet() -> Set<ObjectIdentifier> {
        var powered = Set<ObjectIdentifier>()
        var stack: [GearNode] = []
        // Seized gears are dead metal: they neither turn nor pass drive along.
        for g in activeGears where !g.isSeized && adjacentToSpindle(g) {
            if powered.insert(ObjectIdentifier(g)).inserted { stack.append(g) }
        }
        while let g = stack.popLast() {
            for o in activeGears where o !== g && !o.isSeized {
                if powered.contains(ObjectIdentifier(o)) { continue }
                if MeshRules.meshes(centerA: g.position, radiusA: g.radius,
                                    centerB: o.position, radiusB: o.radius) {
                    powered.insert(ObjectIdentifier(o))
                    stack.append(o)
                }
            }
        }
        return powered
    }

    private func recomputePower() {
        let set = computePoweredSet()
        for g in activeGears {
            let on = set.contains(ObjectIdentifier(g))
            if g.isPowered != on { g.setPowered(on) }
        }
    }

    /// The spindle engages generously — the first gear of a chain catching the
    /// drive should never be the hard part; reach and load are the difficulty.
    private func adjacentToSpindle(_ g: GearNode) -> Bool {
        let d = hypot(g.position.x - spindlePos.x, g.position.y - spindlePos.y)
        return d <= g.radius + spindleRadius + MeshRules.tolerance * 2
    }

    private func poweredCount() -> Int { activeGears.reduce(0) { $0 + ($1.isPowered ? 1 : 0) } }

    private func updateTargets() {
        for t in targets {
            var lit = false
            for g in activeGears where g.isPowered {
                if hypot(g.position.x - t.position.x, g.position.y - t.position.y) <= g.radius + t.reach {
                    lit = true; break
                }
            }
            t.setLit(lit)
        }
    }

    private func allTargetsLit() -> Bool { !targets.isEmpty && targets.allSatisfy { $0.lit } }

    private func addOverdriveTarget() {
        let x = autoRNG.cgFloat(bayRect.minX + 40, bayRect.maxX - 40)
        let y = autoRNG.cgFloat(bayRect.midY, bayRect.maxY - 30)
        let lamp = TargetLamp(position: CGPoint(x: x, y: y), reach: 36)
        targets.append(lamp)
        addChild(lamp.node)
    }

    // MARK: Heat & pressure
    private var currentHeat: Double = 0
    private func heatUp(_ amt: Double) { currentHeat = min(1, currentHeat + amt) }

    /// Runs every frame: gears left off the chain rust solid, and an overloaded
    /// spindle bleeds heat until the machine burns out.
    private func tickPressure(_ dt: TimeInterval) {
        var seizedChanged = false
        for g in activeGears where g.isSettled && !g.isSeized {
            if g.isPowered {
                g.idleTime = 0
            } else {
                g.idleTime += dt
                if g.idleTime >= LoadModel.seizeDelay {
                    g.seize()
                    heatUp(LoadModel.seizeHeat)
                    seizedChanged = true
                    spawnSpark(at: g.position, color: Palette.rust)
                    Haptic.warning()
                }
            }
        }
        if seizedChanged {
            recomputePower()
            updateTargets()
        }

        let seized = activeGears.reduce(0) { $0 + ($1.isSeized ? 1 : 0) }
        let load = poweredCount()
        currentHeat = max(0, min(1, currentHeat + LoadModel.heatDelta(
            load: load, capacity: torqueCapacity, seized: seized, dt: dt)))
        updateLoadRing()
        updateCeilingWarning()

        if currentHeat >= 1.0 {
            shake()
            finishGameOver(reason: .burnout)
        }
    }

    /// Aiming is not free — the feed drops the gear for you when time runs out.
    private func tickShotClock(_ dt: TimeInterval) {
        guard runState == .aiming else { shotRemaining = shotClock; return }
        shotRemaining = max(0, shotRemaining - dt)
        model?.shotFraction = shotClock > 0 ? shotRemaining / shotClock : 1
        if shotRemaining <= 0 {
            heatUp(LoadModel.clockHeat)
            Haptic.warning()
            dropCurrent()
        }
    }

    private func updateCeilingWarning() {
        guard let line = ceilingLine else { return }
        let peak = activeGears.filter { $0.isSettled }.map { $0.position.y + $0.radius }.max() ?? bayRect.minY
        let close = peak > ceilingY - 90
        line.strokeColor = UIColor(close ? Palette.rust : Palette.rust).withAlphaComponent(close ? 0.85 : 0.35)
        if close && line.action(forKey: "pulse") == nil {
            line.run(.repeatForever(.sequence([.fadeAlpha(to: 0.4, duration: 0.45),
                                               .fadeAlpha(to: 1.0, duration: 0.45)])), withKey: "pulse")
        } else if !close {
            line.removeAction(forKey: "pulse")
            line.alpha = 1
        }
    }

    // MARK: Finish
    private func finishSolved() {
        runState = .solved
        let spare = max(0, bay.gearBudget - gearsUsed)
        let stars = ScoreEngine.stars(used: gearsUsed, par: bay.parGears, budget: bay.gearBudget, jams: jams, solved: true)
        score += ScoreEngine.spareBonus(spare) + ScoreEngine.timeBonus(poweredSeconds)
        Haptic.success()
        celebrate()
        let result = GameResult(solved: true, stars: stars, score: score,
                                gearsUsed: gearsUsed, gearsMeshed: poweredCount(),
                                gearsSpare: spare, jams: jams, peakMultiplier: peakMultiplier,
                                secondsPowered: poweredSeconds, bayName: bay.name,
                                mode: config.mode, levelIndex: bay.index, fixture: bay.fixture)
        publishHUD()
        model?.finish(result)
    }

    private func finishGameOver(reason: FailReason) {
        runState = .gameOver
        failReason = reason
        let spare = max(0, bay.gearBudget - gearsUsed)
        let solved = false
        Haptic.warning()
        let result = GameResult(solved: solved, stars: 0, score: score,
                                gearsUsed: gearsUsed, gearsMeshed: poweredCount(),
                                gearsSpare: spare, jams: jams, peakMultiplier: peakMultiplier,
                                secondsPowered: poweredSeconds,
                                bayName: config.mode == .overdrive ? "Overdrive" : bay.name,
                                mode: config.mode, levelIndex: bay.index, fixture: bay.fixture,
                                reason: reason)
        publishHUD()
        model?.finish(result)
    }

    // MARK: Effects
    private func shake() {
        let dx: CGFloat = 7
        cam.run(.sequence([
            .moveBy(x: dx, y: -dx * 0.5, duration: 0.04),
            .moveBy(x: -dx * 2, y: dx, duration: 0.06),
            .moveBy(x: dx, y: -dx * 0.5, duration: 0.05),
            .move(to: CGPoint(x: size.width / 2, y: size.height / 2), duration: 0.05)
        ]))
    }

    private func spawnSpark(at p: CGPoint, color: Color) {
        for i in 0..<8 {
            let spark = SKShapeNode(circleOfRadius: 3)
            spark.fillColor = UIColor(color)
            spark.strokeColor = .clear
            spark.position = p
            spark.zPosition = 50
            addChild(spark)
            let a = CGFloat(i) / 8 * 2 * .pi
            let dist = CGFloat.random(in: 22...44)
            let move = SKAction.moveBy(x: cos(a) * dist, y: sin(a) * dist, duration: 0.4)
            move.timingMode = .easeOut
            spark.run(.sequence([.group([move, .fadeOut(withDuration: 0.4), .scale(to: 0.2, duration: 0.4)]), .removeFromParent()]))
        }
    }

    private func celebrate() {
        for _ in 0..<3 {
            spawnSpark(at: CGPoint(x: CGFloat.random(in: bayRect.minX...bayRect.maxX),
                                   y: CGFloat.random(in: bayRect.midY...bayRect.maxY)), color: Palette.power)
        }
    }

    // MARK: Publishing
    private func publishState(_ s: GameState) {
        runState = s
        model?.state = s
        updateAimLane()
    }
    private func publishHUD() {
        guard let m = model else { return }
        m.score = score
        m.heat = currentHeat
        m.multiplier = multiplier
        m.gearsUsed = gearsUsed
        m.gearsMeshed = poweredCount()
        m.load = poweredCount()
        m.capacity = torqueCapacity
        m.seized = activeGears.reduce(0) { $0 + ($1.isSeized ? 1 : 0) }
        m.gearsLeft = config.mode == .campaign ? max(0, bay.gearBudget - gearsUsed) : -1
        m.queuePreview = upcomingPreview()
    }

    // MARK: Touches (aim + tap-to-drop)
    private var touchStart: CGPoint = .zero
    private var didDrag = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        touchStart = t.location(in: self)
        didDrag = false
        if runState == .aiming { setAim(x: touchStart.x); currentGear?.position.x = aimX }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let p = t.location(in: self)
        if abs(p.x - touchStart.x) > 6 { didDrag = true }
        if runState == .aiming { setAim(x: p.x); currentGear?.position.x = aimX }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if runState == .aiming && !didDrag { dropCurrent() }
    }

    // MARK: Update loop
    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 { lastUpdate = currentTime }
        let dt = min(0.05, currentTime - lastUpdate)
        lastUpdate = currentTime
        guard runState == .aiming || runState == .dropping else { return }

        // ease held gear toward aim
        if runState == .aiming, let g = currentGear {
            g.position.x += (aimX - g.position.x) * 0.35
        }

        // accumulate powered time
        if targets.contains(where: { $0.lit }) { poweredSeconds += dt }

        tickPressure(dt)
        if runState == .gameOver { return }
        tickShotClock(dt)

        // settle detection for the live gear
        if runState == .dropping, let g = droppingGear, let pb = g.physicsBody {
            let speed = hypot(pb.velocity.dx, pb.velocity.dy)
            if speed < 14 && abs(pb.angularVelocity) < 0.5 {
                g.settleTimer += dt
            } else {
                g.settleTimer = 0
            }
            if g.settleTimer > 0.32 || (currentTime - g.dropTime) > 2.8 {
                settleCurrent()
            }
        }

        // Autoplay for demo / screenshot tour: stacks under the next dark lamp so
        // the tour shows the machine actually being built, not gears dumped at random.
        if autoplay && runState == .aiming && currentTime - lastAuto > 1.0 {
            lastAuto = currentTime
            let dark = targets.first(where: { !$0.lit })
            let goal = dark?.position.x ?? spindlePos.x
            // Walk the aim out from the spindle so the chain stays connected.
            let t = min(1, CGFloat(gearsUsed) / 3)
            let base = spindlePos.x + (goal - spindlePos.x) * t
            setAim(x: base + autoRNG.cgFloat(-6, 6))
            currentGear?.position.x = aimX
            dropCurrent()
        }

        // publish elapsed powered seconds occasionally
        if currentTime - lastPublish > 0.3 {
            lastPublish = currentTime
            model?.poweredSeconds = poweredSeconds
        }
    }
}
