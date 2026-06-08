import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: AnalysisViewModel

    var body: some View {
        TabView(selection: $viewModel.activeTab) {
            NavigationStack {
                ScanView()
            }
            .tabItem {
                Label("Scan", systemImage: "viewfinder")
            }
            .tag(AppTab.scan)

            NavigationStack {
                ReportView()
            }
            .tabItem {
                Label("Reports", systemImage: "chart.bar.xaxis")
            }
            .tag(AppTab.reports)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
            .tag(AppTab.profile)
        }
        .tint(.mint)
    }
}
