import Foundation
import PhotosUI
import UIKit

enum PhotoImportError: LocalizedError {
    case loadFailed
    case imageDecodeFailed
    case encodeFailed

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "The selected photo could not be loaded."
        case .imageDecodeFailed:
            return "The selected data is not a valid image."
        case .encodeFailed:
            return "The image could not be prepared for analysis."
        }
    }
}

struct PhotoImportService {
    func importPhotos(items: [PhotosPickerItem], faceService: FaceLandmarkService) async throws -> [AnalysisPhoto] {
        var imported: [AnalysisPhoto] = []

        for (index, item) in items.enumerated() {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw PhotoImportError.loadFailed
            }

            let photo = try makePhoto(
                from: data,
                label: "Photo \(index + 1)",
                faceService: faceService
            )
            imported.append(photo)
        }

        return imported
    }

    func makePhoto(
        from data: Data,
        label: String,
        faceService: FaceLandmarkService
    ) throws -> AnalysisPhoto {
        guard let image = UIImage(data: data) else {
            throw PhotoImportError.imageDecodeFailed
        }

        return try makePhoto(from: image, label: label, faceService: faceService)
    }

    func makePhoto(
        from image: UIImage,
        label: String,
        faceService: FaceLandmarkService
    ) throws -> AnalysisPhoto {
        let prepared = try prepare(image: image)
        let summary = try? faceService.analyze(imageData: prepared)
        return AnalysisPhoto(
            jpegData: prepared,
            sourceLabel: label,
            faceSummary: summary
        )
    }

    private func prepare(image: UIImage) throws -> Data {
        let maxDimension: CGFloat = 1800
        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height))
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let rendered = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        guard let data = rendered.jpegData(compressionQuality: 0.86) else {
            throw PhotoImportError.encodeFailed
        }

        return data
    }
}
