import Foundation

enum GeminiVisionError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case emptyReply

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your Gemini API key in Profile before running AI analysis."
        case .invalidResponse:
            return "Gemini returned an invalid response."
        case .emptyReply:
            return "Gemini returned an empty reply."
        }
    }
}

struct GeminiVisionService {
    private let session = URLSession.shared

    func analyze(
        photos: [AnalysisPhoto],
        apiKey: String,
        model: String
    ) async throws -> AnalysisReport {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeminiVisionError.missingAPIKey
        }

        let prompt = """
        You are a premium appearance analysis assistant for a private iPhone app.
        Review all provided photos together as one person. Do not guess protected traits, health issues, ethnicity, religion, sexuality, disability, or exact age.
        Focus on camera presentation, visual harmony, grooming, style potential, and image quality.
        Return JSON only with this exact schema:
        {
          "overallScore": number,
          "summaryLabel": string,
          "scoreContext": string,
          "strengths": [string],
          "categoryScores": [{"category": string, "score": number, "note": string}],
          "suggestions": [{"title": string, "reason": string}]
        }
        Keep it concise, premium, and useful.
        """

        var parts: [[String: Any]] = [
            ["text": prompt]
        ]

        for photo in photos {
            parts.append([
                "inline_data": [
                    "mime_type": "image/jpeg",
                    "data": photo.jpegData.base64EncodedString()
                ]
            ])
        }

        let body: [String: Any] = [
            "contents": [[
                "parts": parts
            ]],
            "generationConfig": [
                "responseMimeType": "application/json"
            ]
        ]

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard
            let text = response.candidates.first?.content.parts.first?.text,
            !text.isEmpty
        else {
            throw GeminiVisionError.emptyReply
        }

        guard let jsonData = text.data(using: .utf8) else {
            throw GeminiVisionError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(AIReportPayload.self, from: jsonData)
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

private struct AIReportPayload: Codable {
    let overallScore: Double
    let summaryLabel: String
    let scoreContext: String
    let strengths: [String]
    let categoryScores: [CategoryScore]
    let suggestions: [Suggestion]
}

private struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

private struct GeminiCandidate: Codable {
    let content: GeminiContent
}

private struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

private struct GeminiPart: Codable {
    let text: String?
}
