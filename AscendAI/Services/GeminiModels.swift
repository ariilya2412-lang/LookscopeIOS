import Foundation

struct GeminiGenerateContentRequest: Encodable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

struct GeminiContent: Encodable {
    let parts: [GeminiPart]
}

struct GeminiPart: Encodable {
    let text: String?
    let inlineData: GeminiInlineData?

    init(text: String) {
        self.text = text
        self.inlineData = nil
    }

    init(inlineData: GeminiInlineData) {
        self.text = nil
        self.inlineData = inlineData
    }
}

struct GeminiInlineData: Encodable {
    let mimeType: String
    let data: String
}

struct GeminiGenerationConfig: Encodable {
    let temperature: Double
    let responseMimeType: String
}

struct GeminiGenerateContentResponse: Decodable {
    let candidates: [GeminiCandidate]?
    let promptFeedback: GeminiPromptFeedback?
}

struct GeminiCandidate: Decodable {
    let content: GeminiResponseContent?
}

struct GeminiResponseContent: Decodable {
    let parts: [GeminiResponsePart]?
}

struct GeminiResponsePart: Decodable {
    let text: String?
}

struct GeminiPromptFeedback: Decodable {
    let blockReason: String?
}

struct GeminiReportDTO: Decodable {
    let overallScore: Double
    let summary: String
    let brutalTruth: String
    let strongestFeatures: [String]
    let weakestAreas: [String]
    let bottleneck: String
    let scores: GeminiScoresDTO
    let quickWins: [String]
    let longTermPlan: [String]
    let hairAdvice: [String]
    let skinAdvice: [String]
    let beardAdvice: [String]
    let photoAdvice: [String]
    let thirtyDayPlan: [GeminiWeeklyPlanDTO]
    let analysisSteps: [GeminiAnalysisStepDTO]
    let disclaimer: String

    func toAnalysisReport() -> AnalysisReport {
        AnalysisReport(
            overallScore: overallScore,
            summary: summary,
            brutalTruth: brutalTruth,
            strongestFeatures: strongestFeatures,
            weakestAreas: weakestAreas,
            bottleneck: bottleneck,
            scores: scores.toReportScores(),
            quickWins: quickWins,
            longTermPlan: longTermPlan,
            hairAdvice: hairAdvice,
            skinAdvice: skinAdvice,
            beardAdvice: beardAdvice,
            photoAdvice: photoAdvice,
            thirtyDayPlan: thirtyDayPlan.map { $0.toWeeklyPlan() },
            analysisSteps: analysisSteps.map { $0.toReportAnalysisStep() },
            disclaimer: disclaimer
        )
    }
}

struct GeminiScoresDTO: Decodable {
    let faceHarmony: Double
    let symmetry: Double
    let jawline: Double
    let eyeArea: Double
    let nose: Double
    let lips: Double
    let skin: Double
    let hair: Double
    let style: Double

    func toReportScores() -> ReportScores {
        ReportScores(
            faceHarmony: faceHarmony,
            symmetry: symmetry,
            jawline: jawline,
            eyeArea: eyeArea,
            nose: nose,
            lips: lips,
            skin: skin,
            hair: hair,
            style: style
        )
    }
}

struct GeminiWeeklyPlanDTO: Decodable {
    let week: Int
    let title: String
    let tasks: [String]

    func toWeeklyPlan() -> WeeklyPlan {
        WeeklyPlan(week: week, title: title, tasks: tasks)
    }
}

struct GeminiAnalysisStepDTO: Decodable {
    let title: String
    let score: Double
    let verdict: String
    let advice: String

    func toReportAnalysisStep() -> ReportAnalysisStep {
        ReportAnalysisStep(
            title: title,
            score: score,
            verdict: verdict,
            advice: advice
        )
    }
}
