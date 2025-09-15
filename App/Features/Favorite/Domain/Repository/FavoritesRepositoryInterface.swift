//
//  FavoritesRepositoryInterface.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//


public protocol FavoritesRepositoryInterface {
    func isFavorite(id: Int) -> Bool?
    func setFavorite(item: Movie)
    func fetchFavorites() -> [Movie]?
}
