import UIKit
import UIColorHexSwift

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {
    
    // MARK: - Dependencies
    
    private let trackerStore = TrackerStore.shared
    private let categoryStore = TrackerCategoryStore.shared
    private let recordStore = TrackerRecordStore.shared
    
    // MARK: - UI
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.placeholder = "Поиск"
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchResultsUpdater = self
        sc.searchBar.delegate = self
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
    
    // MARK: - State / Filtering
    
    private var searchText: String = "" {
        didSet {
            collectionView.reloadData()
            updateVisibleState()
        }
    }
    
    private var selectedDate: Date = Date() {
        didSet {
            collectionView.reloadData()
            updateVisibleState()
        }
    }
    
    /// Секция = категория + трекеры
    private struct Section {
        let title: String
        let trackers: [TrackerCoreData]
    }
    
    // MARK: - Grouped Trackers
    
    private var sections: [Section] {
        let allTrackers = trackerStore.fetch()
        
        let calendarWeekday = Calendar.current.component(.weekday, from: selectedDate)
        let neededDay = WeekDay.from(calendarWeekday: calendarWeekday)
        
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Фильтруем по дате + поиску
        let filtered = allTrackers.filter { trackerCD in
            let schedule = trackerStore.getSchedule(from: trackerCD)
            let visibleByDay = schedule.isEmpty || schedule.contains(neededDay)
            
            let matchesSearch = query.isEmpty
                ? true
                : (trackerCD.name?.lowercased().contains(query) ?? false)
            
            return visibleByDay && matchesSearch
        }
        
        // Группировка по категории
        let grouped = Dictionary(grouping: filtered) { t in
            t.category?.title ?? "Привычки"
        }
        
        // Сортировка по алфавиту
        return grouped
            .sorted { $0.key < $1.key }
            .map { Section(title: $0.key, trackers: $0.value) }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupCollectionView()
        layoutEmptyView()
        updateVisibleState()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStoreUpdate),
            name: Notification.Name("TrackersDidChange"),
            object: nil
        )
    }
    
    // MARK: - Core Data Update
    
    @objc private func onStoreUpdate() {
        collectionView.reloadData()
        updateVisibleState()
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
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 9, bottom: 16, right: 9)
        
        collectionView.register(
            CategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategoryHeaderView.reuseIdentifier
        )
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.reuseIdentifier
        )
        
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
    
    private func updateVisibleState() {
        emptyView.isHidden = !sections.isEmpty
    }
    
    // MARK: - Mapping
    
    private func makeTracker(from cd: TrackerCoreData) -> Tracker {
        Tracker(
            id: cd.id ?? UUID(),
            name: cd.name ?? "",
            color: colorFromHex(cd.colorHex ?? "#007BFF"),
            emoji: cd.emoji ?? "🙂",
            schedule: trackerStore.getSchedule(from: cd),
            category: cd.category!
        )
    }
    
    private func colorFromHex(_ hex: String) -> UIColor {
        UIColor(hex: hex) ?? .blue
    }
    
    // MARK: - Actions
    
    @objc private func didTapAdd() {
        let habitVC = NewHabitViewController()
        
        habitVC.onTrackerCreated = { [weak self] tracker in
            guard let self else { return }
            
            do {
                try trackerStore.create(
                    id: tracker.id,
                    name: tracker.name,
                    emoji: tracker.emoji,
                    color: tracker.color,
                    schedule: tracker.schedule,
                    category: tracker.category
                )
                
                self.collectionView.reloadData()
                self.updateVisibleState()
                
            } catch {
                print("❌ error creating tracker:", error)
            }
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
    
    func numberOfSections(in cv: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ cv: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        sections[section].trackers.count
    }
    
    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as! TrackerCell
        
        let trackerCD = sections[indexPath.section].trackers[indexPath.item]
        let tracker = makeTracker(from: trackerCD)
        
        let isCompleted = recordStore.isCompleted(tracker: trackerCD, on: selectedDate)
        let completedDays = recordStore.completedCount(for: trackerCD)
        
        let isFuture = Calendar.current.startOfDay(for: selectedDate) >
                       Calendar.current.startOfDay(for: Date())
        
        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            completedDays: completedDays
        )
        
        cell.setCompletionEnabled(!isFuture)
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - Header
    
    func collectionView(
        _ cv: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = cv.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.reuseIdentifier,
            for: indexPath
        ) as! CategoryHeaderView
        
        header.configure(title: sections[indexPath.section].title)
        return header
    }
}

// MARK: - Layout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ cv: UICollectionView,
        layout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let spacing: CGFloat = 9
        let columns: CGFloat = 2
        let totalSpacing = (columns + 1) * spacing
        let available = cv.bounds.width - totalSpacing
        
        return CGSize(
            width: floor(available / columns),
            height: 148
        )
    }
    
    func collectionView(
        _ cv: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        CGSize(width: cv.bounds.width, height: 34)
    }
}

// MARK: - Search

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let new = searchController.searchBar.text ?? ""
        if new != searchText {
            searchText = new
        }
    }
}

// MARK: - SearchBar Delegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchText = ""
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapComplete(_ cell: TrackerCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }
        
        let trackerCD = sections[index.section].trackers[index.item]
        
        do {
            if recordStore.isCompleted(tracker: trackerCD, on: selectedDate) {
                try recordStore.remove(tracker: trackerCD, date: selectedDate)
            } else {
                try recordStore.add(tracker: trackerCD, date: selectedDate)
            }
            
            collectionView.reloadData()
            updateVisibleState()
            
        } catch {
            print("❌ error toggling record:", error)
        }
    }
}
