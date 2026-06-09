import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: AscendFlowViewModel

    var body: some View {
        GradientStageBackground {
            ZStack {
                switch viewModel.currentScreen {
                case .onboarding:
                    OnboardingView()
                case .photoUpload:
                    PhotoUploadView()
                case .questionnaire:
                    QuestionnaireView()
                case .scanning:
                    ScanningView()
                case .analysisSteps:
                    AnalysisStepsView()
                case .report:
                    ReportView()
                case .paywall:
                    PaywallView()
                }
            }
            .animation(.spring(response: 0.52, dampingFraction: 0.86), value: viewModel.currentScreen)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)).combined(with: .scale(scale: 0.985)),
                removal: .opacity.combined(with: .move(edge: .leading))
            ))
        }
    }
}
