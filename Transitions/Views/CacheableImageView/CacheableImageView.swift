import UIKit

class CacheableImageView: UIImageView {
    enum ImageDownloadError: Error {
        case badURL
        case invalidData
    }

    private var imageTask: Task<Void, Error>?
    private var defaultImageCache: ImageCache {
        ImageCache.shared
    }

    func setImage(from url: URL,
                  with placeholder: UIImage? = nil,
                  using imageCache: ImageCache? = nil)
    {
        // Cancel existing image fetching task
        imageTask?.cancel()
        
        // Set placeholder if provided
        setImage(placeholder)
        
        // Check cache first
        let imageCache = imageCache ?? defaultImageCache
        if let cachedImage = imageCache.getImage(forKey: url) {
            setImage(cachedImage)
            return
        }
        
        // If not in cache, download from server
        imageTask = Task {
            try await setRemoteImageAsync(from: url, saveTo: imageCache)
        }
    }

    private func setRemoteImageAsync(from url: URL,
                                     saveTo imageCache: ImageCache? = nil) async throws
    {
        // Download image from remote URL
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let image = UIImage(data: data) else {
            throw ImageDownloadError.invalidData
        }
        
        // Save downloaded image to cache
        imageCache?.setImage(image, forKey: response.url ?? url)
        
        // Check if task is cancelled
        try Task.checkCancellation()
        
        // Set as image of the UIImageView
        setImage(image)
    }

    @MainActor
    public func setImage(_ image: UIImage?) {
        self.image = image
    }
}
