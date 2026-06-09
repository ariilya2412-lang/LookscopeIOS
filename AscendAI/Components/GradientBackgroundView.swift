import SwiftUI

struct GradientBackgroundView<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.05, green: 0.06, blue: 0.09),
                    Color(red: 0.06, green: 0.07, blue: 0.13)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 0.42, green: 0.37, blue: 0.98).opacity(0.26),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 360
            )
            .ignoresSafeArea()
            .offset(x: 110, y: -180)

            RadialGradient(
                colors: [
                    Color(red: 0.20, green: 0.76, blue: 0.98).opacity(0.14),
                    .clear
                ],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 340
            )
            .ignoresSafeArea()
            .offset(x: -120, y: 220)

            content
        }
    }
}
