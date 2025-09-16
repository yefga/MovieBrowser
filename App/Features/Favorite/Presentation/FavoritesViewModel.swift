//
//  FavoritesViewModel.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Combine
import MoviePersistence

final class FavoritesViewModel: ObservableObject {
    private let useCase: FavoriteMovieUseCaseInterface

    @Published private(set) var rows: [Movie] = []

    init(
        useCase: FavoriteMovieUseCaseInterface
    ) {
        self.useCase = useCase
    }

    func load() {
        rows = useCase.getFavorites() ?? []
    }
    
    func toggleFavorite(movie: Movie) {
        var item = movie
        item.isFavorite?.toggle()
        useCase.setFavorite(item: item)
    }
}
