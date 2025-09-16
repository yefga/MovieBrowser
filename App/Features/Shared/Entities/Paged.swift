//
//  Paged.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

public struct Paged<T>: Sendable where T: Sendable {
    public var items: [T]?
    public var page: Int?
    public var hasMore: Bool?
    public var totalPages: Int?
    public var totalResults: Int?
}
