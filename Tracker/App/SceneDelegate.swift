import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let storage = OnboardingStorage()
        
        if storage.hasSeenOnboarding {
            window.rootViewController = RootTabBarController()
        } else {
            window.rootViewController = OnboardingPageViewController()
        }
        
        window.makeKeyAndVisible()
        self.window = window
    }
}
