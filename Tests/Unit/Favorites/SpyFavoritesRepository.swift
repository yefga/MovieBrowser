//
//  SpyFavoritesRepository.swift
//  MovieBrowser
//
//  Created by Yefga on 16/09/25.
//


import Foundation
@testable import MovieBrowser

// MARK: - Spy Repository (also acts as a stub via injectable storage)
final class SpyFavoritesRepository: FavoritesRepositoryInterface {
    
    var isFavorite: Bool = true
    
    func isFavorite(id: Int) -> Bool? {
        isFavorite
    }
    
    func setFavorite(item: Movie) {
        isFavorite = item.isFavorite ?? false
    }
    
    func fetchFavorites() -> [Movie]? {
        [
            
        ]
    }
}

// MARK: - Stub UseCase (returns canned values & routes through repo if desired)

final class StubFavoriteMovieUseCase: FavoriteMovieUseCaseInterface {
    var isFavorite: Bool = true

    func isFavorite(by id: Int) -> Bool {
        isFavorite
    }
    
    func setFavorite(item: MovieBrowser.Movie) {
        isFavorite = item.isFavorite ?? false
    }
    
    func getFavorites() -> [MovieBrowser.Movie]? {
        []
    }
}

// MARK: - Simple Fake UseCase (working in-memory behavior)
final class FakeFavoriteMovieUseCase: FavoriteMovieUseCaseInterface {
    var isFavorite: Bool = true
    func isFavorite(by id: Int) -> Bool {
        false
    }
    
    func setFavorite(item: MovieBrowser.Movie) {
        isFavorite = item.isFavorite ?? true
    }
    
    func getFavorites() -> [MovieBrowser.Movie]? {
        [
            
        ]
    }
}

// MARK: - Mock Coordinator (verifies navigation/finish)
final class MockFavoritesCoordinator {
    private(set) var didOpenDetailsForID: Int?
    private(set) var didFinish = false

    func openDetails(id: Int) { didOpenDetailsForID = id }
    func finish() { didFinish = true }

    // Optional hard verification helper
    func verifyOpened(
        id expected: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assert(
            didOpenDetailsForID == expected,
            "Expected openDetails(\(expected))",
            file: file,
            line: line
        )
    }
}
