# LookscopeIOS

Native SwiftUI iPhone app for multi-photo face analysis.

## Included

- Multi-photo import with `PhotosPicker`
- Local Apple Vision face landmarks
- AI analysis via Gemini `generateContent`
- Scan / Reports / Profile tabs
- Local report history
- GitHub Actions workflow for unsigned IPA artifacts

## Notes

- The app can run without AI and will generate a local fallback report.
- To use Gemini directly in the app, add your API key in the Profile tab.
- For a production release, move the API key to your own backend.
