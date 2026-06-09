import Foundation

enum GeminiVisionError: LocalizedError {
    case missingRelayURL
    case invalidRelayURL
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .missingRelayURL:
            return "Add your PC relay URL in Profile before running AI analysis."
        case .invalidRelayURL:
            return "The relay URL is invalid."
        case .invalidResponse:
            return "The relay server returned an invalid response."
        case .serverError(let message):
            return message
        }
    }
}

struct GeminiVisionService {
    private let session = URLSession.shared

    func analyze(
        photos: [AnalysisPhoto],
        relayURL: String,
        model: String
    ) async throws -> AnalysisReport {
        let trimmedURL = relayURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty else {
            throw GeminiVisionError.missingRelayURL
        }

        guard let url = URL(string: trimmedURL + "/analyze") else {
            throw GeminiVisionError.invalidRelayURL
        }

        let body = RelayAnalyzeRequest(
            model: model,
            photos: photos.map {
                RelayPhotoPayload(
                    label: $0.sourceLabel,
                    jpegBase64: $0.jpegData.base64EncodedString()
                )
            }
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 180
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw GeminiVisionError.invalidResponse
        }

        if !(200...299).contains(http.statusCode) {
            let relayError = try? JSONDecoder().decode(RelayErrorResponse.self, from: data)
            throw GeminiVisionError.serverError(relayError?.error ?? "Relay server error \(http.statusCode).")
        }

        let decoded = try JSONDecoder().decode(RelayAnalyzeResponse.self, from: data)
        return AnalysisReport(
            overallScore: decoded.overallScore,
            summaryLabel: decoded.summaryLabel,
            scoreContext: decoded.scoreContext,
            strengths: decoded.strengths,
            categoryScores: decoded.categoryScores,
            suggestions: decoded.suggestions,
            sourceCount: photos.count,
            usedAI: true
        )
    }
}

private struct RelayAnalyzeRequest: Codable {
    let model: String
    let photos: [RelayPhotoPayload]
}

private struct RelayPhotoPayload: Codable {
    let label: String
    let jpegBase64: String
}

private struct RelayAnalyzeResponse: Codable {
    let overallScore: Double
    let summaryLabel: String
    let scoreContext: String
    let strengths: [String]
    let categoryScores: [CategoryScore]
    let suggestions: [Suggestion]
}

private struct RelayErrorResponse: Codable {
    let error: String
}
