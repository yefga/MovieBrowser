//
//  FavoritesCoordinator.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit

final class FavoritesCoordinator: NSObject, Coordinator {
    var onFinish: (() -> Void)?
    private weak var rootViewController: UIViewController?

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
        self.rootViewController = viewController
        navigationController.delegate = self
        viewController.onSelect = { [weak self] id in
            guard let self else { return }
            let details = DetailsCoordinator(
                navigationController: navigationController,
                movieID: id,
                container: container
            )
            self.childCoordinators.append(details)
            details.onFinish = { [weak self, weak details] in
                guard let self, let details else { return }
                self.removeChild(details)
            }
            details.start()
        }
        
        viewController.onAdd = { [weak self] in
            guard let self else { return }
            navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func removeChild(_ child: Coordinator?) {
        guard let child else { return }
        childCoordinators.removeAll { $0 === child }
    }
}

extension FavoritesCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let root = rootViewController else { return }
        if navigationController.viewControllers.contains(root) == false {
            onFinish?()
            if navigationController.delegate === self {
                navigationController.delegate = nil
            }
        }
    }
}
