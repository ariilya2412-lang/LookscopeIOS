import SwiftUI

struct AnalysisStepsView: View {
    @EnvironmentObject private var viewModel: AscendFlowViewModel
    @State private var revealedCards = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    Text("ANALYSIS COMPLETE")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                    Text("Ascend Score prepared")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("The scan flow finished, mapped the face, and prepared a premium report with no fake compliments.")
                        .foregroundStyle(.secondary)
                }
                .opacity(revealedCards >= 0 ? 1 : 0)

                if let result = viewModel.faceAnalysisResult {
                    GlassCard {
                        Text("LOCAL METRIC PASS")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(1.5)
                        Text("Approximate Vision-based heuristics for entertainment and self-improvement guidance.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)

                        ForEach(result.metrics) { metric in
                            MetricRowView(
                                label: metric.name,
                                detail: metric.verdict,
                                score: metric.score,
                                rawValueText: nil
                            )
                        }
                    }
                    .opacity(revealedCards >= 1 ? 1 : 0)
                    .offset(y: revealedCards >= 1 ? 0 : 14)
                }

                ForEach(Array(viewModel.analysisSteps.enumerated()), id: \.element.id) { index, step in
                    GlassCard {
                        HStack(alignment: .top, spacing: 14) {
                            Circle()
                                .fill(Color.cyan.opacity(0.16))
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(.cyan)
                                )

                            VStack(alignment: .leading, spacing: 8) {
                                Text(step.title)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Text(step.detail)
                                    .foregroundStyle(.secondary)
                                Text(step.accent)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .tracking(1.2)
                                    .foregroundStyle(.cyan)
                            }
                        }
                    }
                    .opacity(revealedCards >= index + 2 ? 1 : 0)
                    .offset(y: revealedCards >= index + 2 ? 0 : 16)
                }

                PrimaryActionButton(title: "Open Report", icon: "arrow.right") {
                    viewModel.continueToReport()
                }
                .opacity(revealedCards >= viewModel.analysisSteps.count + 2 ? 1 : 0)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
        }
        .onAppear {
            revealedCards = 0
            let total = viewModel.analysisSteps.count + 2
            for index in 0...total {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * 0.08)) {
                    withAnimation(.spring(response: 0.56, dampingFraction: 0.86)) {
                        revealedCards = index
                    }
                }
            }
        }
    }
}
