import UIKit

// MARK: - CategoryViewController

final class CategoryViewController: UIViewController {

    // MARK: - UI

    private let containerView = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let addButton = UIButton(type: .system)

    // MARK: - MVVM

    private let viewModel: CategoryViewModel

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

        setupContainerView()
        setupTableView()
        setupAddButton()
        layoutUI()
        bindViewModel()
    }

    // MARK: - Setup UI

    private func setupContainerView() {
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        containerView.addSubview(tableView)
    }

    private func setupAddButton() {
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor(named: "BlackDay") ?? .black
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        view.addSubview(addButton)
    }
    
    

    // MARK: - Layout

    private func layoutUI() {
        NSLayoutConstraint.activate([
            // Кнопка снизу
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            addButton.heightAnchor.constraint(equalToConstant: 60),

            // Контейнер со списком
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),

            // Таблица внутри контейнера
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
        }
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

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }

        let title = viewModel.titleForRow(at: indexPath.row)
        let isSelected = (viewModel.selectedCategoryTitle == title)
        let isLast = indexPath.row == viewModel.numberOfRows() - 1

        cell.configure(with: title, selected: isSelected, isLast: isLast)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Сообщаем ViewModel о выборе
        viewModel.selectCategory(at: indexPath.row)
        // Показываем галочку
        tableView.reloadData()
    }

    // MARK: - Context Menu (долгий тап по категории)

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let title = viewModel.titleForRow(at: indexPath.row)

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }

            let edit = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "pencil")
            ) { _ in
                self.presentEditCategory(at: indexPath.row, currentTitle: title)
            }

            let delete = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.viewModel.deleteCategory(at: indexPath.row)
            }

            return UIMenu(title: "", children: [edit, delete])
        }
    }
}
