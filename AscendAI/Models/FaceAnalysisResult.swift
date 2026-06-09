import CoreGraphics
import Foundation

struct FaceAnalysisResult: Hashable {
    let faceBoundingBox: CGRect
    let landmarks: [FaceLandmarkPoint]
    let metrics: [FaceMetric]
    let qualityScore: Double
    let warningMessage: String?
}

struct FaceLandmarkPoint: Identifiable, Hashable {
    let id: UUID
    let location: CGPoint
    let region: LandmarkRegion
    let sequenceIndex: Int

    init(
        id: UUID = UUID(),
        location: CGPoint,
        region: LandmarkRegion,
        sequenceIndex: Int
    ) {
        self.id = id
        self.location = location
        self.region = region
        self.sequenceIndex = sequenceIndex
    }
}

enum LandmarkRegion: String, Hashable, CaseIterable {
    case faceContour
    case leftEye
    case rightEye
    case nose
    case outerLips
    case innerLips
    case leftEyebrow
    case rightEyebrow
}

struct FaceMetric: Identifiable, Hashable {
    let id: UUID
    let name: String
    let value: Double
    let score: Double
    let category: MetricCategory
    let verdict: String

    init(
        id: UUID = UUID(),
        name: String,
        value: Double,
        score: Double,
        category: MetricCategory,
        verdict: String
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.score = score
        self.category = category
        self.verdict = verdict
    }
}

enum MetricCategory: String, Hashable {
    case harmony
    case symmetry
    case jawline
    case eyes
    case nose
    case lips
}
