import Foundation

struct AnalysisReport: Identifiable, Hashable {
    let id: UUID
    let createdAt: Date
    let overallScore: Double
    let summary: String
    let brutalTruth: String
    let strongestFeatures: [String]
    let weakestAreas: [String]
    let bottleneck: String
    let scores: ReportScores
    let quickWins: [String]
    let longTermPlan: [String]
    let hairAdvice: [String]
    let skinAdvice: [String]
    let beardAdvice: [String]
    let photoAdvice: [String]
    let thirtyDayPlan: [WeeklyPlan]
    let analysisSteps: [ReportAnalysisStep]
    let disclaimer: String

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        overallScore: Double,
        summary: String,
        brutalTruth: String,
        strongestFeatures: [String],
        weakestAreas: [String],
        bottleneck: String,
        scores: ReportScores,
        quickWins: [String],
        longTermPlan: [String],
        hairAdvice: [String],
        skinAdvice: [String],
        beardAdvice: [String],
        photoAdvice: [String],
        thirtyDayPlan: [WeeklyPlan],
        analysisSteps: [ReportAnalysisStep],
        disclaimer: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.overallScore = overallScore
        self.summary = summary
        self.brutalTruth = brutalTruth
        self.strongestFeatures = strongestFeatures
        self.weakestAreas = weakestAreas
        self.bottleneck = bottleneck
        self.scores = scores
        self.quickWins = quickWins
        self.longTermPlan = longTermPlan
        self.hairAdvice = hairAdvice
        self.skinAdvice = skinAdvice
        self.beardAdvice = beardAdvice
        self.photoAdvice = photoAdvice
        self.thirtyDayPlan = thirtyDayPlan
        self.analysisSteps = analysisSteps
        self.disclaimer = disclaimer
    }

    var bottleneckDetected: String {
        bottleneck
    }

    var scoreBreakdown: [ScoreBreakdown] {
        [
            ScoreBreakdown(title: "Face harmony", score: scores.faceHarmony, note: "Approximate read on central proportion balance."),
            ScoreBreakdown(title: "Symmetry", score: scores.symmetry, note: "Visual left-right balance based on AI review and landmark alignment."),
            ScoreBreakdown(title: "Jawline", score: scores.jawline, note: "How sharp and structured the lower third reads in the current presentation."),
            ScoreBreakdown(title: "Eye area", score: scores.eyeArea, note: "How alert and photogenic the eye zone appears."),
            ScoreBreakdown(title: "Skin", score: scores.skin, note: "Visible grooming quality only, not a medical diagnosis."),
            ScoreBreakdown(title: "Hair", score: scores.hair, note: "How much the haircut supports the face frame.")
        ]
    }

    var analysisTimelineSteps: [AnalysisStep] {
        analysisSteps.map { step in
            AnalysisStep(
                title: step.title,
                detail: step.advice,
                accent: step.verdict,
                state: .completed
            )
        }
    }
}

struct ReportScores: Hashable {
    let faceHarmony: Double
    let symmetry: Double
    let jawline: Double
    let eyeArea: Double
    let nose: Double
    let lips: Double
    let skin: Double
    let hair: Double
    let style: Double
}

struct ScoreBreakdown: Identifiable, Hashable {
    let id: UUID
    let title: String
    let score: Double
    let note: String

    init(id: UUID = UUID(), title: String, score: Double, note: String) {
        self.id = id
        self.title = title
        self.score = score
        self.note = note
    }
}

struct WeeklyPlan: Identifiable, Hashable {
    let id: UUID
    let week: Int
    let title: String
    let tasks: [String]

    init(id: UUID = UUID(), week: Int, title: String, tasks: [String]) {
        self.id = id
        self.week = week
        self.title = title
        self.tasks = tasks
    }

    var weekTitle: String {
        "Week \(week)"
    }

    var focus: String {
        title
    }

    var actions: [String] {
        tasks
    }
}

struct ReportAnalysisStep: Identifiable, Hashable {
    let id: UUID
    let title: String
    let score: Double
    let verdict: String
    let advice: String

    init(
        id: UUID = UUID(),
        title: String,
        score: Double,
        verdict: String,
        advice: String
    ) {
        self.id = id
        self.title = title
        self.score = score
        self.verdict = verdict
        self.advice = advice
    }
}
