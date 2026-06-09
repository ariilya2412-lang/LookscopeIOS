import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var viewModel: AscendFlowViewModel

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 12)

            GlassCard {
                Text("Ascend AI+")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text("Premium placeholder")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text("This is only a placeholder paywall for the first MVP. No StoreKit yet.")
                    .foregroundStyle(.secondary)
            }

            GlassCard {
                feature("Unlimited deep reports")
                feature("Progress tracking")
                feature("More severe honesty mode")
                feature("Expanded grooming plans")
            }

            Spacer()

            PrimaryActionButton(title: "Back to Report", icon: "arrow.left") {
                viewModel.backToReport()
            }

            Button("Restart Flow") {
                viewModel.restart()
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 26)
    }

    private func feature(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.cyan)
            Text(text)
                .foregroundStyle(.white.opacity(0.92))
            Spacer()
        }
    }
}
