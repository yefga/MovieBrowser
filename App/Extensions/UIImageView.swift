//
//  UIImageView.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit
import MovieCore

private var loaderTaskKey: UInt8 = 0
private extension UIImageView {
    var _task: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &loaderTaskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &loaderTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

public extension UIImageView {
    func setImage(
        url: URL?,
        loader: ImageLoading,
        options: ImageOptions = .init(),
        placeholder: UIImage? = nil,
        transitionDuration: TimeInterval = 0.2
    ) {
        _task?.cancel()
        // Apply placeholder with desired styling if no image yet
        if let placeholder {
            self.image = placeholder
        } else {
            self.image = nil
        }
        self.contentMode = .center
        self.tintColor = .red
        self.backgroundColor = .systemGray5

        guard let url else { return }

        _task = Task { [weak self] in
            guard let self else { return }
            do {
                let res = try await loader.load(url, options: options)
                guard let image = UIImage(data: res.data) else {
                    return
                }

                await MainActor.run {
                    UIView.transition(with: self, duration: transitionDuration, options: .transitionCrossDissolve) {
                        self.backgroundColor = .clear
                        self.contentMode = .scaleAspectFill
                        self.image = image
                    }
                }
            } catch {
                // optionally set a failure image
            }
        }
    }

    func cancelImageLoad(loader: ImageLoading, url: URL?) {
        _task?.cancel()
        if let url { loader.cancel(for: url) }
    }
}

enum ImageLoaderRegistry {
    static var loader: ImageLoading = DefaultImageLoader()
}
