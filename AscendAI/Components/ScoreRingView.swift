import SwiftUI

struct ScoreRingView: View {
    let title: String
    let score: Double
    var lineWidth: CGFloat = 14
    var diameter: CGFloat = 122

    @State private var animatedScore = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)

                Circle()
                    .trim(from: 0, to: min(animatedScore / 10, 1))
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(red: 0.50, green: 0.84, blue: 1.0),
                                Color(red: 0.57, green: 0.42, blue: 1.0),
                                Color(red: 0.34, green: 0.94, blue: 0.88)
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.10),
                                Color.white.opacity(0.02)
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: diameter / 2
                        )
                    )
                    .padding(18)

                VStack(spacing: 4) {
                    Text(String(format: "%.1f", animatedScore))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("/ 10")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: diameter, height: diameter)
        }
        .onAppear {
            withAnimation(.spring(response: 1.1, dampingFraction: 0.9).delay(0.12)) {
                animatedScore = score
            }
        }
    }
}
