//
//  FavoriteMovieUseCaseTests.swift
//  MovieBrowser
//
//  Created by Yefga on 16/09/25.
//

import XCTest
@testable import MovieBrowser

final class FavoriteMovieUseCaseTests: XCTestCase {

    private func makeConcreteUseCase(repo: FavoritesRepositoryInterface) -> FavoriteMovieUseCaseInterface {
        return FavoriteMovieUseCase(repository: repo)
    }

    func test_isFavorite_forwardsToRepository() {
        let repo = SpyFavoritesRepository()
        repo.isFavorite = false
        let sut = makeConcreteUseCase(repo: repo)

        XCTAssertTrue(sut.isFavorite(by: 1))
    }

    func test_toggle_addsWhenNotFavorite_andRemovesWhenFavorite() {
        let repo = SpyFavoritesRepository()
        repo.isFavorite = false
        let sut = makeConcreteUseCase(repo: repo)

        let item = Movie(id: 7, isFavorite: false)

        sut.setFavorite(item: item)
        XCTAssertEqual(repo.isFavorite, false)
    }
}
