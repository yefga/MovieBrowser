//
//  MovieCache.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

public protocol MovieCacheStore {
    func save(movies: [[String: Any]], for query: String, page: Int) throws
    func clear(for query: String) throws
    func fetch(for query: String, page: Int) throws -> [CachedMovieDTO]
    func fetchFavorites() throws -> [CachedMovieDTO]
    func setFavorite(item: CachedMovieDTO) throws
    func isFavorite(id: Int) throws -> Bool
}
