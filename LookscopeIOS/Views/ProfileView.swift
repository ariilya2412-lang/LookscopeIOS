import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var viewModel: AnalysisViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.04, blue: 0.10), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    settingsCard
                    historyCard
                }
                .padding(18)
            }
        }
        .navigationTitle("Profile")
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Gemini settings")
                .font(.headline)

            SecureField("Gemini API key", text: $viewModel.apiKey)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            TextField("Model", text: $viewModel.model)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text("The app sends selected photos directly to Gemini generateContent with inline image parts. For a production app, move the key to your own backend.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent reports")
                .font(.headline)

            if viewModel.history.isEmpty {
                Text("No history yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.history) { report in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(report.summaryLabel)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text(String(format: "%.1f", report.overallScore))
                                .foregroundStyle(.mint)
                        }
                        Text(report.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
