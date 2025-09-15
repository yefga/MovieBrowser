//
//  SearchCoordinator.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit
import SwiftUI
import MoviePersistence

final class SearchCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let container: AppContainer

    init(navigationController: UINavigationController, container: AppContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let viewModel = SearchViewModel(
            useCase: SearchMoviesUseCase(repository: container.searchMoviesRepository),
            favoritesUseCase: FavoritesRepository()
        )
        let viewController = SearchViewController(viewModel: viewModel)

        viewController.onSelectMovie = { [weak self] movieID in
            guard let self else { return }

            let details = DetailsCoordinator(
                navigationController: navigationController,
                movieID: movieID,
                container: container
            )
            details.start()
        }

        viewController.onShowFavorites = { [weak self] in
            guard let self else { return }
            
            let favorites = FavoritesCoordinator(
                navigationController: navigationController,
                container: container
            )
            favorites.start()
        }
        navigationController.setViewControllers([viewController], animated: false)
    }
    
}
