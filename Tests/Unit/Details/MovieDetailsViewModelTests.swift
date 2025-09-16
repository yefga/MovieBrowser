//
//  MovieDetailsViewModelTests.swift
//  MovieBrowser
//
//  Created by Yefga on 16/09/25.
//


import XCTest
@testable import MovieBrowser

@MainActor
final class MovieDetailsViewModelTests: XCTestCase {

    // MARK: - Helpers
    private func makeSUT(
        movieID: Int = 99,
        useCaseResult: Result<Movie?, DetailsError> = .success(Movie(id: 99, isFavorite: false)),
        isFavoriteReturn: Bool = false
    ) -> (MovieDetailsViewModel, StubGetMovieDetailsUseCase, SpyFavoriteUseCase) {
        let stub = StubGetMovieDetailsUseCase()
        stub.result = useCaseResult
        let favoriteUseCase = SpyFavoriteUseCase()
        favoriteUseCase.isFavoriteReturn = isFavoriteReturn
        let vm = MovieDetailsViewModel(
            movieID: movieID,
            movieDetailsUseCase: stub,
            favoriteUseCase: favoriteUseCase
        )
        return (vm, stub, favoriteUseCase)
    }

    func test_load_setsLoading_thenSetsMovie_andFavorite_onSuccess() async {
        // Given
        let movie = Movie(id: 7, isFavorite: false)
        let (vm, _, fav) = makeSUT(movieID: 7, useCaseResult: .success(movie), isFavoriteReturn: true)

        // When
        XCTAssertFalse(vm.isLoading)
        await vm.load()

        // Then
        XCTAssertNil(vm.error)
        XCTAssertNotNil(vm.movie)
        XCTAssertEqual(vm.movie?.id, 7)
        XCTAssertTrue(vm.isFavorite, "VM should query favoriteUseCase and set isFavorite")
        XCTAssertEqual(fav.isFavoriteQueriedIDs, [7])
        XCTAssertFalse(vm.isLoading, "Loading should be turned off at the end")
    }

    func test_load_setsError_onFailure_andTurnsOffLoading() async {
        let (vm, _, fav) = makeSUT(useCaseResult: .failure(.noInternet))

        await vm.load()

        XCTAssertNil(vm.movie)
        XCTAssertEqual(vm.error, .noInternet)
        XCTAssertEqual(fav.isFavoriteQueriedIDs, [], "Should not query favorite when details fail")
        XCTAssertFalse(vm.isLoading)
    }

    func test_toggleFavorite_updatesState_andCallsSetFavorite() async {
        // Seed with a loaded movie
        let movie = Movie(id: 10, isFavorite: false)
        let (vm, _, fav) = makeSUT(movieID: 10, useCaseResult: .success(movie), isFavoriteReturn: false)
        await vm.load()

        // When
        vm.toggleFavorite()

        // Then
        XCTAssertTrue(vm.isFavorite)
        XCTAssertEqual(vm.movie?.isFavorite, true)
        XCTAssertEqual(fav.setFavoriteItems.count, 1)
        XCTAssertEqual(fav.setFavoriteItems.first?.id, 10)
    }

    func test_loadingTransitions_areBalanced_evenWhenFailing() async {
        let (vm, _, _) = makeSUT(useCaseResult: .failure(.timeout))

        await vm.load()

        XCTAssertFalse(vm.isLoading, "defer should switch isLoading back to false even on error")
    }
}
