//
//  FavoriteUseCaseInterface.swift
//  MovieBrowser
//
//  Created by Yefga on 16/09/25.
//


import Foundation
@testable import MovieBrowser

// MARK: - Minimal “Favorite” protocol (matches what your VM calls)
protocol FavoriteUseCaseInterface {
    func isFavorite(by id: Int) -> Bool
    func setFavorite(item: Movie)
}

// MARK: - Repository Spy (also works as a Stub)
final class SpyMovieDetailsRepository: MovieDetailsRepositoryInterface {
    private(set) var receivedIDs: [Int] = []
    var resultToReturn: Result<Movie?, DetailsError> = .success(nil)

    func details(id: Int) async -> Result<Movie?, DetailsError> {
        receivedIDs.append(id)
        return resultToReturn
    }
}

// MARK: - UseCase Stub (wraps a result; no behavior verification)
final class StubGetMovieDetailsUseCase: GetMovieDetailsUseCaseInterface {
    var result: Result<Movie?, DetailsError> = .success(nil)
    func execute(id: Int) async -> Result<Movie?, DetailsError> { result }
}

// MARK: - Favorite Fakes/Spies
/// Fake that stores favorites in-memory
final class FakeFavoriteUseCase: FavoriteUseCaseInterface {
    private var set: Set<Int> = []
    private(set) var setFavoriteCalls: Int = 0

    func isFavorite(by id: Int) -> Bool { set.contains(id) }

    func setFavorite(item: Movie) {
        setFavoriteCalls += 1
        if let id = item.id {
            if item.isFavorite ?? false {
                set.insert(id)
            } else {
                set.remove(id)
            }
        }
    }
}

/// Spy that only records calls (useful when you don't need storage)
final class SpyFavoriteUseCase: FavoriteMovieUseCaseInterface {
    
    
    private(set) var isFavoriteQueriedIDs: [Int] = []
    private(set) var setFavoriteItems: [Movie] = []
    var isFavoriteReturn: Bool = false

    
    func getFavorites() -> [Movie]? {
        []
    }
    
    func isFavorite(by id: Int) -> Bool {
        isFavoriteQueriedIDs.append(id)
        return isFavoriteReturn
    }

    func setFavorite(item: Movie) {
        setFavoriteItems.append(item)
    }
}

// MARK: - Mock Coordinator (verifies expectations)
final class MockDetailsCoordinator {
    private(set) var finishCalled = false

    func finish() {
        finishCalled = true
    }

    // Example hard expectation (use assert in test to “verify”)
    func verifyFinishCalled(file: StaticString = #file, line: UInt = #line) {
        assert(finishCalled, "Expected finish() to be called", file: file, line: line)
    }
}
