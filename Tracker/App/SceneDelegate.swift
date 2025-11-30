import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let trackersVC = TrackersViewController()
        let nav = UINavigationController(rootViewController: trackersVC)
        
        // ✅ Тест: создание и чтение трекера
        let testSchedule: [WeekDay] = [.monday, .wednesday, .friday]
        
        do {
            try TrackerStore.shared.create(
                id: UUID(),
                name: "🔥 Test Tracker",
                emoji: "🔥",
                color: .red,
                schedule: testSchedule,
                category: nil
            )

            if let created = TrackerStore.shared.fetch().last {
                let restored = TrackerStore.shared.getSchedule(from: created)
                print("✅ Восстановленное расписание:", restored)
            }
        } catch {
            print("❌ Ошибка при создании трекера:", error)
        }
        
        // Установка rootViewController
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window
    }
}
