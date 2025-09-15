//
//  FavoritesCoordinator.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit

final class FavoritesCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let container: AppContainer
    private var childCoordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController,
        container: AppContainer
    ) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let viewModel = FavoritesViewModel(
            useCase: FavoriteMovieUseCase(repository: container.favoritesRepository)
        )
        let viewController = FavoritesViewController(viewModel: viewModel)
        viewController.onSelect = { [weak self] id in
            guard let self else { return }
            let details = DetailsCoordinator(
                navigationController: navigationController,
                movieID: id,
                container: container
            )
            self.childCoordinators.append(details)
            details.start()
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func removeChild(_ child: Coordinator?) {
        guard let child else { return }
        childCoordinators.removeAll { $0 === child }
    }
}
