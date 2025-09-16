//
//  MovieDetailsViewModel.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

@MainActor
final class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Movie?
    @Published var isFavorite: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: DetailsError?
    private let movieDetailsUseCase: GetMovieDetailsUseCaseInterface
    private let favoriteUseCase: FavoriteMovieUseCaseInterface
    private let movieID: Int
    
    init(
        movieID: Int,
        movieDetailsUseCase: GetMovieDetailsUseCaseInterface,
        favoriteUseCase: FavoriteMovieUseCaseInterface
    ) {
        self.movieID = movieID
        self.movieDetailsUseCase = movieDetailsUseCase
        self.favoriteUseCase = favoriteUseCase
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        let result = await movieDetailsUseCase.execute(id: movieID)
        switch result {
        case .success(let movie):
            self.movie = movie
            if let id = movie?.id {
                self.isFavorite = favoriteUseCase.isFavorite(by: id)
            }
        case .failure(let error):
            self.error = error
        }
    }
    
    func toggleFavorite() {
        guard var current = movie else { return }
        isFavorite.toggle()
        current.isFavorite = isFavorite
        movie = current
        favoriteUseCase.setFavorite(item: current)
    }
}
