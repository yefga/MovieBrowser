//
//  MovieRepository.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

protocol SearchMovieRepositoryInterface {
    func search(query: String, page: Int) async -> Result<Paged<Movie>?, MovieError>
}
