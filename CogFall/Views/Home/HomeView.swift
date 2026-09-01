import SwiftUI

/// Orchestrator: splash (1.5s) → onboarding → main app. Persistence lives here, not at App level.
struct HomeView: View {
    private let persistence = PersistenceController.shared
    @StateObject private var store: Store

    private enum Root { case loading, onboarding, app }
    @State private var root: Root = .loading
    @State private var didSetup = false

    init() {
        _store = StateObject(wrappedValue: Store(context: PersistenceController.shared.viewContext))
    }

    var body: some View {
        ZStack {
            switch root {
            case .loading:
                SplashScreen().transition(.opacity)
            case .onboarding:
                OnboardingView(onComplete: {
                    store.completeOnboarding()
                    withAnimation(.easeInOut(duration: 0.45)) { root = .app }
                })
                .transition(.opacity)
            case .app:
                MainAppView(tour: Launch.screenshotTour)
                    .transition(.opacity)
            }
        }
        .environment(\.managedObjectContext, persistence.viewContext)
        .environmentObject(store)
        .task {
            guard !didSetup else { return }
            didSetup = true
            if Launch.screenshotTour {
                store.seedDemoProgress()
            } else {
                store.seedIfNeeded()
            }
            Haptic.enabled = store.preferences().hapticsOn
            let firstDone = store.preferences().firstLaunchCompleted

            if Launch.screenshotTour {
                root = .app
                return
            }
            if !Launch.skipSplash {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
            }
            withAnimation(.easeInOut(duration: 0.4)) {
                root = firstDone ? .app : .onboarding
            }
        }
    }
}
