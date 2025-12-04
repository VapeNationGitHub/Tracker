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
        
        // Кнопка на обеих страницах пропускает онбординг
        page1.onNext = { [weak self] in
            self?.skipOnboarding()
        }
        
        page2.onNext = { [weak self] in
            self?.skipOnboarding()
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

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 678),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        let blackDayColor = UIColor(resource: .blackDay)

        pageControl.currentPageIndicatorTintColor = blackDayColor
        pageControl.pageIndicatorTintColor = blackDayColor.withAlphaComponent(0.3)
    }
    
    
    // MARK: - Finish Onboarding
    
    var onFinish: (() -> Void)?
    
    private func finishOnboarding() {
        OnboardingStorage.shared.hasSeenOnboarding = true
        onFinish?()
    }
    
    // MARK: - Пропустить Onboarding
    func skipOnboarding() {
        finishOnboarding()
    }
}


// MARK: - UIPageViewControllerDataSource & Delegate

extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // Можно листать назад
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        
        guard
            let vc = viewController as? OnboardingViewController,
            let index = pages.firstIndex(of: vc),
            index > 0
        else {
            return nil
        }
        
        return pages[index - 1]
    }
    
    
    // Вперёд можно ТОЛЬКО до последнего экрана
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        
        guard
            let vc = viewController as? OnboardingViewController,
            let index = pages.firstIndex(of: vc),
            index < pages.count - 1
        else {
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
