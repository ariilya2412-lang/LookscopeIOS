import Foundation
import PhotosUI
import UIKit

enum PhotoImportError: LocalizedError {
    case loadFailed
    case invalidImage
    case compressionFailed

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "The selected photo could not be loaded."
        case .invalidImage:
            return "The selected asset is not a valid image."
        case .compressionFailed:
            return "The photo could not be prepared."
        }
    }
}

struct PhotoImportService {
    func importPhoto(item: PhotosPickerItem) async throws -> UploadedPhotoAsset {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw PhotoImportError.loadFailed
        }

        guard let image = UIImage(data: data) else {
            throw PhotoImportError.invalidImage
        }

        let prepared = try prepare(image: image)
        return UploadedPhotoAsset(
            imageData: prepared,
            fileName: item.itemIdentifier ?? "portrait"
        )
    }

    private func prepare(image: UIImage) throws -> Data {
        let maxDimension: CGFloat = 1600
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let rendered = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        guard let data = rendered.jpegData(compressionQuality: 0.88) else {
            throw PhotoImportError.compressionFailed
        }

        return data
    }
}
