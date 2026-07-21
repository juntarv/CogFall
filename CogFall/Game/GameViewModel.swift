import SwiftUI
import SpriteKit

/// Bridges the single SKScene to SwiftUI: publishes HUD state, forwards intents.
final class GameViewModel: ObservableObject {
    @Published var state: GameState = .aiming
    @Published var score = 0
    @Published var heat: Double = 0
    @Published var multiplier: Double = 1
    @Published var gearsUsed = 0
    @Published var gearsMeshed = 0
    @Published var poweredSeconds: Double = 0
    @Published var load = 0
    @Published var capacity = 12
    @Published var seized = 0
    /// Gears left in a campaign bay; -1 in endless mode.
    @Published var gearsLeft = -1
    /// 1 → full time to aim, 0 → the feed drops it for you.
    @Published var shotFraction: Double = 1
    @Published var queuePreview: [GearSize] = []
    @Published var inHand: GearSize = .medium
    @Published var showPause = false
    @Published var showResult = false
    @Published var result: GameResult? = nil

    let config: GameConfig
    let bay: BayDef
    let scene: GameScene
    var onFinish: ((GameResult) -> Void)?

    var bayLabel: String { config.mode == .overdrive ? "OD" : String(format: "%02d", bay.index) }
    var bayTitle: String { config.mode == .overdrive ? "Overdrive" : bay.name }

    init(config: GameConfig) {
        self.config = config
        self.bay = BayLibrary.bay(max(1, config.levelIndex))
        let s = GameScene(config: config)
        self.scene = s
        s.autoplay = Launch.demoMode || Launch.screenshotTour
        s.model = self
    }

    func drop() { scene.dropCurrent() }

    func pause() {
        guard state == .aiming || state == .dropping else { return }
        showPause = true
        scene.isPaused = true
        state = .paused
    }
    func resume() {
        showPause = false
        scene.isPaused = false
        if state == .paused { state = .aiming }
    }
    func restart() {
        showPause = false; showResult = false; result = nil
        heat = 0; score = 0; multiplier = 1; gearsUsed = 0; gearsMeshed = 0; poweredSeconds = 0
        load = 0; seized = 0; shotFraction = 1
        scene.isPaused = false
        scene.restart()
        state = .aiming
    }
    func finish(_ r: GameResult) {
        result = r
        state = r.solved ? .solved : .gameOver
        onFinish?(r)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            self?.showResult = true
        }
    }
}
