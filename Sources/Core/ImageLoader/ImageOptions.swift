//
//  ImageOptions.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

public struct ImageOptions: Sendable, Hashable {
    public enum CachePolicy: Sendable {
        case `default`
        case reloadIgnoringCache
    }

    public var cachePolicy: CachePolicy
    public var priority: Float
    public var headers: [String: String]?

    public init(cachePolicy: CachePolicy = .default,
                priority: Float = URLSessionTask.defaultPriority,
                headers: [String: String]? = nil) {
        self.cachePolicy = cachePolicy
        self.priority = priority
        self.headers = headers
    }
}
