import CoreGraphics
import Foundation

// Local heuristic scoring only. These scores are approximate and intended
// for entertainment/self-improvement guidance rather than scientific truth.
final class LooksmaxScoringEngine {
    func generateLocalMetrics(from result: FaceAnalysisResult) -> [FaceMetric] {
        let contour = points(for: .faceContour, in: result)
        let leftEye = points(for: .leftEye, in: result)
        let rightEye = points(for: .rightEye, in: result)
        let nose = points(for: .nose, in: result)
        let outerLips = points(for: .outerLips, in: result)
        let innerLips = points(for: .innerLips, in: result)

        let faceWidth = max(result.faceBoundingBox.width, 0.001)
        let faceHeight = max(result.faceBoundingBox.height, 0.001)
        let faceCenter = CGPoint(
            x: result.faceBoundingBox.midX,
            y: result.faceBoundingBox.midY
        )

        let leftEyeCenter = averagePoint(leftEye) ?? CGPoint(
            x: result.faceBoundingBox.minX + faceWidth * 0.34,
            y: result.faceBoundingBox.minY + faceHeight * 0.38
        )
        let rightEyeCenter = averagePoint(rightEye) ?? CGPoint(
            x: result.faceBoundingBox.minX + faceWidth * 0.66,
            y: result.faceBoundingBox.minY + faceHeight * 0.38
        )
        let noseCenter = averagePoint(nose) ?? CGPoint(
            x: faceCenter.x,
            y: result.faceBoundingBox.minY + faceHeight * 0.56
        )
        let lipPoints = outerLips.isEmpty ? innerLips : outerLips
        _ = averagePoint(lipPoints) ?? CGPoint(
            x: faceCenter.x,
            y: result.faceBoundingBox.minY + faceHeight * 0.74
        )

        let eyeLineMidpoint = midpoint(leftEyeCenter, rightEyeCenter)
        let harmonyValue = distance(eyeLineMidpoint, noseCenter) / Double(faceHeight)
        let harmonyScore = score(value: harmonyValue, ideal: 0.17, tolerance: 0.08)

        let symmetryVerticalDelta = Double(abs(leftEyeCenter.y - rightEyeCenter.y) / faceHeight)
        let symmetryHorizontalBalance = Double(abs((faceCenter.x - leftEyeCenter.x) - (rightEyeCenter.x - faceCenter.x)) / faceWidth)
        let symmetryValue = symmetryVerticalDelta + symmetryHorizontalBalance
        let symmetryScore = score(value: symmetryValue, ideal: 0.0, tolerance: 0.09)

        let jawWidth = horizontalSpan(contour)
        let jawValue = jawWidth / Double(faceWidth)
        let jawScore = score(value: jawValue, ideal: 0.82, tolerance: 0.18)

        let eyeTilt = abs(angle(from: leftEyeCenter, to: rightEyeCenter)) / 18.0
        let eyeSpacing = distance(leftEyeCenter, rightEyeCenter) / Double(faceWidth)
        let eyeAreaValue = max(0, eyeSpacing - eyeTilt * 0.08)
        let eyeAreaScore = score(value: eyeAreaValue, ideal: 0.34, tolerance: 0.11)

        let noseHeight = verticalSpan(nose)
        let noseWidth = horizontalSpan(nose)
        let noseRatio = noseWidth / max(noseHeight, 0.001)
        let noseScore = score(value: noseRatio, ideal: 0.62, tolerance: 0.22)

        let lipWidth = horizontalSpan(lipPoints)
        let lipHeight = verticalSpan(lipPoints)
        let lipRatio = lipHeight > 0 ? lipWidth / lipHeight : 3.0
        let lipScore = score(value: lipRatio, ideal: 3.0, tolerance: 1.1)

        // These are local heuristics derived from Vision landmarks only.
        // They are approximate and meant for entertainment/self-improvement guidance,
        // not as scientific, medical, or cosmetic advice.
        return [
            FaceMetric(
                name: "Face Harmony Score",
                value: harmonyValue,
                score: harmonyScore,
                category: .harmony,
                verdict: verdict(for: harmonyScore, positive: "Balanced central thirds", fallback: "Center proportions could look cleaner in stronger lighting")
            ),
            FaceMetric(
                name: "Symmetry Score",
                value: symmetryValue,
                score: symmetryScore,
                category: .symmetry,
                verdict: verdict(for: symmetryScore, positive: "Good left-right balance", fallback: "Minor asymmetry reads stronger from this angle")
            ),
            FaceMetric(
                name: "Jawline Score",
                value: jawValue,
                score: jawScore,
                category: .jawline,
                verdict: verdict(for: jawScore, positive: "Solid lower-face structure", fallback: "Jaw definition depends on angle, posture, and body-fat presentation")
            ),
            FaceMetric(
                name: "Eye Area Score",
                value: eyeAreaValue,
                score: eyeAreaScore,
                category: .eyes,
                verdict: verdict(for: eyeAreaScore, positive: "Eye spacing reads strong", fallback: "Eye area would benefit from cleaner framing and rest")
            ),
            FaceMetric(
                name: "Nose Proportion Score",
                value: noseRatio,
                score: noseScore,
                category: .nose,
                verdict: verdict(for: noseScore, positive: "Nose proportions read balanced", fallback: "Nose ratio is angle-sensitive in a single photo")
            ),
            FaceMetric(
                name: "Lip Balance Score",
                value: lipRatio,
                score: lipScore,
                category: .lips,
                verdict: verdict(for: lipScore, positive: "Lip width-to-height balance looks stable", fallback: "Lip balance is partially hidden by expression and lighting")
            )
        ]
    }

    private func points(for region: LandmarkRegion, in result: FaceAnalysisResult) -> [CGPoint] {
        result.landmarks
            .filter { $0.region == region }
            .sorted { $0.sequenceIndex < $1.sequenceIndex }
            .map(\.location)
    }

    private func averagePoint(_ points: [CGPoint]) -> CGPoint? {
        guard !points.isEmpty else { return nil }
        let total = points.reduce(CGPoint.zero) { partial, point in
            CGPoint(x: partial.x + point.x, y: partial.y + point.y)
        }
        return CGPoint(x: total.x / CGFloat(points.count), y: total.y / CGFloat(points.count))
    }

    private func horizontalSpan(_ points: [CGPoint]) -> Double {
        guard let minX = points.map(\.x).min(), let maxX = points.map(\.x).max() else {
            return 0.58
        }
        return Double(maxX - minX)
    }

    private func verticalSpan(_ points: [CGPoint]) -> Double {
        guard let minY = points.map(\.y).min(), let maxY = points.map(\.y).max() else {
            return 0.18
        }
        return Double(maxY - minY)
    }

    private func verdict(for score: Double, positive: String, fallback: String) -> String {
        score >= 7.5 ? positive : fallback
    }

    func distance(_ lhs: CGPoint, _ rhs: CGPoint) -> Double {
        let dx = rhs.x - lhs.x
        let dy = rhs.y - lhs.y
        return sqrt(Double(dx * dx + dy * dy))
    }

    func midpoint(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        CGPoint(x: (lhs.x + rhs.x) / 2, y: (lhs.y + rhs.y) / 2)
    }

    func angle(from start: CGPoint, to end: CGPoint) -> Double {
        Double(atan2(end.y - start.y, end.x - start.x) * 180 / .pi)
    }

    func score(value: Double, ideal: Double, tolerance: Double) -> Double {
        guard tolerance > 0 else { return 5.0 }
        let normalized = max(0, 1 - (abs(value - ideal) / tolerance))
        return max(3.8, min(9.6, normalized * 10))
    }
}
