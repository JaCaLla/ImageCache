//
//  AsyncImageView.swift
//  ImageCache
//
//  Created by JAVIER CALATRAVA LLAVERIA on 21/4/25.
//

import SwiftUI

struct AsyncImageView: View {
    @StateObject private var loader: AsyncImageLoader
    let placeholder: Image
    let imageStyle: (Image) -> Image

    init(
        url: URL,
        placeholder: Image = Image(systemName: "photo"),
        imageStyle: @escaping (Image) -> Image = { $0 }
    ) {
        _loader = StateObject(wrappedValue: AsyncImageLoader(url: url))
        self.placeholder = placeholder
        self.imageStyle = imageStyle
    }

    var body: some View {
        Group {
            if let uiImage = loader.image {
                imageStyle(Image(uiImage: uiImage).resizable())
            } else {
                imageStyle(placeholder.resizable())
                    .onAppear {
                        Task {
                            await loader.load()
                        }
                    }
            }
        }
    }
}

