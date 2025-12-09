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
        sc.searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "")
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
        picker.backgroundColor = .white
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.overrideUserInterfaceStyle = .light
        
        return picker
    }()
    
    private let emptyView = EmptyStateView(
        image: UIImage(named: "Star"),
        title: NSLocalizedString("empty_trackers_placeholder", comment: "")
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
    
    private let filterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("filters_button", comment: "Фильтры"), for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        btn.layer.cornerRadius = 16
        btn.isHidden = true
        return btn
    }()
    
    /// Секция = категория + трекеры
    private struct Section {
        let title: String
        let trackers: [TrackerCoreData]
    }
    
    private var currentFilter: FilterType = .all {
        didSet {
            collectionView.reloadData()
            updateVisibleState()
        }
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
        
        // Дополнительная фильтрация по выбранному фильтру
        let filteredByFilter: [TrackerCoreData] = filtered.compactMap { trackerCD in
            switch currentFilter {
                
            case .all:
                return trackerCD
                
            case .today:
                
                return trackerCD
                
            case .completed:
                return recordStore.isCompleted(tracker: trackerCD, on: selectedDate)
                ? trackerCD : nil
                
            case .uncompleted:
                return recordStore.isCompleted(tracker: trackerCD, on: selectedDate)
                ? nil : trackerCD
            }
        }
        
        // Группировка по категории
        let grouped = Dictionary(grouping: filteredByFilter) { t in
            let categoryTitle = t.category?.title
            return categoryTitle?.isEmpty == false
            ? categoryTitle!
            : NSLocalizedString("habits_title", comment: "")
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
        setupFilterButton()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStoreUpdate),
            name: Notification.Name("TrackersDidChange"),
            object: nil
        )
    }
    
    // MARK: - Analytics (lifecycle)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: "open", screen: "Main")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.report(event: "close", screen: "Main")
    }
    
    // MARK: - Core Data Update
    
    @objc private func onStoreUpdate() {
        collectionView.reloadData()
        updateVisibleState()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("trackers_title", comment: "")
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
        collectionView.contentInset.bottom = 100
        collectionView.verticalScrollIndicatorInsets.bottom = 100
        
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
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !query.isEmpty {
            if sections.isEmpty {
                emptyView.isHidden = false
                emptyView.configure(
                    image: UIImage(named: "error"),
                    title: NSLocalizedString("nothing_found", comment: "")
                )
            } else {
                emptyView.isHidden = true
            }
        } else {
            if sections.isEmpty {
                emptyView.isHidden = false
                emptyView.configure(
                    image: UIImage(named: "Star"),
                    title: NSLocalizedString("empty_trackers_placeholder", comment: "")
                )
            } else {
                emptyView.isHidden = true
            }
        }
        
        filterButton.isHidden = sections.isEmpty
    }
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
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
        UIColor(hex: hex)
    }
    
    // MARK: - Actions
    
    @objc private func didTapAdd() {
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "add_track")
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
    
    @objc private func didTapFilterButton() {
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "filter")
        let vc = FiltersViewController()
        vc.selectedFilter = currentFilter
        
        vc.onFilterSelected = { [weak self] (filter: FilterType) in
            guard let self else { return }
            
            self.currentFilter = filter
            
            // Если выбрано "Сегодня" — меняем дату в календаре
            if filter == .today {
                let today = Date()
                self.selectedDate = today
                self.datePicker.date = today
            }
        }
        
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    // MARK: - Context Menu Actions
    
    private func editTracker(_ trackerCD: TrackerCoreData) {
        let tracker = makeTracker(from: trackerCD)
        let completedDays = recordStore.completedCount(for: trackerCD)
        let editVC = NewHabitViewController(
            trackerToEdit: tracker,
            completedDays: completedDays
        )
        editVC.onTrackerEdited = { [weak self] updated in
            guard let self else { return }
            
            do {
                try self.trackerStore.update(
                    trackerCD: trackerCD,
                    name: updated.name,
                    emoji: updated.emoji,
                    color: updated.color,
                    schedule: updated.schedule,
                    category: updated.category
                )
                self.collectionView.reloadData()
                self.updateVisibleState()
                
            } catch {
                print("❌ error updating tracker:", error)
            }
        }
        
        let nav = UINavigationController(rootViewController: editVC)
        present(nav, animated: true)
    }
    
    private func confirmDelete(_ trackerCD: TrackerCoreData) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("delete_tracker_message", comment: ""),
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete_button", comment: ""),
            style: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(trackerCD)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel_button", comment: ""),
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func deleteTracker(_ trackerCD: TrackerCoreData) {
        do {
            try trackerStore.delete(trackerCD)
            collectionView.reloadData()
            updateVisibleState()
        } catch {
            print("❌ error deleting tracker:", error)
        }
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
        
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "track")
        
        do {
            if recordStore.isCompleted(tracker: trackerCD, on: selectedDate) {
                try recordStore.remove(tracker: trackerCD, date: selectedDate)
            } else {
                try recordStore.add(tracker: trackerCD, date: selectedDate)
            }
            
            collectionView.reloadData()
            updateVisibleState()
            NotificationCenter.default.post(name: .statisticsShouldUpdate, object: nil)
            
        } catch {
            print("❌ error toggling record:", error)
        }
    }
}

// MARK: - Context Menu

extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        let trackerCD = sections[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            // Редактировать
            let edit = UIAction(
                title: NSLocalizedString("edit_button", comment: ""),
                image: UIImage(systemName: "pencil")
            ) { _ in
                AnalyticsService.shared.report(event: "click", screen: "Main", item: "edit")
                self.editTracker(trackerCD)
            }
            
            // Удалить
            let delete = UIAction(
                title: NSLocalizedString("delete_button", comment: ""),
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                AnalyticsService.shared.report(event: "click", screen: "Main", item: "delete")
                self.confirmDelete(trackerCD)
            }
            
            return UIMenu(children: [edit, delete])
        }
    }
}
