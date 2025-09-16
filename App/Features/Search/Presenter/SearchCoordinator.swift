//
//  SearchCoordinator.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit
import MoviePersistence

final class SearchCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let container: AppContainer
    private var childCoordinators: [Coordinator] = []

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
            self.childCoordinators.append(details)
            details.onFinish = { [weak self, weak details] in
                guard let self, let details else { return }
                self.removeChild(details)
            }
            details.start()
        }

        viewController.onShowFavorites = { [weak self] in
            guard let self else { return }
            
            let favorites = FavoritesCoordinator(
                navigationController: navigationController,
                container: container
            )
            self.childCoordinators.append(favorites)
            favorites.onFinish = { [weak self, weak favorites] in
                guard let self, let favorites else { return }
                self.removeChild(favorites)
            }
            favorites.start()
        }
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func removeChild(_ child: Coordinator?) {
        guard let child else { return }
        childCoordinators.removeAll { $0 === child }
    }
    
}
