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
        
        let storage = OnboardingStorage.shared
        
        if storage.hasSeenOnboarding {
            window.rootViewController = RootTabBarController()
        } else {
            
            let onboarding = OnboardingPageViewController()
            
            onboarding.onFinish = {
                storage.hasSeenOnboarding = true
                
                UIView.transition(
                    with: window,
                    duration: 0.4,
                    options: .transitionCrossDissolve,
                    animations: {
                        window.rootViewController = RootTabBarController()
                    },
                    completion: nil
                )
            }
            
            window.rootViewController = onboarding
        }
        
        window.makeKeyAndVisible()
        self.window = window
    }
}
