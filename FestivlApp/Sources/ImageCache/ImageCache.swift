//
//  File.swift
//  
//
//  Created by Woodrow Melling on 4/9/22.
//

import Foundation
import Combine

public final class ImageCache {
    public static let shared = ImageCache()

    // 2nd level cache, that contains decoded images
    private lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = config.memoryLimit
        return cache
    }()

    private lazy var fileStorageCache = Cache<FileStorage>()

    private let lock = NSLock()
    private let config: Config

    struct Config {
        let countLimit: Int
        let memoryLimit: Int

        static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
    }

    init(config: Config = Config.defaultConfig) {
        self.config = config
    }
}

extension ImageCache: ImageCacheDestination {
    func insertImage(_ image: UIImage?, for url: URL, size: CGSize) {
        guard let image = image else { return removeImage(for: url, size: size) }
        let decodedImage = image.decodedImage()

        lock.lock(); defer { lock.unlock() }
        decodedImageCache.setObject(decodedImage as AnyObject, forKey: url.absoluteString as AnyObject, cost: decodedImage.diskSize)
        fileStorageCache.insert(data: decodedImage.pngData()?.base64EncodedData(), key: url.absoluteString)
    }

    func removeImage(for url: URL, size: CGSize) {
        lock.lock(); defer { lock.unlock() }

        decodedImageCache.setObject(image as AnyObject, forKey: url as AnyObject)
        fileStorageCache.insert(data: Data?.none, key: url.absoluteString)
    }

    func image(for url: URL, size: CGSize) -> UIImage? {

        // the best case scenario -> there is a decoded image
        if let decodedImage = decodedImageCache.object(forKey: url as AnyObject) as? UIImage {
            print("Cache Hit decoded")
            return decodedImage
        }

        lock.lock(); defer { lock.unlock() }

        // worst case, retrieve from disk
        if let imageData = fileStorageCache.fetch(key: url.absoluteString, type: Data.self) {
            print("Cache hit fileStorage")
            return UIImage(data: imageData)
        }

        print("Cache Miss")
        return nil
    }

    func removeAllImages() {
        decodedImageCache.removeAllObjects()
        try? FileStorage.clearCache()
    }

    subscript(_ key: URL, size: CGSize) -> UIImage? {
        get {
            return image(for: key, size: size)
        }
        set {
            return insertImage(newValue, for: key, size: size)
        }
    }

    public func loadAndStoreImage(url: URL, size: CGSize) async {
        guard ImageCache.shared[url, size] == nil else {

            return

        }
        do {
            let data = try await URLSession.shared.data(from: url).0
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                ImageCache.shared[url, size] = image
            }

        } catch {
            print("Error:", error)
        }
    }
}

private extension UIImage {
    // Disk size in bytes
    var diskSize: Int {
        let imgData = NSData(data: jpegData(compressionQuality: 1)!)
        return imgData.count
    }
}

public extension UIImageView {
    @discardableResult
    func setImage(with url: URL?, placeholder: UIImage? = nil, size: CGSize) -> URLSessionDataTask? {
        if let placeholder = placeholder {
            self.image = placeholder
        }

        guard let url = url else { return nil }

        if let image = ImageCache.shared[url, self.frame.size] {
            self.image = image
            return nil
        } else {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    ImageCache.shared[url, self.frame.size] = image
                    self.image = image
                }
            }
            task.resume()
            return task
        }
    }
}

import SwiftUI

public class Loader: ObservableObject {
    enum LoadState {
        case loading, success, failure
    }
    var url: URL?
    var data = Data()
    var state = LoadState.loading

    init(url: URL?) {
        self.url = url
        if let url = url {
            self.fetchData(url: url)
        }
    }

    internal func fetchData(url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil
            else {
                self.state = .failure
                return
            }
            self.data = data
            self.state = .success
            DispatchQueue.main.async {
                self.dataFetched()
                self.objectWillChange.send()
            }
        }.resume()
    }

    internal func dataFetched() {

    }
}

public class CachedImageLoader: Loader {
    @Published var image: SwiftUI.Image
    var placeholder: SwiftUI.Image
    var size: CGSize

    init(url: URL?, placeholder: SwiftUI.Image, size: CGSize) {
        self.image = placeholder
        self.placeholder = placeholder
        self.size = size
        super.init(url: url)
    }

    override func fetchData(url: URL?) {
        self.image = placeholder


        if let url = url {
            let size = self.size
            DispatchQueue.global(qos: .utility).async {
                if let cachedImage = ImageCache.shared[url, size] {
                    DispatchQueue.main.async {
                        self.image = SwiftUI.Image(uiImage: cachedImage)
                    }

                } else {
                    super.fetchData(url: url)
                }
            }

        }

    }

    override func dataFetched() {
        if let url = self.url, let image = UIImage(data: self.data) {
            ImageCache.shared[url, size] = image
            self.image = SwiftUI.Image(uiImage: image)
        }
    }
}

public struct CachedAsyncImage: View {
    @StateObject private var loader: CachedImageLoader
    var url: URL?
    var size: CGSize

    public init(
        url: URL?,
        placeholder: SwiftUI.Image = SwiftUI.Image(systemName: "multiply.circle"),
        size: CGSize
        // TODO: research using @ViewBuilder to pass in placeholder image with modifiers
        //  until then, Image modifiers like .resizable() need to be hardcoded in body
    ) {
        self.url = url
        _loader = StateObject(wrappedValue: CachedImageLoader(url: url, placeholder: placeholder, size: size))
        self.size = size
    }

    public var body: some View {
        loadImage()
            .resizable()
            .onChange(of: url) { value in
                loader.fetchData(url: url)
            }
            .frame(width: size.width, height: size.height)
    }

    private func loadImage() -> SwiftUI.Image {
        return loader.image
    }
}
