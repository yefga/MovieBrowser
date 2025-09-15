//
//  AppCoordinator.swift
//  MovieBrowser
//
//  Created by Yefga on 15/09/25.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get }
    func start()
}

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let container: AppContainer
    private var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController, container: AppContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let searchCoordinator = SearchCoordinator(
            navigationController: navigationController,
            container: container
        )
        childCoordinators.append(searchCoordinator)
        searchCoordinator.start()
    }
}
