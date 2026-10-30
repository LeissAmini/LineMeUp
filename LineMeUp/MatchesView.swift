import SwiftUI

// Screen 1: upcoming matches
struct MatchesView: View {
    @EnvironmentObject var store: LineupStore
    @AppStorage("daysAhead") private var daysAhead = 3
    @AppStorage("favoritesFirst") private var favoritesFirst = true

    var body: some View {
        NavigationStack {
            Group {
                switch store.matchState {
                case .loading:
                    ProgressView("Loading matches...")
                case .failed(let message):
                    ErrorView(message: message) {
                        Task { await loadAll() }
                    }
                case .loaded:
                    matchList
                }
            }
            .navigationTitle("Premier League")
            .navigationDestination(for: Match.self) { match in
                MatchDetailView(match: match)
            }
        }
        .task {
            await loadAll()
        }
        .onChange(of: daysAhead) {
            Task { await store.loadLineups(for: store.matches(withinDays: daysAhead)) }
        }
    }

    var matchList: some View {
        List {
            ForEach(store.matchesByDay(days: daysAhead, favoritesFirst: favoritesFirst), id: \.date) { day in
                Section(day.date) {
                    ForEach(day.matches) { match in
                        NavigationLink(value: match) {
                            MatchRow(match: match)
                        }
                    }
                }
            }
        }
        .refreshable {
            await loadAll()
        }
    }

    func loadAll() async {
        await store.loadMatches()
        await store.loadLineups(for: store.matches(withinDays: daysAhead))
    }
}

struct MatchRow: View {
    @EnvironmentObject var store: LineupStore
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TeamLogo(team: match.homeTeam)
                Text(match.homeTeam.name)
                if store.isFavorite(match.homeTeam) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                }
            }
            HStack {
                TeamLogo(team: match.awayTeam)
                Text(match.awayTeam.name)
                if store.isFavorite(match.awayTeam) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                }
            }
            HStack {
                Text(match.timeUtc.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                // status of the home lineup
                if let lineup = store.lineups[match.id] {
                    StatusBadge(status: lineup.home.status)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
