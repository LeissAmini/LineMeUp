import SwiftUI

// draws the starting 11 on a pitch
struct PitchView: View {
    let players: [Player]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.75))

                // middle line and circle
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 2)
                Circle()
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                    .frame(width: geo.size.width * 0.25)

                // position each player using the API values
                ForEach(players) { player in
                    VStack(spacing: 2) {
                        Text(player.shirtNumber ?? "")
                            .font(.caption.bold())
                            .foregroundColor(.black)
                            .frame(width: 28, height: 28)
                            .background(Color.white)
                            .clipShape(Circle())
                        Text(player.lastName)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .frame(width: 60)
                    }
                    .position(x: player.pitchY * geo.size.width,
                              y: (1 - player.pitchX) * geo.size.height)
                }
            }
        }
        .aspectRatio(0.72, contentMode: .fit)
    }
}
