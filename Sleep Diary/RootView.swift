import SwiftUI

let onboardingShownKey = "onboardingShown"

enum AppRoute: Equatable {
    case loading
    case onboarding
    case menu
    case settings
    case addNotes
    case noteDetails(id: UUID)
    case addTime
}

struct RootView: View {
    @State private var route: AppRoute = .loading

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "F7F8F9"), Color(hex: "FFFFFF")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            currentScreen
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch route {
        case .loading:
            Preloading {
                let needsOnboarding = !UserDefaults.standard.bool(
                    forKey: onboardingShownKey
                )
                route = needsOnboarding ? .onboarding : .menu
            }

        case .onboarding:
            Welcome {
                UserDefaults.standard.set(true, forKey: onboardingShownKey)
                route = .menu
            }

        case .menu:
            MenuView(
                onSettings: { route = .settings },
                onAddNotes: { route = .addNotes },
                onIdeaDetails: { ideaID in
                    route = .noteDetails(id: ideaID)
                },
                onBestTime: { route = .addTime }
            )

        case .settings:
            SettingsView(onBack: { route = .menu })

        case .addNotes:
            AddNote(
                onCancel: { route = .menu }

            )
            
        case .addTime:
        BestTimeView(
                onBack: { route = .menu }

            )

        case .noteDetails(let id):
            DetailView(
                ideaID: id,
                onBack: { route = .menu }
            )
        }
    }
}

#Preview {
    RootView()
}
