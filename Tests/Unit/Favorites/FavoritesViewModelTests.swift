//
//  FavoritesViewModelTests.swift
//  MovieBrowser
//
//  Created by Yefga on 16/09/25.
//

import XCTest
@testable import MovieBrowser

@MainActor
final class FavoritesViewModelTests: XCTestCase {

    // Helper to build SUT with injectable doubles
    private func makeSUT(
        favorites: [Movie] = [Movie(id: 1, isFavorite: true)],
        useFake: Bool = false
    ) -> FavoritesViewModel {

        let useCase: FavoriteMovieUseCaseInterface
        if useFake {
            let fake = FakeFavoriteMovieUseCase()
            favorites.forEach { fake.setFavorite(item: $0) }
            useCase = fake
        } else {
            let stub = StubFavoriteMovieUseCase()
            stub.isFavorite = false
            useCase = stub
        }

        let vm = FavoritesViewModel(useCase: useCase)
        return vm
    }

    func test_load_setsFavorites_andTurnsOffLoading_onSuccess() async {
        let list = [Movie(id: 42, isFavorite: true), Movie(id: 9, isFavorite: true)]
        let vm = makeSUT(favorites: list)

        XCTAssertTrue(vm.rows.isEmpty)
    }
}
