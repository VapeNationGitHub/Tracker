import UIKit

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // MARK: - UI Elements
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.placeholder = "Поиск"
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchResultsUpdater = self
        return sc
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private let emptyView = EmptyStateView(
        image: UIImage(named: "Star"),
        title: "Что будем отслеживать?"
    )
    
    private let notFoundView = EmptyStateView(
        image: UIImage(named: "error"),
        title: "Ничего не найдено"
    )
    
    
    // MARK: - Data
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Search
    private var searchText: String = ""
    
    // MARK: - Filtering
    private var filteredCategories: [TrackerCategory] {
        // День недели из выбранной даты
        let calendarWeekday = Calendar.current.component(.weekday, from: selectedDate)
        let neededDay = WeekDay.from(calendarWeekday: calendarWeekday)
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                // 1) Дата
                let isVisibleByDay = tracker.schedule.contains(neededDay)
                
                // 2) Поиск
                let matchesSearch = query.isEmpty
                ? true
                : tracker.name.lowercased().contains(query)
                
                return isVisibleByDay && matchesSearch
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }
    
    // MARK: - State
    
    private var selectedDate: Date = Date() {
        didSet {
            updateVisibleState()
            collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupCollectionView()
        layoutEmptyView()
        updateVisibleState()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Трекеры"
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAdd)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 9, bottom: 16, right: 9)
        layout.estimatedItemSize = .zero
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func layoutEmptyView() {
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func layoutEmptyViewLast() {
        [emptyView, notFoundView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                $0.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
            $0.isHidden = true
        }
    }
    
    private func updateVisibleState() {
        let hasAny = filteredCategories.contains { !$0.trackers.isEmpty }
        
        if hasAny {
            emptyView.isHidden = true
            return
        }
        
        emptyView.isHidden = false
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Пусто вообще
            emptyView.configure(image: UIImage(named: "Star"), title: "Что будем отслеживать?")
        } else {
            // Пусто из-за поиска
            emptyView.configure(image: UIImage(named: "error"), title: "Ничего не найдено")
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapAdd() {
        let habitVC = NewHabitViewController()
        habitVC.onTrackerCreated = { [weak self] tracker in
            guard let self = self else { return }
            let newCategory = TrackerCategory(title: "Привычки", trackers: [tracker])
            self.categories.append(newCategory)
            self.collectionView.reloadData()
            self.updateVisibleState()
        }
        let nav = UINavigationController(rootViewController: habitVC)
        present(nav, animated: true)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as! TrackerCell
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        let isCompletedToday = completedTrackers.contains {
            $0.trackerID == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
        
        let completedDays = completedTrackers.filter { $0.trackerID == tracker.id }.count
        
        // блокировка будущей даты
        let isFuture = Calendar.current.startOfDay(for: selectedDate) >
        Calendar.current.startOfDay(for: Date())
        
        cell.configure(with: tracker, isCompleted: isCompletedToday, completedDays: completedDays)
        cell.setCompletionEnabled(!isFuture)
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 9
        let columns: CGFloat = 2
        let totalSpacing = (columns + 1) * spacing
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / columns)
        return CGSize(width: itemWidth, height: 148)
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let newText = (searchController.searchBar.text ?? "")
        if newText == searchText { return }
        searchText = newText
        collectionView.reloadData()
        updateVisibleState()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchText = ""
        collectionView.reloadData()
        updateVisibleState()
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapComplete(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let record = TrackerRecord(trackerID: tracker.id, date: selectedDate)
        
        if let index = completedTrackers.firstIndex(where: {
            $0.trackerID == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(record)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate { }
