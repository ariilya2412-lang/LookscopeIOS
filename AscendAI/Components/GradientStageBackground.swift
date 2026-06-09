import SwiftUI

struct GradientStageBackground<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        GradientBackgroundView {
            content
        }
    }
}
