//
//  DetailsCoordinator.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

// Application/Coordinators/DetailsCoordinator.swift

import UIKit
import SwiftUI

final class DetailsCoordinator {
    private let navigationController: UINavigationController
    private let movieID: Int
    private let container: AppContainer

    init(navigationController: UINavigationController, movieID: Int, container: AppContainer) {
        self.navigationController = navigationController
        self.movieID = movieID
        self.container = container
    }

    func start() {
        let viewModel = MovieDetailsViewModel(
            movieID: movieID,
            movieDetailsUseCase: GetMovieDetailsUseCase(
                repository: container.movieDetailsRepository
            ),
            favoriteUseCase: FavoriteMovieUseCase(repository: container.favoritesRepository)
        )
        let viewController = MovieDetailsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
