import SwiftUI

@main
struct LookscopeApp: App {
    @StateObject private var viewModel = AnalysisViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
