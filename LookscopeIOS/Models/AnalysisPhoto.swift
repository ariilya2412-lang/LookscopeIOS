import Foundation
import UIKit

struct AnalysisPhoto: Identifiable, Hashable {
    let id: UUID
    let jpegData: Data
    let sourceLabel: String
    let createdAt: Date
    let faceSummary: FaceScanSummary?

    init(
        id: UUID = UUID(),
        jpegData: Data,
        sourceLabel: String,
        createdAt: Date = .now,
        faceSummary: FaceScanSummary? = nil
    ) {
        self.id = id
        self.jpegData = jpegData
        self.sourceLabel = sourceLabel
        self.createdAt = createdAt
        self.faceSummary = faceSummary
    }

    var uiImage: UIImage? {
        UIImage(data: jpegData)
    }
}

struct FaceScanSummary: Codable, Hashable {
    let faceCount: Int
    let landmarksCount: Int
    let alignment: String
    let localScore: Double
}
