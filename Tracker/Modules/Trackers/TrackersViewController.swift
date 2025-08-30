import UIKit

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.placeholder = "Поиск"
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchResultsUpdater = self
        return sc
    }()
    
    private let emptyView = EmptyStateView(
        image: UIImage(named: "Star"),
        title: "Что будем отслеживать?"
    )
    
    private let dateButton = DateBadgeButton(type: .system)
    
    // MARK: - State
    
    private var selectedDate: Date = Date() {
        didSet {
            dateButton.setDate(selectedDate)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        layoutEmptyView()
    }
    
    // MARK: - Setup Methods
    
    /// Базовая настройка внешнего вида
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Трекеры"
    }
    
    /// Настройка навигационного бара (заголовок, кнопки, поиск)
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAdd)
        )
        
        dateButton.setDate(selectedDate)
        dateButton.addTarget(self, action: #selector(didTapDate), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateButton)
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    /// Расположение пустого состояния на экране
    private func layoutEmptyView() {
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(
            title: "Скоро",
            message: "Добавление трекера будет позже",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func didTapDate() {
        let alert = UIAlertController(
            title: "Дата",
            message: "Выбор даты сделаем позже",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}
