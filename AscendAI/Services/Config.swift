import Foundation

enum Config {
    // TODO: In production, API keys must be stored on a backend, not in the iOS app.
    static let geminiAPIKey = "PASTE_GEMINI_API_KEY_HERE"
    static let geminiEndpointTemplate = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=%@"

    static var geminiEndpoint: String {
        String(format: geminiEndpointTemplate, geminiAPIKey)
    }
}
