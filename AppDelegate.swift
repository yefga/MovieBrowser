import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    // If your app uses scenes (iOS 13+), provide a configuration here.
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        // Ensure we hook up our SceneDelegate defined elsewhere in the project
        config.delegateClass = SceneDelegate.self
        return config
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Handle any cleanup if needed when scenes are discarded.
    }
}
