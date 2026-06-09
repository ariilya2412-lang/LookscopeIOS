import Foundation
import UIKit

enum GeminiAPIServiceError: LocalizedError {
    case invalidConfiguration
    case imageEncodingFailed
    case invalidEndpoint
    case requestFailed(Int, String)
    case emptyResponse
    case blocked(String)
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Gemini API key is missing."
        case .imageEncodingFailed:
            return "Could not prepare the selected image for AI analysis."
        case .invalidEndpoint:
            return "Gemini endpoint is invalid."
        case let .requestFailed(code, message):
            return "Gemini HTTP error \(code): \(message)"
        case .emptyResponse:
            return "Gemini returned an empty response."
        case let .blocked(reason):
            return "Gemini blocked the request: \(reason)"
        case .invalidJSON:
            return "Gemini returned a response that could not be decoded into the report format."
        }
    }
}

final class GeminiAPIService {
    func generateReport(
        image: UIImage,
        questionnaire: UserQuestionnaire,
        localMetrics: [FaceMetric]
    ) async throws -> AnalysisReport {
        guard !Config.geminiAPIKey.contains("PASTE_GEMINI_API_KEY_HERE") else {
            throw GeminiAPIServiceError.invalidConfiguration
        }

        guard let url = URL(string: Config.geminiEndpoint) else {
            throw GeminiAPIServiceError.invalidEndpoint
        }

        guard let imageData = prepareImageData(from: image) else {
            throw GeminiAPIServiceError.imageEncodingFailed
        }

        let prompt = buildPrompt(questionnaire: questionnaire, localMetrics: localMetrics)
        let body = GeminiGenerateContentRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(text: prompt),
                        GeminiPart(
                            inlineData: GeminiInlineData(
                                mimeType: "image/jpeg",
                                data: imageData.base64EncodedString()
                            )
                        )
                    ]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.45,
                responseMimeType: "application/json"
            )
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiAPIServiceError.emptyResponse
        }

        if !(200 ... 299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Unknown Gemini error."
            throw GeminiAPIServiceError.requestFailed(httpResponse.statusCode, message)
        }

        let apiResponse = try JSONDecoder().decode(GeminiGenerateContentResponse.self, from: data)
        if let blockReason = apiResponse.promptFeedback?.blockReason {
            throw GeminiAPIServiceError.blocked(blockReason)
        }

        guard let rawText = apiResponse.candidates?
            .first?
            .content?
            .parts?
            .compactMap(\.text)
            .joined(separator: "\n"),
              !rawText.isEmpty else {
            throw GeminiAPIServiceError.emptyResponse
        }

        let cleanedJSON = cleanJSON(rawText)
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw GeminiAPIServiceError.invalidJSON
        }

        do {
            let dto = try JSONDecoder().decode(GeminiReportDTO.self, from: jsonData)
            return dto.toAnalysisReport()
        } catch {
            throw GeminiAPIServiceError.invalidJSON
        }
    }

    private func prepareImageData(from image: UIImage) -> Data? {
        let maxDimension: CGFloat = 1600
        let longestSide = max(image.size.width, image.size.height)
        let scale = min(1, maxDimension / max(longestSide, 1))
        let targetSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resized.jpegData(compressionQuality: 0.7)
    }

    private func cleanJSON(_ raw: String) -> String {
        // Gemini can still wrap JSON in fenced markdown even when we request raw JSON,
        // so we normalize that here before decoding into the app DTOs.
        var cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func buildPrompt(
        questionnaire: UserQuestionnaire,
        localMetrics: [FaceMetric]
    ) -> String {
        let honestyMode = questionnaire.honestyLevel >= 9 ? "Brutally Honest" : "Direct"
        let metricsSummary = localMetrics.map {
            "\($0.name): score=\(String(format: "%.1f", $0.score))/10, value=\(String(format: "%.3f", $0.value)), verdict=\($0.verdict)"
        }
        .joined(separator: "\n")

        return """
        You are an AI facial analysis and looksmaxing assistant.
        Analyze the user's photo, questionnaire, and local geometric metrics.
        Generate a direct, practical, brutally honest but non-insulting facial improvement report.

        Rules:
        - Do not flatter the user.
        - Do not insult the user.
        - Be direct, specific, and useful.
        - Focus on controllable improvements: grooming, skincare, haircut, beard, posture, fitness, lighting, photo angles, style.
        - Do not diagnose medical conditions.
        - Do not recommend surgery as the default.
        - Do not claim the analysis is scientifically perfect.
        - If honesty level is "Brutally Honest", be more direct, but still respectful.
        - Separate quick wins from long-term improvements.
        - Identify the biggest bottleneck.
        - Return only valid JSON. No markdown. No explanation outside JSON.

        Honesty mode: \(honestyMode)
        Questionnaire:
        - Goal: \(questionnaire.goal)
        - Skin type: \(questionnaire.skinType.rawValue)
        - Facial hair: \(questionnaire.facialHair.rawValue)
        - Hairstyle change readiness: \(questionnaire.hairstyleReadiness.rawValue)
        - Budget: \(questionnaire.budget.rawValue)
        - Current routine: \(questionnaire.currentRoutine)
        - Main concern: \(questionnaire.mainConcern)
        - Honesty level: \(questionnaire.honestyLevel)/10

        Local metrics:
        \(metricsSummary)

        JSON schema:
        {
          "overallScore": 0.0,
          "summary": "string",
          "brutalTruth": "string",
          "strongestFeatures": ["string"],
          "weakestAreas": ["string"],
          "bottleneck": "string",
          "scores": {
            "faceHarmony": 0.0,
            "symmetry": 0.0,
            "jawline": 0.0,
            "eyeArea": 0.0,
            "nose": 0.0,
            "lips": 0.0,
            "skin": 0.0,
            "hair": 0.0,
            "style": 0.0
          },
          "quickWins": ["string"],
          "longTermPlan": ["string"],
          "hairAdvice": ["string"],
          "skinAdvice": ["string"],
          "beardAdvice": ["string"],
          "photoAdvice": ["string"],
          "thirtyDayPlan": [
            {
              "week": 1,
              "title": "string",
              "tasks": ["string"]
            }
          ],
          "analysisSteps": [
            {
              "title": "string",
              "score": 0.0,
              "verdict": "string",
              "advice": "string"
            }
          ],
          "disclaimer": "This analysis is for entertainment and self-improvement guidance only. It is not medical, psychological, or cosmetic surgery advice."
        }
        """
    }
}
