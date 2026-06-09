import Foundation
import ImageIO
import UIKit
import Vision

enum VisionFaceAnalyzerError: LocalizedError {
    case invalidImage
    case noFaceDetected
    case multipleFacesDetected
    case lowQuality
    case noLandmarks

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Photo quality is too low. Use natural light and avoid filters."
        case .noFaceDetected:
            return "No clear face detected. Try a front-facing photo with better lighting."
        case .multipleFacesDetected:
            return "Multiple faces detected. Use a solo front-facing photo."
        case .lowQuality:
            return "Photo quality is too low. Use natural light and avoid filters."
        case .noLandmarks:
            return "No clear face detected. Try a front-facing photo with better lighting."
        }
    }
}

final class VisionFaceAnalyzer {
    func analyzeFace(in image: UIImage) async throws -> FaceAnalysisResult {
        guard let cgImage = image.cgImage else {
            throw VisionFaceAnalyzerError.invalidImage
        }

        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgOrientation)

        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        let observations = request.results ?? []
        guard !observations.isEmpty else {
            throw VisionFaceAnalyzerError.noFaceDetected
        }
        guard observations.count == 1 else {
            throw VisionFaceAnalyzerError.multipleFacesDetected
        }

        let face = observations[0]
        let faceBox = CGRect(
            x: face.boundingBox.minX,
            y: 1 - face.boundingBox.maxY,
            width: face.boundingBox.width,
            height: face.boundingBox.height
        )

        let regions = extractRegions(from: face, boundingBox: faceBox)
        let landmarks = regions.flatMap(\.points)

        guard !landmarks.isEmpty else {
            throw VisionFaceAnalyzerError.noLandmarks
        }

        let qualityScore = makeQualityScore(faceBox: faceBox, landmarks: landmarks)
        guard qualityScore >= 0.32 else {
            throw VisionFaceAnalyzerError.lowQuality
        }

        let warningMessage = qualityScore < 0.52
            ? "Photo quality is borderline. Natural light and a cleaner front-facing angle will improve the reading."
            : nil

        return FaceAnalysisResult(
            faceBoundingBox: faceBox,
            landmarks: landmarks,
            metrics: [],
            qualityScore: qualityScore,
            warningMessage: warningMessage
        )
    }

    private func extractRegions(from observation: VNFaceObservation, boundingBox: CGRect) -> [LandmarkRegionPoints] {
        guard let landmarks = observation.landmarks else { return [] }

        return [
            makeRegion(.faceContour, points: landmarks.faceContour?.normalizedPoints ?? [], boundingBox: boundingBox),
            makeRegion(.leftEye, points: landmarks.leftEye?.normalizedPoints ?? [], boundingBox: boundingBox),
            makeRegion(.rightEye, points: landmarks.rightEye?.normalizedPoints ?? [], boundingBox: boundingBox),
            makeRegion(.nose, points: landmarks.nose?.normalizedPoints ?? [], boundingBox: boundingBox),
            makeRegion(.outerLips, points: landmarks.outerLips?.normalizedPoints ?? [], boundingBox: boundingBox),
            makeRegion(.innerLips, points: landmarks.innerLips?.normalizedPoints ?? [], boundingBox: boundingBox),
            makeRegion(.leftEyebrow, points: landmarks.leftEyebrow?.normalizedPoints ?? [], boundingBox: boundingBox),
            makeRegion(.rightEyebrow, points: landmarks.rightEyebrow?.normalizedPoints ?? [], boundingBox: boundingBox)
        ]
    }

    private func makeRegion(
        _ region: LandmarkRegion,
        points: [CGPoint],
        boundingBox: CGRect
    ) -> LandmarkRegionPoints {
        let mapped = points.enumerated().map { index, point in
            FaceLandmarkPoint(
                location: CGPoint(
                    x: boundingBox.minX + point.x * boundingBox.width,
                    y: boundingBox.minY + (1 - point.y) * boundingBox.height
                ),
                region: region,
                sequenceIndex: index
            )
        }
        return LandmarkRegionPoints(region: region, points: mapped)
    }

    private func makeQualityScore(faceBox: CGRect, landmarks: [FaceLandmarkPoint]) -> Double {
        let faceCoverage = min(1, max(0, faceBox.width * faceBox.height * 2.2))
        let landmarkDensity = min(1, Double(landmarks.count) / 72.0)
        return min(1, (faceCoverage * 0.45) + (landmarkDensity * 0.55))
    }

}

private struct LandmarkRegionPoints {
    let region: LandmarkRegion
    let points: [FaceLandmarkPoint]
}

private extension UIImage {
    var cgOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
