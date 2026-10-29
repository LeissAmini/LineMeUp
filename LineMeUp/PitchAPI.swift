import Foundation

// all the network calls
struct PitchAPI {
    static let premierLeagueID = "l_4WFCIZ"   // English Premier League
    static let baseURL = "https://api.pitchapi.dev/v1"

    // key comes from Secrets.xcconfig so it stays out of GitHub
    static var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "PitchAPIKey") as? String ?? ""
    }

    // get upcoming matches
    static func fetchMatches() async throws -> [Match] {
        let data = try await get("/leagues/\(premierLeagueID)/matches?status=upcoming")
        let response = try decoder.decode(MatchesResponse.self, from: data)
        return response.data.matches
    }

    // get the lineup for one match
    static func fetchLineup(matchID: String) async throws -> Lineup {
        let data = try await get("/matches/\(matchID)/lineups")
        let response = try decoder.decode(LineupResponse.self, from: data)
        return response.data
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private static func get(_ path: String) async throws -> Data {
        guard !apiKey.isEmpty, let url = URL(string: baseURL + path) else {
            throw APIError.missingKey
        }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw APIError.badStatus(http.statusCode)
        }
        return data
    }
}

// error messages shown to the user
enum APIError: LocalizedError {
    case missingKey
    case badStatus(Int)

    var errorDescription: String? {
        switch self {
        case .missingKey:
            return "No API key found. Add it to Config/Secrets.xcconfig."
        case .badStatus(let code):
            if code == 401 { return "The API key was rejected (401)." }
            if code == 429 { return "Too many requests. Try again in a moment (429)." }
            return "The server returned an error (\(code))."
        }
    }
}
