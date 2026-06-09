import SwiftUI

struct QuestionnaireView: View {
    @EnvironmentObject private var viewModel: AscendFlowViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                textFieldCard(title: "Goal", text: Binding(
                    get: { viewModel.questionnaire.goal },
                    set: { value in viewModel.updateQuestionnaire { $0.goal = value } }
                ))
                menuCard(title: "Skin type", value: viewModel.questionnaire.skinType.rawValue, options: SkinType.allCases) {
                    questionnaire, option in
                    questionnaire.skinType = option
                }
                menuCard(title: "Facial hair", value: viewModel.questionnaire.facialHair.rawValue, options: FacialHairStyle.allCases) {
                    questionnaire, option in
                    questionnaire.facialHair = option
                }
                menuCard(title: "Hairstyle change readiness", value: viewModel.questionnaire.hairstyleReadiness.rawValue, options: HairstyleReadiness.allCases) {
                    questionnaire, option in
                    questionnaire.hairstyleReadiness = option
                }
                menuCard(title: "Budget", value: viewModel.questionnaire.budget.rawValue, options: BudgetTier.allCases) {
                    questionnaire, option in
                    questionnaire.budget = option
                }
                textEditorCard(
                    title: "Current routine",
                    text: Binding(
                        get: { viewModel.questionnaire.currentRoutine },
                        set: { value in viewModel.updateQuestionnaire { $0.currentRoutine = value } }
                    )
                )
                textFieldCard(title: "Main concern", text: Binding(
                    get: { viewModel.questionnaire.mainConcern },
                    set: { value in viewModel.updateQuestionnaire { $0.mainConcern = value } }
                ))
                honestyCard
                PrimaryActionButton(title: "Start Scan", icon: "waveform.path.ecg") {
                    viewModel.startAnalysis()
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
        }
    }

    private var header: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("PROFILE CONTEXT")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                    Text("Build the context")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                }
                Spacer()
                Text("\(Int(viewModel.questionnaireProgress * 100))%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)
            }

            ProgressBarView(progress: viewModel.questionnaireProgress)
        }
    }

    private func textFieldCard(title: String, text: Binding<String>) -> some View {
        GlassCard {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.3)
            TextField(title, text: text, axis: .vertical)
                .textInputAutocapitalization(.sentences)
                .padding(14)
                .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func textEditorCard(title: String, text: Binding<String>) -> some View {
        GlassCard {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.3)
            TextEditor(text: text)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var honestyCard: some View {
        GlassCard {
            HStack {
                Text("HONESTY LEVEL")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.3)
                Spacer()
                Text("\(viewModel.questionnaire.honestyLevel)/10")
                    .foregroundStyle(.cyan)
            }

            Slider(
                value: Binding(
                    get: { Double(viewModel.questionnaire.honestyLevel) },
                    set: { value in viewModel.updateQuestionnaire { $0.honestyLevel = Int(value.rounded()) } }
                ),
                in: 1...10,
                step: 1
            )
            .tint(.cyan)
        }
    }

    private func menuCard<Option: CaseIterable & Identifiable & RawRepresentable>(
        title: String,
        value: String,
        options: Option.AllCases,
        setter: @escaping (inout UserQuestionnaire, Option) -> Void
    ) -> some View where Option.RawValue == String {
        GlassCard {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.3)

            Menu {
                ForEach(Array(options)) { option in
                    Button(option.rawValue) {
                        viewModel.updateQuestionnaire { questionnaire in
                            setter(&questionnaire, option)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(value)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}
