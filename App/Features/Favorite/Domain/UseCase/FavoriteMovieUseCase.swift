//
//  GetMovieDetailsUseCase.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation
import MoviePersistence

struct FavoriteMovieUseCase: FavoriteMovieUseCaseInterface {
    
    private let repository: FavoritesRepositoryInterface
    init(repository: FavoritesRepositoryInterface) { self.repository = repository }
    
    func isFavorite(by id: Int) -> Bool {
        repository.isFavorite(id: id) ?? false
    }
    
    func setFavorite(item: Movie) {
        repository.setFavorite(item: item)
    }
    
    func getFavorites() -> [Movie]? {
        repository.fetchFavorites()?.compactMap {
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
