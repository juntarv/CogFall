import SwiftUI

enum AppScreen: Hashable {
    case menu
    case conduit
    case foundry
    case settings
    case game(GameConfig)
}

/// Lightweight programmatic router (also drives the screenshot tour).
final class AppRouter: ObservableObject {
    @Published var screen: AppScreen = .menu

    func go(_ s: AppScreen) {
        withAnimation(.easeInOut(duration: 0.35)) { screen = s }
    }
    func play(_ config: GameConfig) { go(.game(config)) }
    func backToMenu() { go(.menu) }
}
