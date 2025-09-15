//
//  GetMovieDetailsUseCase.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

struct GetMovieDetailsUseCase: GetMovieDetailsUseCaseInterface {
    private let repository: MovieDetailsRepositoryInterface
    init(repository: MovieDetailsRepositoryInterface) { self.repository = repository }

    func execute(id: Int) async -> Result<Movie?, DetailsError> {
        await repository.details(id: id)
    }
}
