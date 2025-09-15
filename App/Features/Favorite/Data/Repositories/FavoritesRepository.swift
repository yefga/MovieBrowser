//
//  FavoritesRepository.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import MoviePersistence

public final class FavoritesRepository: FavoritesRepositoryInterface {
    
    private var store: MovieCacheStore
    public init(store: MovieCacheStore = CoreDataMovieCache()) {
        self.store = store
    }

    public func isFavorite(id: Int) -> Bool? {
        return try? store.isFavorite(id: id)
    }

    public func setFavorite(item: Movie) {
        let item = CachedMovieDTO(
            id: item.id ?? .zero,
            title: item.title,
            posterPath: item.posterPath,
            releaseDateText: item.releaseDateText,
            overview: item.overview,
            voteAverage: item.voteAverage,
            originalLanguage: item.originalLanguage,
            isFavorite: item.isFavorite ?? false
        )
        try? store.setFavorite(
            item: item
        )
    }

    public func fetchFavorites() -> [Movie]? {
        let favorites = try? store.fetchFavorites()
        return favorites?.compactMap {
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
    }
}
