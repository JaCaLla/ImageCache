//
//  AsyncImageLoader.swift
//  ImageCache
//
//  Created by JAVIER CALATRAVA LLAVERIA on 21/4/25.
//

import SwiftUI

@MainActor
class AsyncImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var url: URL

    init(url: URL) {
        self.url = url
    }

    func load() async {
        if let cached = await DiskImageCache.shared.image(for: url) {
            self.image = cached
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let downloaded = UIImage(data: data) else { return }

            self.image = downloaded
            await DiskImageCache.shared.store(downloaded, for: url)
        } catch {
            print("Image load failed:", error)
        }
    }
}

