import SwiftUI

struct LoadingTextView: View {
    let title: String
    let subtitle: String

    @State private var animatePhase = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            HStack(spacing: 14) {
                Text(subtitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.cyan.opacity(animatePhase ? 0.95 : 0.32))
                            .frame(width: 6, height: 6)
                            .scaleEffect(animatePhase ? 1 : 0.6)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever()
                                .delay(Double(index) * 0.14),
                                value: animatePhase
                            )
                    }
                }
            }
        }
        .onAppear {
            animatePhase = true
        }
    }
}
