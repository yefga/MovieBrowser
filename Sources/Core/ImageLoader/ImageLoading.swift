//
//  ImageLoading.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

public protocol ImageLoading: AnyObject {
    @discardableResult
    func load(_ url: URL, options: ImageOptions) async throws -> ImageResponse

    func prefetch(_ urls: [URL], options: ImageOptions)
    func cancel(for url: URL)

    func clearMemory()
    func clearDisk() throws
}
