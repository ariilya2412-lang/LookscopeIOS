import Foundation

struct AnalysisStep: Identifiable, Hashable {
    let id: UUID
    let title: String
    let detail: String
    let accent: String
    let state: StepState

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        accent: String,
        state: StepState
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.accent = accent
        self.state = state
    }
}

enum StepState: String, Hashable {
    case queued
    case processing
    case completed
}
