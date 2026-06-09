import SwiftUI

struct ScorePill: View {
    let title: String
    let score: Double

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            ScoreRingView(title: "Ascend Score", score: score, lineWidth: 12, diameter: 112)
            VStack(alignment: .leading, spacing: 8) {
                Text(title.uppercased())
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.secondary)
                Text("No fake compliments")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("Practical improvement only.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.035))
        )
    }
}
