import Foundation
import PhotosUI
import SwiftUI
import UIKit

enum AscendScreen: Hashable {
    case onboarding
    case photoUpload
    case questionnaire
    case scanning
    case analysisSteps
    case report
    case paywall
}

@MainActor
final class AscendFlowViewModel: ObservableObject {
    @Published var currentScreen: AscendScreen = .onboarding
    @Published var selectedPhoto: UploadedPhotoAsset?
    @Published var questionnaire: UserQuestionnaire
    @Published var report: AnalysisReport?
    @Published var analysisSteps: [AnalysisStep] = []
    @Published var scanningStatus: String = "Detecting face..."
    @Published var scanningProgress: Double = 0
    @Published var isScanning = false
    @Published var importError: String?
    @Published var faceAnalysisResult: FaceAnalysisResult?
    @Published var scanningErrorMessage: String?
    @Published var aiStatusMessage: String?

    let scanningStages = [
        "Detecting face...",
        "Mapping facial landmarks...",
        "Measuring symmetry...",
        "Checking jawline structure...",
        "Analyzing eye area...",
        "Evaluating skin and grooming...",
        "Generating looksmax plan..."
    ]

    private let photoImportService = PhotoImportService()
    private let geminiAPIService = GeminiAPIService()
    private let recommendationEngine = RecommendationEngine()
    private let sessionStore = SessionStore()
    private let visionFaceAnalyzer = VisionFaceAnalyzer()
    private let looksmaxScoringEngine = LooksmaxScoringEngine()

    init() {
        questionnaire = sessionStore.loadQuestionnaire() ?? UserQuestionnaire()
    }

    var questionnaireProgress: Double {
        let textFields = [
            questionnaire.goal.trimmingCharacters(in: .whitespacesAndNewlines),
            questionnaire.currentRoutine.trimmingCharacters(in: .whitespacesAndNewlines),
            questionnaire.mainConcern.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        let filled = textFields.filter { !$0.isEmpty }.count
        return Double(filled + 5) / 8.0
    }

    func beginFlow() {
        HapticsService.tap()
        currentScreen = .photoUpload
    }

    func importPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw PhotoImportError.loadFailed
            }
            let photo = try photoImportService.importPhoto(
                data: data,
                fileName: item.itemIdentifier ?? "portrait"
            )
            selectedPhoto = photo
            importError = nil
            HapticsService.success()
        } catch {
            importError = error.localizedDescription
            HapticsService.warning()
        }
    }

    func continueToQuestionnaire() {
        guard selectedPhoto != nil else {
            importError = "Add a portrait first."
            HapticsService.warning()
            return
        }
        HapticsService.tap()
        currentScreen = .questionnaire
    }

    func updateQuestionnaire(_ update: (inout UserQuestionnaire) -> Void) {
        update(&questionnaire)
        sessionStore.save(questionnaire: questionnaire)
    }

    func startAnalysis() {
        sessionStore.save(questionnaire: questionnaire)
        scanningErrorMessage = nil
        faceAnalysisResult = nil
        report = nil
        analysisSteps = []
        aiStatusMessage = nil
        currentScreen = .scanning
    }

    func runScanningSequenceIfNeeded() async {
        guard !isScanning else { return }
        guard let image = selectedPhoto?.uiImage else {
            scanningErrorMessage = "No clear face detected. Try a front-facing photo with better lighting."
            return
        }

        isScanning = true
        scanningProgress = 0
        scanningErrorMessage = nil

        do {
            scanningStatus = scanningStages[0]
            scanningProgress = 1.0 / Double(scanningStages.count)
            HapticsService.tap()
            try? await Task.sleep(for: .milliseconds(520))

            let rawResult = try await visionFaceAnalyzer.analyzeFace(in: image)
            let localMetrics = looksmaxScoringEngine.generateLocalMetrics(from: rawResult)
            let result = FaceAnalysisResult(
                faceBoundingBox: rawResult.faceBoundingBox,
                landmarks: rawResult.landmarks,
                metrics: localMetrics,
                qualityScore: rawResult.qualityScore,
                warningMessage: rawResult.warningMessage
            )
            faceAnalysisResult = result

            for (index, stage) in scanningStages.enumerated().dropFirst() {
                scanningStatus = stage
                scanningProgress = Double(index + 1) / Double(scanningStages.count)
                HapticsService.tap()
                try? await Task.sleep(for: .milliseconds(index == scanningStages.count - 1 ? 780 : 520))
            }

            do {
                let aiReport = try await geminiAPIService.generateReport(
                    image: image,
                    questionnaire: questionnaire,
                    localMetrics: localMetrics
                )
                report = aiReport
                analysisSteps = aiReport.analysisTimelineSteps
                aiStatusMessage = nil
            } catch {
                // The demo must stay usable even when Gemini is rate-limited or unavailable.
                let fallbackReport = recommendationEngine.makeReport(
                    for: questionnaire,
                    hasPhoto: selectedPhoto != nil,
                    faceAnalysis: result
                )
                report = fallbackReport
                analysisSteps = fallbackReport.analysisTimelineSteps
                aiStatusMessage = "AI report unavailable. Generated a local report instead."
            }
            isScanning = false
            HapticsService.success()
            currentScreen = .analysisSteps
        } catch {
            isScanning = false
            scanningProgress = 0
            scanningErrorMessage = error.localizedDescription
            HapticsService.warning()
        }
    }

    func continueToReport() {
        HapticsService.tap()
        currentScreen = .report
    }

    func openPaywall() {
        HapticsService.tap()
        currentScreen = .paywall
    }

    func backToReport() {
        HapticsService.tap()
        currentScreen = .report
    }

    func restart() {
        HapticsService.tap()
        selectedPhoto = nil
        report = nil
        analysisSteps = []
        faceAnalysisResult = nil
        scanningErrorMessage = nil
        aiStatusMessage = nil
        scanningProgress = 0
        scanningStatus = scanningStages.first ?? "Detecting face..."
        isScanning = false
        currentScreen = .onboarding
    }

    func returnToPhotoUpload() {
        HapticsService.tap()
        scanningErrorMessage = nil
        faceAnalysisResult = nil
        aiStatusMessage = nil
        scanningProgress = 0
        scanningStatus = scanningStages.first ?? "Detecting face..."
        currentScreen = .photoUpload
    }
}
