import SwiftUI

struct PremiumButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            HapticsService.tap()
            action()
        } label: {
            HStack(spacing: 10) {
                Text(title.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(1.3)

                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(backgroundShape)
            .overlay(backgroundStroke)
            .shadow(color: Color(red: 0.34, green: 0.34, blue: 0.90).opacity(0.26), radius: 18, y: 10)
            .scaleEffect(isPressed ? 0.982 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.25, green: 0.25, blue: 0.82),
                        Color(red: 0.20, green: 0.52, blue: 0.96),
                        Color(red: 0.18, green: 0.73, blue: 0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var backgroundStroke: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .stroke(Color.white.opacity(0.14), lineWidth: 1)
    }
}
