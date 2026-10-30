import SwiftUI

// Screen 2: lineup for one match
struct MatchDetailView: View {
    @EnvironmentObject var store: LineupStore
    @AppStorage("showSubs") private var showSubs = true
    @AppStorage("layout") private var layout = "Pitch"

    let match: Match
    @State private var showHome = true    // home or away

    var team: Team { showHome ? match.homeTeam : match.awayTeam }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                // switch between home and away
                Picker("Team", selection: $showHome.animation()) {
                    Text(match.homeTeam.name).tag(true)
                    Text(match.awayTeam.name).tag(false)
                }
                .pickerStyle(.segmented)

                if let lineup = store.lineups[match.id] {
                    lineupSection(lineup)
                } else {
                    ProgressView("Loading lineup...")
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Lineup")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await store.loadLineup(for: match)
        }
    }

    var header: some View {
        VStack(spacing: 6) {
            HStack(spacing: 20) {
                teamColumn(match.homeTeam)
                Text("vs").foregroundStyle(.secondary)
                teamColumn(match.awayTeam)
            }
            Text(kickoffText(match.timeUtc))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // logo, name and a star to save the team
    func teamColumn(_ team: Team) -> some View {
        VStack {
            TeamLogo(team: team, size: 50)
            Text(team.name)
                .font(.footnote.bold())
                .multilineTextAlignment(.center)
            Button {
                withAnimation(.spring()) {
                    store.toggleFavorite(team)
                }
            } label: {
                Image(systemName: store.isFavorite(team) ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
                    .scaleEffect(store.isFavorite(team) ? 1.3 : 1.0)
            }
        }
        .frame(maxWidth: .infinity)
    }

    func lineupSection(_ lineup: Lineup) -> some View {
        let side = showHome ? lineup.home : lineup.away
        return VStack(spacing: 12) {
            HStack {
                StatusBadge(status: side.status)
                Spacer()
                if !side.formation.isEmpty {
                    Text("Formation: \(side.formation)").font(.subheadline)
                }
            }

            if let starters = side.starters, !starters.isEmpty {
                if layout == "Pitch" {
                    PitchView(players: starters)
                        .transition(.opacity)
                } else {
                    playerList(title: "Starting XI", players: starters)
                }
                if showSubs, let subs = side.subs, !subs.isEmpty {
                    playerList(title: "Substitutes", players: subs)
                }
            } else {
                Text("The lineup for \(team.name) has not been announced yet.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }

    func playerList(title: String, players: [Player]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            ForEach(players) { player in
                HStack {
                    Text(player.shirtNumber ?? "-")
                        .frame(width: 30)
                        .foregroundStyle(.secondary)
                    Text(player.name)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
