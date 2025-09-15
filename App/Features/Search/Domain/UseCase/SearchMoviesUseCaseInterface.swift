//
//  SearchMoviesUseCase.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

protocol SearchMoviesUseCaseInterface {
    func execute(query: String, page: Int) async -> Result<Paged<Movie>?, MovieError>
}
