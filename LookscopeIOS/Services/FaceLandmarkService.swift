import Foundation
import ImageIO
import UIKit
import Vision

enum FaceLandmarkError: LocalizedError {
    case imageDecodeFailed

    var errorDescription: String? {
        "Face scan could not decode the image."
    }
}

struct FaceLandmarkService {
    func analyze(imageData: Data) throws -> FaceScanSummary {
        guard let image = UIImage(data: imageData), let cgImage = image.cgImage else {
            throw FaceLandmarkError.imageDecodeFailed
        }

        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgOrientation)
        try handler.perform([request])

        let observations = request.results ?? []
        guard let face = observations.first else {
            return FaceScanSummary(faceCount: 0, landmarksCount: 0, alignment: "No face", localScore: 2.0)
        }

        let leftEye = face.landmarks?.leftEye?.normalizedPoints ?? []
        let rightEye = face.landmarks?.rightEye?.normalizedPoints ?? []
        let allPoints = (face.landmarks?.allPoints?.pointCount) ?? 0

        let alignment: String
        if let left = leftEye.first, let right = rightEye.first {
            let tilt = abs(left.y - right.y)
            if tilt < 0.03 {
                alignment = "Strong"
            } else if tilt < 0.06 {
                alignment = "Good"
            } else {
                alignment = "Tilted"
            }
        } else {
            alignment = "Partial"
        }

        let localScore = min(9.2, max(3.5, 4.8 + Double(allPoints) / 25.0))

        return FaceScanSummary(
            faceCount: observations.count,
            landmarksCount: allPoints,
            alignment: alignment,
            localScore: localScore
        )
    }
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
