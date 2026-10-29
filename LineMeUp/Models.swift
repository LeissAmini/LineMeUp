import Foundation

// MARK: - Data from the API
// the API sends names like home_team, the decoder turns them into homeTeam

struct Team: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let imageUrl: URL?
}

struct Match: Codable, Hashable, Identifiable {
    let id: String
    let date: String
    let timeUtc: Date         // kickoff time
    let homeTeam: Team
    let awayTeam: Team
    let scoreHome: Int?       // nil until the match is played
    let scoreAway: Int?
}

struct Player: Codable, Identifiable {
    let playerId: String
    let name: String
    let shirtNumber: String?
    let pitchX: Double        // how far up the pitch, 0 to 1
    let pitchY: Double        // left to right, 0 to 1

    var id: String { playerId }

    // gets the last name only
    var lastName: String {
        name.split(separator: " ").last.map(String.init) ?? name
    }
}

// lineup for one team
struct SideLineup: Codable {
    let formation: String
    let confirmed: Bool
    let starters: [Player]?   // nil when there is no lineup yet
    let subs: [Player]?

    var status: LineupStatus {
        guard let starters = starters, !starters.isEmpty else { return .notAnnounced }
        return confirmed ? .confirmed : .predicted
    }
}

struct Lineup: Codable {
    let matchId: String
    let homeTeam: Team
    let awayTeam: Team
    let home: SideLineup
    let away: SideLineup
}

// the API puts everything inside "data"

struct MatchesData: Codable {
    let matches: [Match]
}

struct MatchesResponse: Codable {
    let data: MatchesData
}

struct LineupResponse: Codable {
    let data: Lineup
}

// MARK: - Enums

enum LineupStatus {
    case notAnnounced
    case predicted
    case confirmed

    var title: String {
        switch self {
        case .notAnnounced: return "Not announced"
        case .predicted: return "Predicted"
        case .confirmed: return "Confirmed"
        }
    }

    var systemImage: String {
        switch self {
        case .notAnnounced: return "clock"
        case .predicted: return "questionmark.circle"
        case .confirmed: return "checkmark.seal.fill"
        }
    }
}

// what the Matches screen should show
enum LoadState {
    case loading
    case loaded
    case failed(String)
}
