import SwiftUI

struct ReportView: View {
    @EnvironmentObject private var viewModel: AnalysisViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.06, blue: 0.10), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if let report = viewModel.report {
                ScrollView {
                    VStack(spacing: 18) {
                        summaryCard(report)
                        metricsCard(report)
                        strengthsCard(report)
                        suggestionsCard(report)
                    }
                    .padding(18)
                }
            } else {
                ContentUnavailableView(
                    "No report yet",
                    systemImage: "sparkles.rectangle.stack",
                    description: Text("Import several photos on the Scan tab and run the analysis.")
                )
            }
        }
        .navigationTitle("Reports")
    }

    private func summaryCard(_ report: AnalysisReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(report.usedAI ? "AI report" : "Local fallback")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.mint)

            HStack(alignment: .bottom) {
                Text(String(format: "%.1f", report.overallScore))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                Text("/10")
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
            }

            Text(report.summaryLabel)
                .font(.title2.weight(.bold))
            Text(report.scoreContext)
                .foregroundStyle(.secondary)

            Text("Built from \(report.sourceCount) photos")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func metricsCard(_ report: AnalysisReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category scores")
                .font(.headline)

            ForEach(report.categoryScores) { score in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(score.category)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(String(format: "%.1f / 10", score.score))
                            .foregroundStyle(.mint)
                    }
                    ProgressView(value: score.score, total: 10)
                        .tint(.mint)
                    Text(score.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func strengthsCard(_ report: AnalysisReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Strengths")
                .font(.headline)

            ForEach(report.strengths, id: \.self) { item in
                Label(item, systemImage: "checkmark.circle.fill")
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(.primary, .mint)
                    .font(.subheadline)
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func suggestionsCard(_ report: AnalysisReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upgrade plan")
                .font(.headline)

            ForEach(report.suggestions) { suggestion in
                VStack(alignment: .leading, spacing: 6) {
                    Text(suggestion.title)
                        .font(.subheadline.weight(.semibold))
                    Text(suggestion.reason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
