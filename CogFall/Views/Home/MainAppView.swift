import SwiftUI

/// Hosts the router-driven screens and runs the screenshot-tour coordinator.
struct MainAppView: View {
    var tour: Bool
    @EnvironmentObject var store: Store
    @StateObject private var router = AppRouter()

    // tour state
    @State private var tourStep = 0
    private let tourScreens: [AppScreen] = [
        .menu,
        .game(GameConfig(mode: .campaign, levelIndex: 3)),
        .conduit,
        .foundry,
        .settings
    ]
    private let tourTick = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            current
                .id(router.screen)
                .transition(.opacity)
        }
        .environmentObject(router)
        .animation(.easeInOut(duration: 0.35), value: router.screen)
        .onReceive(tourTick) { _ in
            guard tour else { return }
            tourStep = (tourStep + 1) % tourScreens.count
            router.go(tourScreens[tourStep])
        }
        .onAppear {
            if tour { router.screen = tourScreens[0] }
        }
    }

    @ViewBuilder private var current: some View {
        switch router.screen {
        case .menu:      MainMenuView()
        case .conduit:   ConduitView()
        case .foundry:   FoundryView()
        case .settings:  SettingsView()
        case .game(let cfg): GamePlayView(config: cfg)
        }
    }
}
