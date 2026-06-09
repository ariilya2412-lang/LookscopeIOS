import Foundation
import UIKit

struct UserQuestionnaire: Codable, Hashable {
    var goal: String = "Sharper face, cleaner presentation, better photos."
    var skinType: SkinType = .combination
    var facialHair: FacialHairStyle = .lightStubble
    var hairstyleReadiness: HairstyleReadiness = .openToBigChange
    var budget: BudgetTier = .moderate
    var currentRoutine: String = "Basic cleanser, inconsistent sleep, no strict styling routine yet."
    var mainConcern: String = "Jawline definition and tired eye area."
    var honestyLevel: Int = 8
}

enum SkinType: String, CaseIterable, Codable, Identifiable {
    case dry = "Dry"
    case oily = "Oily"
    case combination = "Combination"
    case sensitive = "Sensitive"
    case normal = "Normal"

    var id: String { rawValue }
}

enum FacialHairStyle: String, CaseIterable, Codable, Identifiable {
    case cleanShaven = "Clean shaven"
    case lightStubble = "Light stubble"
    case shortBeard = "Short beard"
    case fullBeard = "Full beard"
    case patchy = "Patchy / uneven"

    var id: String { rawValue }
}

enum HairstyleReadiness: String, CaseIterable, Codable, Identifiable {
    case subtleOnly = "Only subtle changes"
    case openToBigChange = "Open to big change"
    case wantExpertDirection = "Want strong direction"

    var id: String { rawValue }
}

enum BudgetTier: String, CaseIterable, Codable, Identifiable {
    case tight = "Low"
    case moderate = "Moderate"
    case premium = "High"

    var id: String { rawValue }
}

struct UploadedPhotoAsset: Identifiable, Hashable {
    let id: UUID
    let imageData: Data
    let fileName: String

    init(id: UUID = UUID(), imageData: Data, fileName: String) {
        self.id = id
        self.imageData = imageData
        self.fileName = fileName
    }

    var uiImage: UIImage? {
        UIImage(data: imageData)
    }
}
