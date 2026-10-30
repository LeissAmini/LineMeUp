import SwiftUI

// Screen 4: saved teams
struct FavoritesView: View {
    @EnvironmentObject var store: LineupStore
    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.favoriteTeams) { team in
                    HStack {
                        TeamLogo(team: team, size: 36)
                        VStack(alignment: .leading) {
                            Text(team.name)
                            if let match = store.nextMatch(for: team) {
                                Text("Next: \(kickoffText(match.timeUtc))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    store.favoriteTeams.remove(atOffsets: offsets)
                }
            }
            .overlay {
                if store.favoriteTeams.isEmpty {
                    Text("No favorite teams yet.\nOpen a match and tap the star under a team.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                if !store.favoriteTeams.isEmpty {
                    Button("Clear all") {
                        showClearAlert = true
                    }
                }
            }
            .alert("Remove all favorites?", isPresented: $showClearAlert) {
                Button("Remove", role: .destructive) {
                    store.favoriteTeams.removeAll()
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}
