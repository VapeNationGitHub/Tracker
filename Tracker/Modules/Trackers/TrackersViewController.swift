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

    // MARK: - Data

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []

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
        let hasTrackers = !categories.flatMap { $0.trackers }.isEmpty
        emptyView.isHidden = hasTrackers
    }

    // MARK: - Actions

    @objc private func didTapAdd() {
        let createVC = CreateTrackerViewController()
        createVC.onTrackerCreated = { [weak self] tracker in
            guard let self = self else { return }

            let newCategory = TrackerCategory(title: "Привычки", trackers: [tracker])
            self.categories.append(newCategory)

            self.collectionView.reloadData()
            self.updateVisibleState()
        }

        let navController = UINavigationController(rootViewController: createVC)
        present(navController, animated: true)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = categories[indexPath.section].trackers[indexPath.item]

        let isCompleted = completedTrackers.contains {
            $0.trackerID == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }

        let completedDays = completedTrackers.filter {
            $0.trackerID == tracker.id
        }.count

        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays)
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
    func updateSearchResults(for searchController: UISearchController) { }
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
