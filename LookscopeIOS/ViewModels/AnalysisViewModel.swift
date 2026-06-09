import Foundation
import PhotosUI
import SwiftUI
import UIKit

enum AppTab: Hashable {
    case scan
    case reports
    case profile
}

@MainActor
final class AnalysisViewModel: ObservableObject {
    @Published var activeTab: AppTab = .scan
    @Published var photos: [AnalysisPhoto] = []
    @Published var report: AnalysisReport?
    @Published var history: [AnalysisReport] = []
    @Published var status = "Add several photos for a richer read."
    @Published var isAnalyzing = false
    @Published var importError: String?

    @AppStorage("lookscope.api.key") var apiKey = ""
    @AppStorage("lookscope.gemini.model") var model = "gemini-2.5-flash"

    private let importer = PhotoImportService()
    private let faceService = FaceLandmarkService()
    private let gemini = GeminiVisionService()
    private let historyStore = HistoryStore()

    init() {
        history = historyStore.load()
        report = history.first
    }

    func importPhotos(from items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }

        do {
            var loadedData: [Data] = []
            for item in items {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    throw PhotoImportError.loadFailed
                }
                loadedData.append(data)
            }

            let imported = try importer.importPhotos(photoData: loadedData, faceService: faceService)
            let startIndex = photos.count
            let renumbered = imported.enumerated().map { offset, photo in
                AnalysisPhoto(
                    jpegData: photo.jpegData,
                    sourceLabel: "Photo \(startIndex + offset + 1)",
                    faceSummary: photo.faceSummary
                )
            }

            photos.append(contentsOf: renumbered)
            status = "Imported \(photos.count) photos. Ready for local scan and AI analysis."
            importError = nil
        } catch {
            importError = error.localizedDescription
            status = error.localizedDescription
        }
    }

    func addCapturedPhoto(_ image: UIImage) {
        do {
            let photo = try importer.makePhoto(
                from: image,
                label: "Photo \(photos.count + 1)",
                faceService: faceService
            )
            photos.append(photo)
            status = "Camera photo added. Total photos: \(photos.count)."
            importError = nil
        } catch {
            importError = error.localizedDescription
            status = error.localizedDescription
        }
    }

    func removePhoto(id: UUID) {
        photos.removeAll { $0.id == id }
        photos = photos.enumerated().map { index, photo in
            AnalysisPhoto(
                id: photo.id,
                jpegData: photo.jpegData,
                sourceLabel: "Photo \(index + 1)",
                createdAt: photo.createdAt,
                faceSummary: photo.faceSummary
            )
        }
        status = photos.isEmpty ? "Session cleared." : "Photo removed. \(photos.count) photos remain."
    }

    func analyze() async {
        guard !photos.isEmpty else {
            status = "Choose at least one photo first."
            return
        }

        isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let fallback = makeFallbackReport()
                apply(report: fallback)
                status = "AI key is missing, so a local premium fallback report was generated."
            } else {
                let remoteReport = try await gemini.analyze(photos: photos, apiKey: apiKey, model: model)
                apply(report: remoteReport)
                status = "AI report is ready."
            }
        } catch {
            let fallback = makeFallbackReport()
            apply(report: fallback)
            status = "AI request failed, so a local fallback report was generated."
            importError = error.localizedDescription
        }
    }

    func resetSession() {
        photos = []
        report = history.first
        status = "Session cleared."
        activeTab = .scan
    }

    private func apply(report: AnalysisReport) {
        self.report = report
        history.insert(report, at: 0)
        history = Array(history.prefix(10))
        historyStore.save(history)
        activeTab = .reports
    }

    private func makeFallbackReport() -> AnalysisReport {
        let scores = photos.compactMap { $0.faceSummary?.localScore }
        let overall = scores.isEmpty ? 6.5 : scores.reduce(0, +) / Double(scores.count)
        let landmarksAverage = photos.compactMap { $0.faceSummary?.landmarksCount }.reduce(0, +) / max(1, photos.count)
        let alignment = photos.compactMap { $0.faceSummary?.alignment }.first ?? "Partial"

        return AnalysisReport(
            overallScore: overall,
            summaryLabel: "Multi-photo premium read",
            scoreContext: "Built from local face scan across \(photos.count) photos. Add your Gemini API key for full AI commentary.",
            strengths: [
                "The app reviews several photos together instead of relying on one angle.",
                "Local Vision scan found an average of \(landmarksAverage) landmark points per image.",
                "Current face alignment read is \(alignment.lowercased()), which helps stabilize the visual summary."
            ],
            categoryScores: [
                CategoryScore(category: "Photo consistency", score: min(9.0, 5.8 + Double(photos.count) * 0.45), note: "More angles generally improve the reliability of the read."),
                CategoryScore(category: "Face scan confidence", score: min(9.1, 4.8 + Double(landmarksAverage) / 18.0), note: "Based on local Vision landmark coverage."),
                CategoryScore(category: "Presentation potential", score: min(9.0, overall + 0.4), note: "A stable multi-photo set gives the report a more polished feel.")
            ],
            suggestions: [
                Suggestion(title: "Keep 3 to 6 clean photos", reason: "A short set with front, 3/4, and profile angles gives the strongest combined read."),
                Suggestion(title: "Use one neutral background", reason: "Cleaner backgrounds make the report feel more premium and reduce noise."),
                Suggestion(title: "Add your Gemini API key in Profile", reason: "That unlocks the full AI written analysis inside the app.")
            ],
            sourceCount: photos.count,
            usedAI: false
        )
    }
}
