//
//  ContentView.swift
//  ImageCache
//
//  Created by JAVIER CALATRAVA LLAVERIA on 21/4/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        AsyncImageView(url: URL(string: "https://picsum.photos/510")!)
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 5)
    }
}

#Preview {
    ContentView()
}
