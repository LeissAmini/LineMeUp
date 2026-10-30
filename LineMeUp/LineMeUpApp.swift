import SwiftUI

@main
struct LineMeUpApp: App {
    @StateObject private var store = LineupStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                MatchesView()
                    .tabItem { Label("Matches", systemImage: "sportscourt") }
                PlayersView()
                    .tabItem { Label("Players", systemImage: "person.3") }
                FavoritesView()
                    .tabItem { Label("Favorites", systemImage: "star") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
            .environmentObject(store)
        }
    }
}
