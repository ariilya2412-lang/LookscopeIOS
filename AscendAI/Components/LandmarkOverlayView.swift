import SwiftUI

struct LandmarkOverlayView: View {
    let result: FaceAnalysisResult
    @State private var pulse = false
    @State private var reveal = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                ForEach(LandmarkRegion.allCases, id: \.self) { region in
                    let regionPoints = result.landmarks
                        .filter { $0.region == region }
                        .sorted { $0.sequenceIndex < $1.sequenceIndex }

                    if regionPoints.count > 1 {
                        Path { path in
                            let first = convert(regionPoints[0].location, in: size)
                            path.move(to: first)
                            for point in regionPoints.dropFirst() {
                                path.addLine(to: convert(point.location, in: size))
                            }
                            if closes(region) {
                                path.addLine(to: first)
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.40, green: 0.85, blue: 1.0).opacity(0.9),
                                    Color(red: 0.56, green: 0.40, blue: 1.0).opacity(0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 1.25, lineCap: .round, lineJoin: .round)
                        )
                        .opacity(reveal ? 1 : 0)
                        .scaleEffect(reveal ? 1 : 0.97)
                    }
                }

                ForEach(result.landmarks) { point in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.49, green: 0.93, blue: 1.0),
                                    Color(red: 0.65, green: 0.44, blue: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 4.5, height: 4.5)
                        .shadow(color: Color.cyan.opacity(0.65), radius: 6)
                        .scaleEffect(pulse ? 1.05 : 0.92)
                        .opacity(reveal ? 1 : 0)
                        .scaleEffect(reveal ? (pulse ? 1.05 : 0.92) : 0.2)
                        .position(convert(point.location, in: size))
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.78)
                            .delay(Double(point.sequenceIndex) * 0.012),
                            value: reveal
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            reveal = true
            withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private func convert(_ point: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: point.x * size.width, y: point.y * size.height)
    }

    private func closes(_ region: LandmarkRegion) -> Bool {
        switch region {
        case .leftEye, .rightEye, .outerLips, .innerLips:
            return true
        default:
            return false
        }
    }
}
