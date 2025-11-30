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
    
    private let notFoundView = EmptyStateView(
        image: UIImage(named: "error"),
        title: "Ничего не найдено"
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
    
    /// Секция для collectionView — категория + трекеры этой категории
    private struct Section {
        let title: String
        let trackers: [TrackerCoreData]
    }
    
    /// Все секции с учётом фильтра по дате и поиску
    private var sections: [Section] {
        let allTrackers = trackerStore.fetch()
        
        // День недели из выбранной даты
        let calendarWeekday = Calendar.current.component(.weekday, from: selectedDate)
        let neededDay = WeekDay.from(calendarWeekday: calendarWeekday)
        
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        // Фильтрация
        let filtered = allTrackers.filter { trackerCD in
            // 1) Расписание
            let scheduleStrings = trackerCD.schedule as? [String] ?? []
            let schedule = scheduleStrings
                .compactMap { Int($0) }
                .compactMap { WeekDay(rawValue: $0) }
            
            let isVisibleByDay = schedule.isEmpty || schedule.contains(neededDay)
            
            print("📥 scheduleStrings:", scheduleStrings)
            print("📅 schedule (WeekDay):", schedule)
            
            // 2) Поиск
            let name = trackerCD.name?.lowercased() ?? ""
            let matchesSearch = query.isEmpty ? true : name.contains(query)
            
            return isVisibleByDay && matchesSearch
        }
        
        // Группируем по названию категории
        let grouped = Dictionary(grouping: filtered) { (tracker: TrackerCoreData) -> String in
            tracker.category?.title ?? "Привычки"
        }
        
        // Сортируем категории по названию
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
    
    // MARK: - Core Data Updates
    
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
    
    private func updateVisibleState() {
        let hasAny = !sections.isEmpty
        
        if hasAny {
            emptyView.isHidden = true
        } else {
            emptyView.isHidden = false
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                emptyView.configure(image: UIImage(named: "Star"),
                                    title: "Что будем отслеживать?")
            } else {
                emptyView.configure(image: UIImage(named: "error"),
                                    title: "Ничего не найдено")
            }
        }
    }
    
    // MARK: - Helpers (Mapping)
    
    /// Преобразуем CoreData-модель в доменную Tracker
    private func makeTracker(from cd: TrackerCoreData) -> Tracker {
        let id = cd.id ?? UUID()
        let name = cd.name ?? ""
        let emoji = cd.emoji ?? "🙂"
        
        let hex = cd.colorHex ?? "#007BFF"
        let color = colorFromHex(hex)
        
        let scheduleRaw = cd.schedule as? [Int] ?? []
        print("📅 schedule CD:", scheduleRaw)
        let schedule = scheduleRaw.compactMap { WeekDay(rawValue: $0) }
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    /// Преобразуем HEX-строку в UIColor
    private func colorFromHex(_ hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    // MARK: - Actions
    
    @objc private func didTapAdd() {
        let habitVC = NewHabitViewController()
        
        habitVC.onTrackerCreated = { [weak self] tracker in
            guard let self = self else { return }
            
            do {
                // Категория по умолчанию
                let categoryCD = try self.categoryStore.defaultCategory()
                
                try self.trackerStore.create(
                    id: tracker.id,
                    name: tracker.name,
                    emoji: tracker.emoji,
                    color: tracker.color,
                    schedule: tracker.schedule,
                    category: categoryCD
                )
                
                self.collectionView.reloadData()
                self.updateVisibleState()
            } catch {
                print("❌ Error creating tracker:", error)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        sections[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as! TrackerCell
        
        let trackerCD = sections[indexPath.section].trackers[indexPath.item]
        let tracker = makeTracker(from: trackerCD)
        
        let isCompletedToday = recordStore.isCompleted(
            tracker: trackerCD,
            on: selectedDate
        )
        let completedDays = recordStore.completedCount(for: trackerCD)
        
        // Блокировка будущей даты
        let isFuture = Calendar.current.startOfDay(for: selectedDate) >
        Calendar.current.startOfDay(for: Date())
        
        cell.configure(with: tracker,
                       isCompleted: isCompletedToday,
                       completedDays: completedDays)
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
        let newText = searchController.searchBar.text ?? ""
        if newText == searchText { return }
        searchText = newText
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchText = ""
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapComplete(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let trackerCD = sections[indexPath.section].trackers[indexPath.item]
        
        do {
            if recordStore.isCompleted(tracker: trackerCD, on: selectedDate) {
                try recordStore.remove(tracker: trackerCD, date: selectedDate)
            } else {
                try recordStore.add(tracker: trackerCD, date: selectedDate)
            }
            
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("❌ Error toggling record:", error)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate { }
