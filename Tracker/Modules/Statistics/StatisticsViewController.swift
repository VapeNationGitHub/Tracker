import UIKit

final class StatisticsViewController: UIViewController {
    
    private let recordStore = TrackerRecordStore.shared
    private let trackerStore = TrackerStore.shared
    
    private let emptyView = EmptyStateView(
        image: UIImage(named: "smile_empty_state"),
        title: NSLocalizedString("empty_statistics", comment: "")
    )
    
    private lazy var completedCard = StatisticsCardView(
        count: 0,
        title: NSLocalizedString("stats_completed", comment: "")
    )
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_title", comment: "")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor.label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        updateStatistics()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStatisticsUpdate),
            name: .statisticsShouldUpdate,
            object: nil
        )
    }
    
    private func setupUI() {
        
        // Заголовок
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        // Пустой экран
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Карточка статистики
        view.addSubview(completedCard)
        NSLayoutConstraint.activate([
            completedCard.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 40),
            completedCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completedCard.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    @objc private func onStatisticsUpdate() {
        updateStatistics()
    }
    
    private func updateStatistics() {
        let total = recordStore.totalCompleted()
        let trackers = trackerStore.fetch()
        
        let isEmpty = trackers.isEmpty || total == 0
        
        emptyView.isHidden = !isEmpty
        completedCard.isHidden = isEmpty
        
        if !isEmpty {
            completedCard.configure(count: total,
                                    title: NSLocalizedString("stats_completed", comment: ""))
        }
    }
}
