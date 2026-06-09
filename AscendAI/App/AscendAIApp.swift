import SwiftUI

@main
struct AscendAIApp: App {
    @StateObject private var viewModel = AscendFlowViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
