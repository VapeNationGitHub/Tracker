import UIKit
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // MARK: - Register Value Transformers (до Core Data)
        ValueTransformer.setValueTransformer(
            WeekDaysTransformer(),
            forName: NSValueTransformerName("WeekDaysTransformer")
        )
        
        // MARK: - AppMetrica Init
        let configuration = YMMYandexMetricaConfiguration(apiKey: "a76f9986-a218-4c40-97af-06ec21d724e4")
        YMMYandexMetrica.activate(with: configuration!)
        
        print("📊 AppMetrica activated")
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        
        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
    
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) { }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataStack.shared.saveContext()
    }
}
