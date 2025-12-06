import UIKit

final class FiltersViewController: UIViewController {

    // MARK: - Public API
    var selectedFilter: FilterType = .all
    var onFilterSelected: ((FilterType) -> Void)?

    private let filters: [FilterType] = [.all, .today, .completed, .uncompleted]

    // MARK: - UI

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("filters_title", comment: "")
        view.backgroundColor = .systemBackground

        setupTable()
        setupLayout()
    }

    // MARK: - Setup

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseID)
    }

    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        containerView.backgroundColor = .secondarySystemBackground

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 75 * 4)
        ])
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FilterCell.reuseID,
            for: indexPath
        ) as! FilterCell

        let filter = filters[indexPath.row]
        let isSelected = filter == selectedFilter
        let isLast = indexPath.row == filters.count - 1
        cell.configure(title: filter.title, isSelected: isSelected, isLast: isLast)

        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        selectedFilter = filter
        onFilterSelected?(filter)
        dismiss(animated: true)
    }
}
