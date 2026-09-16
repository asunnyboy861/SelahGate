import SwiftUI
import SwiftData

enum AppRoute: Hashable {
    case ritual(depth: RitualDepth, source: String)
    case paywall
}

@main
struct SelahGateApp: App {
    let container: ModelContainer

    @State private var route: AppRoute?

    init() {
        let schema = Schema([UnlockEvent.self, DailyState.self, VerseVaultEntry.self, PrayerEntry.self])
        let configuration = ModelConfiguration(schema: schema, url: AppGroupStore.containerURL.appending(path: "SelahGate.sqlite"))
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            container = try! ModelContainer(for: schema)
        }
        let day = VerseLibrary.currentDayIndex
        if AppGroupStore.cachedVerseOfDay(dayIndex: day) == nil {
            let verse = VerseLibrary.randomToday()
            AppGroupStore.cacheVerseOfDay(verse, dayIndex: day)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(route: $route)
                .modelContainer(container)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "selahgate" else { return }
        let depthRaw = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first { $0.name == "depth" }?.value
        let depth = RitualDepth(rawValue: depthRaw ?? "") ?? .light
        route = .ritual(depth: depth, source: "shield")
    }
}
