import UIKit

// MARK: - CategoryViewController

final class CategoryViewController: UIViewController {

    // MARK: - UI

    /// Серая "карточка"
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = 75
        table.isScrollEnabled = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "BlackDay") ?? .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: Пустое состояние

    private let emptyIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Star"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .blackDay
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var emptyStack = UIStackView()

    // MARK: - MVVM

    private let viewModel: CategoryViewModel

    // MARK: - Layout constraints

    private var containerHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Категория"
        view.backgroundColor = .systemBackground

        setupEmptyState()
        setupContainer()
        setupTableView()
        setupAddButton()
        layoutUI()
        bindViewModel()
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContainerHeight()
    }

    // MARK: - Setup

    private func setupContainer() {
        view.addSubview(containerView)
        containerView.addSubview(tableView)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
    }

    private func setupAddButton() {
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        view.addSubview(addButton)
    }

    private func setupEmptyState() {
        emptyStack = UIStackView(arrangedSubviews: [emptyIcon, emptyLabel])
        emptyStack.axis = .vertical
        emptyStack.alignment = .center
        emptyStack.spacing = 12
        emptyStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStack)
    }

    // MARK: - Layout

    private func layoutUI() {

        // Add button
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Empty state
        NSLayoutConstraint.activate([
            emptyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            emptyIcon.widthAnchor.constraint(equalToConstant: 80),
            emptyIcon.heightAnchor.constraint(equalToConstant: 80)
        ])

        // Container
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // Height constraint (динамическая)
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)
        containerHeightConstraint?.isActive = true

        // Table in container
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updateUI()
        }
    }

    // MARK: - UI update

    private func updateUI() {
        let hasCategories = viewModel.numberOfRows() > 0

        containerView.isHidden = !hasCategories
        tableView.isHidden = !hasCategories

        emptyStack.isHidden = hasCategories

        updateContainerHeight()
    }

    private func updateContainerHeight() {
        tableView.layoutIfNeeded()
        let height = tableView.contentSize.height
        containerHeightConstraint?.constant = height
    }
    
    // MARK: - Alert на удаление категории

    private func showDeleteAlert(at index: Int) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(
            title: "Удалить",
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel.deleteCategory(at: index)
        }

        let cancelAction = UIAlertAction(
            title: "Отменить",
            style: .cancel
        )

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func didTapAdd() {
        let vc = NewCategoryViewController()
        vc.onSave = { [weak self] title in
            self?.viewModel.addCategory(title: title)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func presentEditCategory(at index: Int, currentTitle: String) {
        let vc = EditCategoryViewController(initialTitle: currentTitle)
        vc.onSave = { [weak self] newTitle in
            self?.viewModel.updateCategory(at: index, newTitle: newTitle)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath
        ) as? CategoryCell else { return UITableViewCell() }

        let title = viewModel.titleForRow(at: indexPath.row)
        let isSelected = (viewModel.selectedCategoryTitle == title)
        let isLast = indexPath.row == viewModel.numberOfRows() - 1

        cell.configure(with: title, selected: isSelected, isLast: isLast)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        tableView.reloadData()
    }

    // MARK: - Context Menu

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint)
        -> UIContextMenuConfiguration? {

        let title = viewModel.titleForRow(at: indexPath.row)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }

            let edit = UIAction(title: "Редактировать",
                                image: UIImage(systemName: "pencil")) { _ in
                self.presentEditCategory(at: indexPath.row, currentTitle: title)
            }

            let delete = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.showDeleteAlert(at: indexPath.row)
            }

            return UIMenu(title: "", children: [edit, delete])
        }
    }
}
