//
//  CachedAsyncImage.swift
//  LightspeedCodingChallenge
//
//  Created by edgar kosyan on 03.11.24.
//

import SwiftUI

struct CacheAsyncImage<Content, Placeholder>: View where Content: View, Placeholder: View {
    
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (Image) -> Content
    private let placeholder: AnyView
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Image) -> Content,
        placeholder: () -> Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.placeholder = AnyView(placeholder())
    }
    
    var body: some View {
        // Check if the image is cached
        if let cachedImage = ImageCache[url] {
            content(cachedImage)
        } else {
            // Fetch and cache the image if not cached
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    content(image)
                        .onAppear {
                            ImageCache[url] = image
                        }
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        }
    }
}

fileprivate class ImageCache {
    static private var cache: [URL: Image] = [:]
    
    static subscript(url: URL?) -> Image? {
        get {
            guard let url = url else { return nil }
            return ImageCache.cache[url]
        }
        set {
            guard let url = url else { return }
            ImageCache.cache[url] = newValue
        }
    }
}
