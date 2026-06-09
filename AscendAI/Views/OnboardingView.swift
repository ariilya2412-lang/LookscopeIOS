import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var viewModel: AscendFlowViewModel
    @State private var reveal = false

    var body: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 32)

            GlassCard(padding: 26) {
                Text("PRIVATE ANALYSIS")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(.secondary)

                Text("Ascend AI")
                    .font(.system(size: 44, weight: .bold, design: .rounded))

                Text("Brutally honest facial analysis.")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.94))

                Text("No fake compliments. Just practical improvement.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .offset(y: reveal ? 0 : 18)
            .opacity(reveal ? 1 : 0)

            HStack(spacing: 12) {
                statChip("Ascend Score", systemImage: "waveform.path.ecg")
                statChip("Photo Scan", systemImage: "photo.fill")
                statChip("High ROI Fixes", systemImage: "sparkles")
            }
            .offset(y: reveal ? 0 : 22)
            .opacity(reveal ? 1 : 0)

            Spacer()

            PrimaryActionButton(title: "Begin Ascension", icon: "arrow.right") {
                viewModel.beginFlow()
            }
            .offset(y: reveal ? 0 : 28)
            .opacity(reveal ? 1 : 0)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 28)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.86)) {
                reveal = true
            }
        }
    }

    private func statChip(_ label: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
            Text(label)
        }
        .font(.system(size: 11, weight: .bold, design: .rounded))
        .tracking(1.1)
        .foregroundStyle(.white.opacity(0.88))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
}
