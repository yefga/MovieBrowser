//
//  FavoriteMovieUseCaseInterface.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import Foundation

protocol FavoriteMovieUseCaseInterface {
    func isFavorite(by id: Int) -> Bool
    func setFavorite(item: Movie)
    func getFavorites() -> [Movie]?
}
