//
//  DefaultImageLoader.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

public actor DefaultImageLoader: @preconcurrency ImageLoading {
    private let cache: DefaultImageCache
    private let session: URLSession

    // Track in-flight tasks to support dedup + cancel
    private var tasks: [URL: Task<ImageResponse, Error>] = [:]

    // Public initializer that does not expose internal cache type
    public init(configuration: URLSessionConfiguration = .default) {
        var config = configuration
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData // we do our own cache
        config.urlCache = nil
        self.session = URLSession(configuration: config)
        self.cache = DefaultImageCache()
    }

    // Internal initializer for injecting a custom cache (e.g., in tests)
    init(configuration: URLSessionConfiguration = .default, cache: DefaultImageCache) {
        var config = configuration
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData // we do our own cache
        config.urlCache = nil
        self.session = URLSession(configuration: config)
        self.cache = cache
    }

    // MARK: ImageLoading

    @discardableResult
    public func load(_ url: URL, options: ImageOptions = .init()) async throws -> ImageResponse {
        if Task.isCancelled { throw ImageError.cancelled }

        // 1) Memory cache
        if options.cachePolicy == .default, let mem = cache.memoryData(for: url) {
            return ImageResponse(data: mem, mimeType: nil, etag: nil, fromCache: true)
        }

        // 2) Disk cache
        if options.cachePolicy == .default, let disk = cache.diskData(for: url) {
            cache.setMemory(disk, for: url)
            return ImageResponse(data: disk, mimeType: nil, etag: nil, fromCache: true)
        }

        // 3) Coalesce same URL requests
        if let existing = tasks[url] {
            return try await existing.value
        }

        // 4) Create a new network task
        let t = Task<ImageResponse, Error> {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 30
            request.allHTTPHeaderFields = options.headers
            let (data, response) = try await session.data(for: request, delegate: nil)

            if Task.isCancelled { throw ImageError.cancelled }

            guard !data.isEmpty else { throw ImageError.decode }

            // Cache
            cache.setMemory(data, for: url)
            cache.setDisk(data, for: url)

            let http = response as? HTTPURLResponse
            let mime = http?.value(forHTTPHeaderField: "Content-Type")
            let etag = http?.value(forHTTPHeaderField: "Etag")

            return ImageResponse(data: data, mimeType: mime, etag: etag, fromCache: false)
        }

        tasks[url] = t
        defer { tasks[url] = nil }

        do {
            return try await t.value
        } catch is CancellationError {
            throw ImageError.cancelled
        } catch {
            throw ImageError.network(error)
        }
    }

    public func prefetch(_ urls: [URL], options: ImageOptions = .init()) {
        Task.detached { [weak self] in
            guard let self else { return }
            for url in urls {
                _ = try? await self.load(url, options: options)
            }
        }
    }

    public func cancel(for url: URL) {
        tasks[url]?.cancel()
        tasks[url] = nil
    }

    public func clearMemory() {
        cache.clearMemory()
    }

    public func clearDisk() throws {
        try cache.clearDisk()
    }
}
