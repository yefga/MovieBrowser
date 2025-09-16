//
//  DetailsCoordinator.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit

final class DetailsCoordinator: NSObject, Coordinator {
    var onFinish: (() -> Void)?
    private weak var rootViewController: UIViewController?

    let navigationController: UINavigationController
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
        self.rootViewController = viewController
        navigationController.delegate = self
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension DetailsCoordinator: UINavigationControllerDelegate {
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
