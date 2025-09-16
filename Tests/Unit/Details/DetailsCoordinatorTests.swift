//
//  DetailsCoordinatorTests.swift
//  MovieBrowser
//
//  Created by Yefga on 16/09/25.
//


import XCTest
@testable import MovieBrowser


final class DetailsCoordinatorTests: XCTestCase {
    @MainActor func test_finish_triggersOnFinish() {
        let coordinator = DetailsCoordinator(
            navigationController: UINavigationController(),
            movieID: 1,
            container: .make()
        )
        var finished = false
        coordinator.onFinish = { finished = true }

        coordinator.onFinish?()

        XCTAssertTrue(finished)
    }
}
