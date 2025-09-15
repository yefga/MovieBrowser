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
    var onSelect: ((Int) -> Void)?

    init(navigationController: UINavigationController, container: AppContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let viewModel = FavoritesViewModel(
            useCase: FavoriteMovieUseCase(repository: container.favoritesRepository)
        )
        let viewController = FavoritesViewController(viewModel: viewModel)
        self.onSelect = { [weak self] id in
            guard let self else { return }
            let details = DetailsCoordinator(navigationController: self.navigationController,
                                             movieID: id,
                                             container: self.container)
            details.start()
        }
        navigationController.pushViewController(viewController, animated: true)
    }
}
