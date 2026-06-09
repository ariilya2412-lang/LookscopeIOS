import SwiftUI

struct ScanningView: View {
    @EnvironmentObject private var viewModel: AscendFlowViewModel
    @State private var animatePulse = false
    @State private var revealMetrics = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let image = viewModel.selectedPhoto?.uiImage {
                    GlassCard(padding: 12) {
                        GeometryReader { proxy in
                            let previewHeight = min(max(proxy.size.width * 1.12, 260), 380)

                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: previewHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                                LinearGradient(
                                    colors: [.black.opacity(0.02), .black.opacity(0.36)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                                if let result = viewModel.faceAnalysisResult {
                                    LandmarkOverlayView(result: result)
                                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                }

                                if viewModel.isScanning {
                                    scanRing
                                }
                            }
                        }
                        .frame(height: 380)
                    }
                }

                GlassCard {
                    LoadingTextView(
                        title: "Face Engine",
                        subtitle: viewModel.scanningStatus
                    )

                    Text("Apple Vision is mapping the face and building a premium report flow with practical improvement only.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    ProgressBarView(progress: viewModel.scanningProgress)
                }

                if let result = viewModel.faceAnalysisResult {
                    GlassCard {
                        Text("LOCAL METRIC PASS")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(1.5)
                            .foregroundStyle(.secondary)
                        ForEach(result.metrics) { metric in
                            MetricRowView(
                                label: metric.name,
                                detail: metric.verdict,
                                score: metric.score,
                                rawValueText: String(format: "RAW %.2f", metric.value)
                            )
                            .opacity(revealMetrics ? 1 : 0)
                            .offset(y: revealMetrics ? 0 : 10)
                        }

                        if let warning = result.warningMessage {
                            Text(warning)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                if let errorMessage = viewModel.scanningErrorMessage {
                    GlassCard {
                        Text("Scan issue")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        PrimaryActionButton(title: "Choose Another Photo", icon: "arrow.uturn.left") {
                            viewModel.returnToPhotoUpload()
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 28)
        }
        .task {
            await viewModel.runScanningSequenceIfNeeded()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animatePulse = true
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.86).delay(0.18)) {
                revealMetrics = true
            }
        }
    }

    private var scanRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 18)
                .frame(width: 220, height: 220)

            Circle()
                .trim(from: 0, to: viewModel.scanningProgress)
                .stroke(
                    AngularGradient(
                        colors: [Color.cyan, Color.purple, Color.cyan],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 220, height: 220)

            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 150, height: 150)
                .scaleEffect(animatePulse ? 1.06 : 0.94)
                .blur(radius: 10)

            VStack(spacing: 8) {
                Text("\(Int(viewModel.scanningProgress * 100))%")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Text("ASCEND SCORE")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
