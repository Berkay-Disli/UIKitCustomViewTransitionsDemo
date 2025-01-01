import UIKit

protocol ImageCaching {
    func getImage(forKey key: URL) -> UIImage?
    func setImage(_ image: UIImage, forKey key: URL)
    func removeImage(forKey key: URL)
    func removeAll()
}

final class ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    private func cacheKey(from url: URL) -> NSString {
        NSString(string: url.absoluteString)
    }
    
    // There is `instance` and `shared` because we want to
    // initialize this lazily
    private static var instance: ImageCache?
    static var shared: ImageCache {
        guard let instance else {
            let instance = ImageCache()
            self.instance = instance
            return instance
        }
        
        return instance
    }
}

extension ImageCache: ImageCaching {
    public func setImage(_ image: UIImage, forKey key: URL) {
        cache.setObject(image, forKey: cacheKey(from: key))
    }

    public func getImage(forKey key: URL) -> UIImage? {
        cache.object(forKey: cacheKey(from: key))
    }

    public func removeImage(forKey key: URL) {
        cache.removeObject(forKey: cacheKey(from: key))
    }

    public func removeAll() {
        cache.removeAllObjects()
    }
}
