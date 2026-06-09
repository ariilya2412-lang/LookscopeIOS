import SwiftUI

struct ReportView: View {
    @EnvironmentObject private var viewModel: AscendFlowViewModel
    @State private var visibleCards = 0

    var body: some View {
        ScrollView {
            if let report = viewModel.report {
                VStack(spacing: 18) {
                    GlassCard {
                        Text("Ascend Report")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text("Premium analysis output")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        ScorePill(title: "Overall Ascend Score", score: report.overallScore)
                    }
                    .opacity(visibleCards >= 0 ? 1 : 0)
                    .offset(y: visibleCards >= 0 ? 0 : 14)

                    if let aiStatusMessage = viewModel.aiStatusMessage {
                        GlassCard {
                            HStack(spacing: 10) {
                                Image(systemName: "sparkles.rectangle.stack")
                                    .foregroundStyle(.cyan)
                                Text(aiStatusMessage)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .opacity(visibleCards >= 1 ? 1 : 0)
                        .offset(y: visibleCards >= 1 ? 0 : 14)
                    }

                    textCard("Summary", text: report.summary)
                        .opacity(visibleCards >= 2 ? 1 : 0)
                        .offset(y: visibleCards >= 2 ? 0 : 14)
                    textCard("Brutal Truth", text: report.brutalTruth)
                        .opacity(visibleCards >= 3 ? 1 : 0)
                        .offset(y: visibleCards >= 3 ? 0 : 14)
                    breakdownCard(report)
                        .opacity(visibleCards >= 4 ? 1 : 0)
                        .offset(y: visibleCards >= 4 ? 0 : 14)
                    localMetricsCard
                        .opacity(visibleCards >= 5 ? 1 : 0)
                        .offset(y: visibleCards >= 5 ? 0 : 14)
                    listCard("Strongest Features", items: report.strongestFeatures)
                        .opacity(visibleCards >= 6 ? 1 : 0)
                        .offset(y: visibleCards >= 6 ? 0 : 14)
                    listCard("Weakest Areas", items: report.weakestAreas)
                        .opacity(visibleCards >= 7 ? 1 : 0)
                        .offset(y: visibleCards >= 7 ? 0 : 14)
                    textCard("Bottleneck Detected", text: report.bottleneckDetected)
                        .opacity(visibleCards >= 8 ? 1 : 0)
                        .offset(y: visibleCards >= 8 ? 0 : 14)
                    listCard("High ROI Fixes", items: report.quickWins)
                        .opacity(visibleCards >= 9 ? 1 : 0)
                        .offset(y: visibleCards >= 9 ? 0 : 14)
                    listCard("30-Day Direction", items: report.longTermPlan)
                        .opacity(visibleCards >= 10 ? 1 : 0)
                        .offset(y: visibleCards >= 10 ? 0 : 14)
                    planCard(report.thirtyDayPlan)
                        .opacity(visibleCards >= 11 ? 1 : 0)
                        .offset(y: visibleCards >= 11 ? 0 : 14)
                    listCard("Hair Advice", items: report.hairAdvice)
                        .opacity(visibleCards >= 12 ? 1 : 0)
                        .offset(y: visibleCards >= 12 ? 0 : 14)
                    listCard("Skin Advice", items: report.skinAdvice)
                        .opacity(visibleCards >= 13 ? 1 : 0)
                        .offset(y: visibleCards >= 13 ? 0 : 14)
                    listCard("Beard Advice", items: report.beardAdvice)
                        .opacity(visibleCards >= 14 ? 1 : 0)
                        .offset(y: visibleCards >= 14 ? 0 : 14)
                    listCard("Photo Advice", items: report.photoAdvice)
                        .opacity(visibleCards >= 15 ? 1 : 0)
                        .offset(y: visibleCards >= 15 ? 0 : 14)
                    textCard("Disclaimer", text: report.disclaimer)
                        .opacity(visibleCards >= 16 ? 1 : 0)
                        .offset(y: visibleCards >= 16 ? 0 : 14)

                    PrimaryActionButton(title: "Open Paywall Preview", icon: "lock.fill") {
                        viewModel.openPaywall()
                    }
                    .opacity(visibleCards >= 17 ? 1 : 0)
                    .offset(y: visibleCards >= 17 ? 0 : 14)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 26)
            }
        }
        .onAppear {
            visibleCards = 0
            for index in 0...17 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * 0.05)) {
                    withAnimation(.spring(response: 0.56, dampingFraction: 0.86)) {
                        visibleCards = index
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var localMetricsCard: some View {
        if let result = viewModel.faceAnalysisResult, !result.metrics.isEmpty {
            GlassCard {
                Text("LOCAL LOOKSMAX METRICS")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.5)
                Text("Approximate landmark-based scoring for entertainment and self-improvement guidance.")
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
        }
    }

    private func breakdownCard(_ report: AnalysisReport) -> some View {
        GlassCard {
            Text("SCORE BREAKDOWN")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.5)
            ForEach(report.scoreBreakdown) { item in
                MetricRowView(
                    label: item.title,
                    detail: item.note,
                    score: item.score,
                    rawValueText: nil
                )
            }
        }
    }

    private func listCard(_ title: String, items: [String]) -> some View {
        GlassCard {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.4)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkle")
                        .foregroundStyle(.cyan)
                    Text(item)
                        .foregroundStyle(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func textCard(_ title: String, text: String) -> some View {
        GlassCard {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.4)
            Text(text)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func planCard(_ plan: [WeeklyPlan]) -> some View {
        GlassCard {
            Text("30-DAY ASCENSION PLAN")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.5)
            ForEach(plan) { week in
                VStack(alignment: .leading, spacing: 8) {
                    Text(week.weekTitle)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Text(week.focus)
                        .foregroundStyle(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(week.actions, id: \.self) { action in
                        HStack(alignment: .top, spacing: 10) {
                            Text("-")
                                .foregroundStyle(.cyan)
                            Text(action)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}
