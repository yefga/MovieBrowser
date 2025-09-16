//
//  GetMovieDetailsUseCaseTests.swift
//  MovieBrowser
//
//  Created by Yefga on 16/09/25.
//


import XCTest
@testable import MovieBrowser

final class GetMovieDetailsUseCaseTests: XCTestCase {

    func test_execute_forwardsID_and_returnsRepositoryResult_success() async {
        // Given
        let repo = SpyMovieDetailsRepository()
        let expected = Movie(id: 42, isFavorite: false)
        repo.resultToReturn = .success(expected)

        let sut = GetMovieDetailsUseCase(repository: repo)

        // When
        let result = await sut.execute(id: 42)

        // Then
        XCTAssertEqual(repo.receivedIDs, [42], "Use case should forward the id to repository exactly once")

        switch result {
        case .success(let movie):
            XCTAssertEqual(movie?.id, expected.id)
        default:
            XCTFail("Expected success")
        }
    }

    func test_execute_returnsError_whenRepositoryFails() async {
        let repo = SpyMovieDetailsRepository()
        repo.resultToReturn = .failure(.timeout)
        let sut = GetMovieDetailsUseCase(repository: repo)

        let result = await sut.execute(id: 1)

        switch result {
        case .failure(let error):
            XCTAssertEqual(error, .timeout)
        default:
            XCTFail("Expected failure")
        }
    }
}
