//
//  RemoteImage.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import SwiftUI
import MovieCore

public struct RemoteImage: View {
    let url: URL?
    let loader: ImageLoading
    let options: ImageOptions
    let placeholder: AnyView

    @State private var uiImage: UIImage?

    public init(
        url: URL?,
        loader: ImageLoading,
        options: ImageOptions = .init(),
        @ViewBuilder placeholder: () -> some View = { Color.gray.opacity(0.15) }
    ) {
        self.url = url
        self.loader = loader
        self.options = options
        self.placeholder = AnyView(placeholder())
    }

    public var body: some View {
        ZStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity.animation(.easeIn(duration: 0.2)))
            } else {
                placeholder
            }
        }
        .task(id: url) {
            guard let url else { return }
            if let res = try? await loader.load(url, options: options),
               let img = UIImage(data: res.data) {
                withAnimation { uiImage = img }
            }
        }
    }
}
