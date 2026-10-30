import SwiftUI

// Screen 5: settings, saved with @AppStorage
struct SettingsView: View {
    @EnvironmentObject var store: LineupStore
    @AppStorage("daysAhead") private var daysAhead = 3
    @AppStorage("favoritesFirst") private var favoritesFirst = true
    @AppStorage("showSubs") private var showSubs = true
    @AppStorage("layout") private var layout = "Pitch"

    var body: some View {
        NavigationStack {
            Form {
                Section("Matches") {
                    Stepper("Show next \(daysAhead) days", value: $daysAhead, in: 1...7)
                    Toggle("Favorite teams first", isOn: $favoritesFirst)
                }

                Section("Lineups") {
                    Picker("Layout", selection: $layout) {
                        Text("Pitch").tag("Pitch")
                        Text("List").tag("List")
                    }
                    .pickerStyle(.segmented)
                    Toggle("Show substitutes", isOn: $showSubs)
                }

                Section("About") {
                    Text("Lineup data from PitchAPI. Predicted lineups appear up to 48 hours before kickoff and become confirmed when the teams are announced.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
