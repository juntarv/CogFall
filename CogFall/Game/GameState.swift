import Foundation

/// Explicit gameplay state machine. Transitions happen only in GameViewModel/GameScene.
enum GameState: Equatable {
    case aiming
    case dropping
    case settling
    case solved
    case gameOver
    case paused
}

struct GameConfig: Equatable, Hashable {
    enum Mode: String, Equatable, Hashable { case campaign, overdrive }
    var mode: Mode
    var levelIndex: Int   // bay number (campaign); 0 for overdrive
}

struct GameResult: Equatable {
    var solved: Bool
    var stars: Int
    var score: Int
    var gearsUsed: Int
    var gearsMeshed: Int
    var gearsSpare: Int
    var jams: Int
    var peakMultiplier: Double
    var secondsPowered: Double
    var bayName: String
    var mode: GameConfig.Mode
    var levelIndex: Int
    var fixture: String
    var reason: FailReason = .none
}
