import Foundation

struct AnalysisReport: Codable, Identifiable, Hashable {
    let id: UUID
    let createdAt: Date
    let overallScore: Double
    let summaryLabel: String
    let scoreContext: String
    let strengths: [String]
    let categoryScores: [CategoryScore]
    let suggestions: [Suggestion]
    let sourceCount: Int
    let usedAI: Bool

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        overallScore: Double,
        summaryLabel: String,
        scoreContext: String,
        strengths: [String],
        categoryScores: [CategoryScore],
        suggestions: [Suggestion],
        sourceCount: Int,
        usedAI: Bool
    ) {
        self.id = id
        self.createdAt = createdAt
        self.overallScore = overallScore
        self.summaryLabel = summaryLabel
        self.scoreContext = scoreContext
        self.strengths = strengths
        self.categoryScores = categoryScores
        self.suggestions = suggestions
        self.sourceCount = sourceCount
        self.usedAI = usedAI
    }
}

struct CategoryScore: Codable, Hashable, Identifiable {
    let id = UUID()
    let category: String
    let score: Double
    let note: String

    enum CodingKeys: String, CodingKey {
        case category
        case score
        case note
    }
}

struct Suggestion: Codable, Hashable, Identifiable {
    let id = UUID()
    let title: String
    let reason: String

    enum CodingKeys: String, CodingKey {
        case title
        case reason
    }
}
