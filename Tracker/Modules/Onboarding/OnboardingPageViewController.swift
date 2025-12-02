import UIKit

// MARK: - OnboardingPageViewController

final class OnboardingPageViewController: UIPageViewController {
    
    // MARK: - Private Properties
    
    private let pageControl = UIPageControl()
    private var pages: [OnboardingViewController] = []
    
    
    // MARK: - Init
    
    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        configurePages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Configure Pages
    
    private func configurePages() {
        
        let page1 = OnboardingViewController(page: OnboardingPage(
            imageName: "onboarding-1",
            title: "Отслеживайте только то, что хотите"
        ))
        
        let page2 = OnboardingViewController(page: OnboardingPage(
            imageName: "onboarding-2",
            title: "Даже если это не литры воды и йога"
        ))
        
        
        // Кнопка на 1 экране → листаем на 2
        page1.onNext = { [weak self] in
            guard let self else { return }
            self.setViewControllers([page2], direction: .forward, animated: true)
            self.pageControl.currentPage = 1
        }
        
        // Кнопка на 2 экране → вход в приложение
        page2.onNext = { [weak self] in
            self?.finishOnboarding()
        }
        
        pages = [page1, page2]
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageController()
        setupPageControl()
    }
    
    
    // MARK: - Setup PageViewController
    
    private func setupPageController() {
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
    }
    
    
    // MARK: - Setup PageControl
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 678),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        pageControl.currentPageIndicatorTintColor = UIColor(named: "Black [day]") ?? .black
        pageControl.pageIndicatorTintColor = UIColor(named: "Black [day]")?.withAlphaComponent(0.3) ?? .lightGray
    }
    
    
    // MARK: - Finish Onboarding
    
    private func finishOnboarding() {
        guard let window = view.window else { return }
        
        // Сохраняем флаг
        OnboardingStorage().hasSeenOnboarding = true
        
        let tabBar = RootTabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        
        UIView.transition(
            with: window,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = tabBar
            },
            completion: nil
        )
    }
}


// MARK: - UIPageViewControllerDataSource & Delegate

extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // Можно листать назад
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        
        guard let index = pages.firstIndex(of: viewController as! OnboardingViewController),
              index > 0 else { return nil }
        
        return pages[index - 1]
    }
    
    
    // Вперёд можно ТОЛЬКО до последнего экрана
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        
        guard let index = pages.firstIndex(of: viewController as! OnboardingViewController),
              index < pages.count - 1 else {
            // На последней странице свайп вперёд НЕДОСТУПЕН, только по кнопке
            return nil
        }
        
        return pages[index + 1]
    }
    
    
    // Обновляем PageControl
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let visibleVC = viewControllers?.first as? OnboardingViewController,
              let index = pages.firstIndex(of: visibleVC) else { return }
        
        pageControl.currentPage = index
    }
}
