import UIKit

// MARK: - RootTabBarController

final class RootTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        configureTabBarAppearance()
    }
    
    // MARK: - Private Methods
    
    /// Настройка вкладок TabBar
    private func setupTabs() {
        let trackers = UINavigationController(rootViewController: TrackersViewController())
        trackers.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tab_trackers"),
            tag: 0
        )
        
        let stats = UINavigationController(rootViewController: StatisticsViewController())
        stats.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tab_statistics"),
            tag: 1
        )
        
        viewControllers = [trackers, stats]
    }
    
    /// Настройка внешнего вида TabBar
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
