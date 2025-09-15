//
//  SceneDelegate.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController = UINavigationController()
        navigationController.navigationBar.isTranslucent = false
        navigationController.view.backgroundColor = .white

        // DI (example—use your real container)
        let container = AppContainer.make()
        let coordinator = AppCoordinator(
            navigationController: navigationController,
            container: container
        )
        coordinator.start()

        let window = UIWindow(frame: windowScene.screen.bounds)
        window.windowScene = windowScene
        window.rootViewController = navigationController
        window.backgroundColor = .systemBackground
        self.window = window
        self.appCoordinator = coordinator
        window.makeKeyAndVisible()
        NetworkMonitor.shared.start(on: window)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        NetworkMonitor.shared.stop()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        if let window = window {
            NetworkMonitor.shared.start(on: window)
        }
    }
}
