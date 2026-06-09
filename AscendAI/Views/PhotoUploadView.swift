import PhotosUI
import SwiftUI

struct PhotoUploadView: View {
    @EnvironmentObject private var viewModel: AscendFlowViewModel
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                titleSection
                previewCard
                uploadAction
                PrimaryActionButton(title: "Continue", icon: "arrow.right") {
                    viewModel.continueToQuestionnaire()
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
        }
        .alert("Import issue", isPresented: Binding(
            get: { viewModel.importError != nil },
            set: { if !$0 { viewModel.importError = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.importError ?? "Unknown import issue.")
        }
        .onChange(of: selectedItem) { _, newValue in
            Task {
                await viewModel.importPhoto(from: newValue)
            }
        }
    }

    private var titleSection: some View {
        GlassCard {
            Text("PHOTO SCAN")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.secondary)
            Text("Upload a front portrait")
                .font(.system(size: 30, weight: .bold, design: .rounded))
            Text("Use neutral lighting and keep the full face visible. Clean framing gives both Vision and the fallback report a stronger base.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var previewCard: some View {
        GlassCard {
            GeometryReader { proxy in
                let previewHeight = min(max(proxy.size.width * 1.08, 250), 360)

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                        .frame(height: previewHeight)

                    if let image = viewModel.selectedPhoto?.uiImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: previewHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.square")
                                .font(.system(size: 54))
                                .foregroundStyle(.white.opacity(0.74))
                            Text("No portrait selected yet")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Text("Choose one clear front photo.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(height: 360)
        }
    }

    private var uploadAction: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            HStack(spacing: 10) {
                Text("CHOOSE PHOTO")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(1.2)
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
