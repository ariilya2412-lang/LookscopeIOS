import Foundation

struct RecommendationEngine {
    func makeReport(
        for questionnaire: UserQuestionnaire,
        hasPhoto: Bool,
        faceAnalysis: FaceAnalysisResult?
    ) -> AnalysisReport {
        let honestyBonus = Double(questionnaire.honestyLevel) * 0.08
        let beardBonus = questionnaire.facialHair == .lightStubble ? 0.35 : 0
        let hairFlexBonus = questionnaire.hairstyleReadiness == .openToBigChange ? 0.4 : 0.15
        let photoBonus = hasPhoto ? 0.55 : 0
        let visionBonus = (faceAnalysis?.qualityScore ?? 0.4) * 0.55
        let overall = min(9.4, max(5.9, 6.2 + honestyBonus + beardBonus + hairFlexBonus + photoBonus + visionBonus))

        let metricMap = Dictionary(uniqueKeysWithValues: (faceAnalysis?.metrics ?? []).map { ($0.category, $0) })
        let scores = ReportScores(
            faceHarmony: metricMap[.harmony]?.score ?? 7.0,
            symmetry: metricMap[.symmetry]?.score ?? 6.8,
            jawline: metricMap[.jawline]?.score ?? min(9.0, overall + 0.2),
            eyeArea: metricMap[.eyes]?.score ?? 6.9,
            nose: metricMap[.nose]?.score ?? 7.1,
            lips: metricMap[.lips]?.score ?? 6.7,
            skin: min(8.9, overall - 0.25),
            hair: questionnaire.hairstyleReadiness == .openToBigChange ? 7.8 : 6.9,
            style: min(8.8, overall + 0.1)
        )

        return AnalysisReport(
            overallScore: overall,
            summary: "A usable base with clear upside. The biggest gains are practical: better grooming consistency, cleaner photo presentation, and sharper style discipline.",
            brutalTruth: "Your face is not the main problem. Inconsistent lighting, tired photos, and weak grooming decisions are making it read worse than it should.",
            strongestFeatures: [
                "There is enough structure to respond well to disciplined grooming.",
                "Small upgrades in hair, skin, and photo control can noticeably raise the overall read.",
                "The face has decent improvement headroom without relying on extreme interventions."
            ],
            weakestAreas: [
                questionnaire.mainConcern,
                "Presentation consistency under average lighting.",
                "Lack of one locked-in haircut and grooming direction."
            ],
            bottleneck: "The main bottleneck is inconsistency. Your appearance drops whenever sleep, lighting, hairstyle control, and posture are all left unmanaged.",
            scores: scores,
            quickWins: [
                "Choose one haircut direction and stop drifting between styles.",
                "Use window light and a slightly higher camera angle before judging your face.",
                "Tighten sleep and grooming consistency to improve the eye area fast."
            ],
            longTermPlan: [
                "Improve facial presentation through sleep discipline, body-fat management, and better posture.",
                "Build a repeatable routine instead of relying on random good days.",
                "Track progress with matching daylight photos every 2 weeks."
            ],
            hairAdvice: makeHairAdvice(for: questionnaire),
            skinAdvice: makeSkinAdvice(for: questionnaire),
            beardAdvice: makeBeardAdvice(for: questionnaire),
            photoAdvice: [
                "Use front-facing daylight, not dark room lighting.",
                "Keep the phone slightly above eye level to reduce lower-face distortion.",
                "Avoid tired late-night selfies if you want an honest visual baseline."
            ],
            thirtyDayPlan: [
                WeeklyPlan(
                    week: 1,
                    title: "Reset the baseline",
                    tasks: [
                        "Pick one haircut direction and collect 3 reference photos.",
                        "Take a clean daylight front-facing photo set.",
                        "Simplify skincare to cleanser, moisturizer, and SPF."
                    ]
                ),
                WeeklyPlan(
                    week: 2,
                    title: "Sharpen grooming",
                    tasks: [
                        "Tighten beard lines or commit to clean shave.",
                        "Practice hair control with less randomness.",
                        "Fix one repeated photo mistake: angle, clutter, or bad light."
                    ]
                ),
                WeeklyPlan(
                    week: 3,
                    title: "Improve structure",
                    tasks: [
                        "Use cleaner necklines and darker, calmer colors near the face.",
                        "Stay strict with sleep timing for a full week.",
                        "Compare progress photos against week 1."
                    ]
                ),
                WeeklyPlan(
                    week: 4,
                    title: "Lock the upgraded version",
                    tasks: [
                        "Keep only the habits that visibly improved your face.",
                        "Retake photos in matching daylight.",
                        "Write down the maintenance routine you can actually sustain."
                    ]
                )
            ],
            analysisSteps: [
                ReportAnalysisStep(
                    title: "Face harmony",
                    score: scores.faceHarmony,
                    verdict: scores.faceHarmony >= 7.5 ? "Stable" : "Needs cleaner framing",
                    advice: "Central proportions read better in a neutral front-facing shot with even light."
                ),
                ReportAnalysisStep(
                    title: "Jawline read",
                    score: scores.jawline,
                    verdict: scores.jawline >= 7.5 ? "Promising" : "Angle-dependent",
                    advice: "Posture, body-fat level, and camera tilt will strongly affect lower-face definition."
                ),
                ReportAnalysisStep(
                    title: "Eye area",
                    score: scores.eyeArea,
                    verdict: scores.eyeArea >= 7.5 ? "Good presence" : "Fatigue showing",
                    advice: "Sleep, hydration, and less harsh lighting will clean up this zone fastest."
                )
            ],
            disclaimer: "This analysis is for entertainment and self-improvement guidance only. It is not medical, psychological, or cosmetic surgery advice."
        )
    }

    private func makeHairAdvice(for questionnaire: UserQuestionnaire) -> [String] {
        switch questionnaire.hairstyleReadiness {
        case .subtleOnly:
            return [
                "Keep the sides compact and remove extra width around the temples.",
                "Controlled texture will look more premium than messy bulk."
            ]
        case .openToBigChange:
            return [
                "A stronger top-to-side contrast should help the face read sharper.",
                "Ask for a shape-first haircut, not just a shorter fade."
            ]
        case .wantExpertDirection:
            return [
                "Get a silhouette-focused cut that builds structure near the temples and crown.",
                "Prioritize face framing over trend-chasing."
            ]
        }
    }

    private func makeSkinAdvice(for questionnaire: UserQuestionnaire) -> [String] {
        switch questionnaire.skinType {
        case .dry:
            return [
                "Barrier support and hydration matter more than aggressive actives right now.",
                "Use a richer moisturizer consistently."
            ]
        case .oily:
            return [
                "Oil control and clarity are the highest ROI targets.",
                "Use a salicylic cleanser and lighter moisturizer."
            ]
        case .combination:
            return [
                "Keep the routine simple and avoid over-treating the whole face.",
                "Target only the areas that truly need more control."
            ]
        case .sensitive:
            return [
                "Reduce irritation first with gentle, fragrance-free products.",
                "Avoid stacking too many harsh actives at once."
            ]
        case .normal:
            return [
                "Your biggest gains come from consistency, SPF, and better recovery.",
                "Do not overcomplicate a routine that already works."
            ]
        }
    }

    private func makeBeardAdvice(for questionnaire: UserQuestionnaire) -> [String] {
        switch questionnaire.facialHair {
        case .cleanShaven:
            return [
                "If you stay clean-shaven, make it look intentional and sharp.",
                "Without beard support, lighting and jaw posture matter even more."
            ]
        case .lightStubble:
            return [
                "Light stubble is often the best low-risk option if density is decent.",
                "Keep the neckline disciplined or it stops looking premium."
            ]
        case .shortBeard:
            return [
                "A short beard can add structure if the cheek and neckline are controlled.",
                "Trim bulk before it softens the lower face."
            ]
        case .fullBeard:
            return [
                "A full beard only helps if density is strong and shape is clean.",
                "Avoid extra width that makes the face look heavier."
            ]
        case .patchy:
            return [
                "Patchy growth usually looks worse than clean shave or tight stubble.",
                "Choose neatness over forcing density that is not there."
            ]
        }
    }
}
