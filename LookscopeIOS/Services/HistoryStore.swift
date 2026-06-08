import Foundation

struct HistoryStore {
    private let key = "lookscope.report.history"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func load() -> [AnalysisReport] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        return (try? decoder.decode([AnalysisReport].self, from: data)) ?? []
    }

    func save(_ reports: [AnalysisReport]) {
        guard let data = try? encoder.encode(reports) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}
