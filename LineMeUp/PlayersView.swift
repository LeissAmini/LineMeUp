import SwiftUI

// Screen 3: all players in the lineups, with search
struct PlayersView: View {
    @EnvironmentObject var store: LineupStore
    @AppStorage("daysAhead") private var daysAhead = 3
    @State private var searchText = ""

    // one row in the list
    struct Entry: Identifiable {
        let id: String
        let player: Player
        let teamName: String
        let status: LineupStatus
        let match: Match
    }

    var entries: [Entry] {
        var result: [Entry] = []
        for match in store.matches(withinDays: daysAhead) {
            guard let lineup = store.lineups[match.id] else { continue }
            for player in lineup.home.starters ?? [] {
                result.append(Entry(id: match.id + player.playerId, player: player,
                                    teamName: lineup.homeTeam.name,
                                    status: lineup.home.status, match: match))
            }
            for player in lineup.away.starters ?? [] {
                result.append(Entry(id: match.id + player.playerId, player: player,
                                    teamName: lineup.awayTeam.name,
                                    status: lineup.away.status, match: match))
            }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.player.name.localizedCaseInsensitiveContains(searchText) ||
                $0.teamName.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result.sorted { $0.player.name < $1.player.name }
    }

    var body: some View {
        NavigationStack {
            List(entries) { entry in
                NavigationLink(value: entry.match) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.player.name)
                            Text(entry.teamName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        StatusBadge(status: entry.status)
                    }
                }
            }
            .overlay {
                if entries.isEmpty {
                    Text("No players to show yet.\nLineups appear about 48 hours before kickoff.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .searchable(text: $searchText, prompt: "Search player or team")
            .navigationTitle("Players")
            .navigationDestination(for: Match.self) { match in
                MatchDetailView(match: match)
            }
        }
    }
}
