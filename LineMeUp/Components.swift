import SwiftUI

// team logo from the web
struct TeamLogo: View {
    let team: Team
    var size: CGFloat = 28

    var body: some View {
        AsyncImage(url: team.imageUrl) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Image(systemName: "shield")
                .foregroundStyle(.secondary)
        }
        .frame(width: size, height: size)
    }
}

// small label: Predicted, Confirmed or Not announced
struct StatusBadge: View {
    let status: LineupStatus

    var color: Color {
        switch status {
        case .notAnnounced: return .gray
        case .predicted: return .orange
        case .confirmed: return .green
        }
    }

    var body: some View {
        Label(status.title, systemImage: status.systemImage)
            .font(.caption.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

// error message with a retry button
struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
            Button("Try again", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// kickoff time in the user's timezone
func kickoffText(_ date: Date) -> String {
    date.formatted(date: .abbreviated, time: .shortened)
}
