//
//  MovieRepositoryImpl.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation
import MovieCore
import MoviePersistence

final class SearchMovieRepository: SearchMovieRepositoryInterface {
    private let executor: RequestExecuting
    private let cache: MovieCacheStore
    private let favorites: FavoritesRepositoryInterface

    init(executor: RequestExecuting, cache: MovieCacheStore, favorites: FavoritesRepositoryInterface) {
        self.executor = executor
        self.cache = cache
        self.favorites = favorites
    }

    func search(query: String, page: Int) async -> Result<Paged<Movie>?, MovieError> {
        do {
            let ep = MovieEndpoint.search(query: query, page: page)
            let dto: SearchResponseDTO = try await executor.call(ep)
            let paged = MovieMapper.fromSearchResponse(dto)
            let mergedItems: [Movie] = (paged.items ?? []).map { movie in
                var dict = movie.asDictionary()
                if let id = movie.id { dict["isFavorite"] = favorites.isFavorite(id: id) }
                return Movie(dict: dict)
            }
            let mergedPaged = Paged(items: mergedItems, page: paged.page, hasMore: paged.hasMore)
            let dicts = mergedItems.map { $0.asDictionary() }
            try? cache.save(movies: dicts, for: query, page: page)

            return .success(mergedPaged)
        } catch let net as NetworkError {
            if let cached = try? cache.fetch(for: query, page: page), !cached.isEmpty {
                let movies = cached.map {
                    Movie(
                        id: $0.id,
                        title: $0.title,
                        releaseDateText: $0.releaseDateText,
                        posterPath: $0.posterPath,
                        originalLanguage: $0.originalLanguage,
                        voteAverage: $0.voteAverage,
                        overview: $0.overview,
                        isFavorite: $0.isFavorite
                    )
                }
                let merged: [Movie] = movies.map { movie in
                    var dict = movie.asDictionary()
                    if let id = movie.id { dict["isFavorite"] = favorites.isFavorite(id: id) }
                    return Movie(dict: dict)
                }
                let paged = Paged(items: merged, page: page, hasMore: false)
                return .success(paged)
            }
            return .failure(map(net))
        } catch {
            return .failure(.unknown)
        }
    }

    private func map(_ error: NetworkError) -> MovieError {
        switch error {
        case .noInternet: return .noInternet
        case .timedOut:   return .timeout
        case .server(_, _, let api): return .server(message: api?.statusMessage ?? "Server error")
        default:          return .unknown
        }
    }
}
