import PhotosUI
import SwiftUI
import UIKit

struct ScanView: View {
    @EnvironmentObject private var viewModel: AnalysisViewModel
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCamera = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.04, green: 0.08, blue: 0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    headerCard
                    photoPickerCard
                    localScanCard
                    actionCard
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Lookscope")
        .onChange(of: selectedItems) { _, newValue in
            Task {
                await viewModel.importPhotos(from: newValue)
                selectedItems = []
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { image in
                viewModel.addCapturedPhoto(image)
            }
            .ignoresSafeArea()
        }
        .alert("Import issue", isPresented: Binding(
            get: { viewModel.importError != nil },
            set: { if !$0 { viewModel.importError = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.importError ?? "Unknown issue.")
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Private visual analysis")
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.mint)

            Text("Multi-photo face scan for iPhone")
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text("Select several photos, run a local face scan, then let Gemini build a richer appearance report across the whole set.")
                .foregroundStyle(.secondary)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var photoPickerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 8,
                    matching: .images
                ) {
                    Label("Choose photos", systemImage: "photo.on.rectangle.angled")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [.yellow, .mint, .cyan], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                        )
                        .foregroundStyle(.black)
                }

                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button {
                        showCamera = true
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.headline)
                            .frame(width: 58, height: 58)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            if viewModel.photos.isEmpty {
                Text("Front, side, and 3/4 angles work best.")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.photos) { photo in
                            VStack(alignment: .leading, spacing: 6) {
                                ZStack(alignment: .topTrailing) {
                                    if let image = photo.uiImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 112, height: 140)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    }

                                    Button {
                                        viewModel.removePhoto(id: photo.id)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                            .padding(8)
                                            .background(.black.opacity(0.7), in: Circle())
                                    }
                                    .padding(8)
                                    .buttonStyle(.plain)
                                }

                                Text(photo.sourceLabel)
                                    .font(.caption.weight(.semibold))

                                Text(photo.faceSummary?.alignment ?? "Pending")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var localScanCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Local face scan")
                .font(.headline)

            if viewModel.photos.isEmpty {
                Text("No photos loaded yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.photos) { photo in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(photo.sourceLabel)
                                .font(.subheadline.weight(.semibold))
                            Text("Faces: \(photo.faceSummary?.faceCount ?? 0) - Landmarks: \(photo.faceSummary?.landmarksCount ?? 0)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(photo.faceSummary?.alignment ?? "Pending")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.08), in: Capsule())
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.status)
                .font(.callout)
                .foregroundStyle(.secondary)

            Button {
                Task {
                    await viewModel.analyze()
                }
            } label: {
                HStack {
                    if viewModel.isAnalyzing {
                        ProgressView()
                            .tint(.black)
                    }
                    Text(viewModel.isAnalyzing ? "Analyzing..." : "Run AI analysis")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(colors: [.mint, .cyan], startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
                .foregroundStyle(.black)
            }
            .disabled(viewModel.photos.isEmpty || viewModel.isAnalyzing)

            if !viewModel.photos.isEmpty {
                Button("Reset session", role: .destructive) {
                    viewModel.resetSession()
                }
                .font(.subheadline.weight(.semibold))
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
