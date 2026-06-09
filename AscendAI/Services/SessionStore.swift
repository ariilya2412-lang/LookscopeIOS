import Foundation

struct SessionStore {
    private let questionnaireKey = "ascend.questionnaire"

    func save(questionnaire: UserQuestionnaire) {
        guard let data = try? JSONEncoder().encode(questionnaire) else { return }
        UserDefaults.standard.set(data, forKey: questionnaireKey)
    }

    func loadQuestionnaire() -> UserQuestionnaire? {
        guard let data = UserDefaults.standard.data(forKey: questionnaireKey) else { return nil }
        return try? JSONDecoder().decode(UserQuestionnaire.self, from: data)
    }
}
