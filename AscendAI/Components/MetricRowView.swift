import SwiftUI

struct MetricRowView: View {
    let label: String
    let detail: String
    let score: Double
    let rawValueText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                    Text(detail)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 3) {
                    Text(String(format: "%.1f / 10", score))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    if let rawValueText {
                        Text(rawValueText)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .tracking(1)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            ProgressBarView(progress: score / 10)
        }
        .padding(.vertical, 4)
    }
}
