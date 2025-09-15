//
//  ImageResponse.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

public struct ImageResponse: Sendable {
    public let data: Data
    public let mimeType: String?
    public let etag: String?
    public let fromCache: Bool

    public init(data: Data, mimeType: String?, etag: String?, fromCache: Bool) {
        self.data = data
        self.mimeType = mimeType
        self.etag = etag
        self.fromCache = fromCache
    }
}
