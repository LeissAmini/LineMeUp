import Foundation
import SwiftUI

// holds the app's data, the views update when it changes
@MainActor
class LineupStore: ObservableObject {
    @Published var matchState: LoadState = .loading
    @Published var matches: [Match] = []
    @Published var lineups: [String: Lineup] = [:]      // match id -> lineup

    // favorite teams, saved to UserDefaults every time they change
    @Published var favoriteTeams: [Team] = [] {
        didSet { saveFavorites() }
    }

    private let favoritesKey = "favoriteTeams"

    init() {
        loadFavorites()
    }

    func loadMatches() async {
        matchState = .loading
        do {
            matches = try await PitchAPI.fetchMatches()
            matchState = .loaded
        } catch {
            matchState = .failed(error.localizedDescription)
        }
    }

    func loadLineup(for match: Match) async {
        do {
            lineups[match.id] = try await PitchAPI.fetchLineup(matchID: match.id)
        } catch {
            // skip it, the list still works without this lineup
        }
    }

    func loadLineups(for matches: [Match]) async {
        for match in matches {
            await loadLineup(for: match)
        }
    }

    // matches in the next few days
    func matches(withinDays days: Int) -> [Match] {
        let end = Date().addingTimeInterval(Double(days) * 24 * 60 * 60)
        return matches.filter { $0.timeUtc < end }
    }

    // groups the matches by day
    func matchesByDay(days: Int, favoritesFirst: Bool) -> [(date: String, matches: [Match])] {
        var result: [(date: String, matches: [Match])] = []
        for match in matches(withinDays: days) {
            if let index = result.firstIndex(where: { $0.date == match.date }) {
                result[index].matches.append(match)
            } else {
                result.append((date: match.date, matches: [match]))
            }
        }
        if favoritesFirst {
            for index in result.indices {
                result[index].matches.sort { isFavoriteMatch($0) && !isFavoriteMatch($1) }
            }
        }
        return result
    }

    var favoriteIDs: Set<String> {
        Set(favoriteTeams.map { $0.id })
    }

    func isFavorite(_ team: Team) -> Bool {
        favoriteIDs.contains(team.id)
    }

    func isFavoriteMatch(_ match: Match) -> Bool {
        isFavorite(match.homeTeam) || isFavorite(match.awayTeam)
    }

    func toggleFavorite(_ team: Team) {
        if let index = favoriteTeams.firstIndex(where: { $0.id == team.id }) {
            favoriteTeams.remove(at: index)
        } else {
            favoriteTeams.append(team)
        }
    }

    func nextMatch(for team: Team) -> Match? {
        matches.first { $0.homeTeam.id == team.id || $0.awayTeam.id == team.id }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteTeams) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let teams = try? JSONDecoder().decode([Team].self, from: data) {
            favoriteTeams = teams
        }
    }
}
