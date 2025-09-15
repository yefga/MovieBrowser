//
//  SearchMoviesUseCase.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

struct SearchMoviesUseCase: SearchMoviesUseCaseInterface {
    private let repository: SearchMovieRepositoryInterface
    
    init(repository: SearchMovieRepositoryInterface) {
        self.repository = repository
    }

    func execute(query: String, page: Int) async -> Result<Paged<Movie>?, MovieError> {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .success(Paged(items: [], page: 1, hasMore: false)) }
        let safePage = max(page, 1)
        return await repository.search(query: trimmed, page: safePage)
    }
}
