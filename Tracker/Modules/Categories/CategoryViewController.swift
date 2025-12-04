import UIKit

// MARK: - CategoryViewController

final class CategoryViewController: UIViewController {
    
    // MARK: - UI
    
    /// Серая «карточка»
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Таблица со списком категорий
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = 75
        table.isScrollEnabled = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    /// Кнопка добавления новой категории
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(resource: .blackDay)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Empty State
    
    private let emptyIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(resource: .star))
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
    
    private lazy var emptyStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emptyIcon, emptyLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - ViewModel
    
    private let viewModel: CategoryViewModel
    
    // MARK: - Constraints
    
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
        
        setupUI()
        setupTableView()
        setupBindings()
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContainerHeight()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(containerView)
        view.addSubview(addButton)
        view.addSubview(emptyStack)
        
        containerView.addSubview(tableView)
        
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        
        layoutUI()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
    }
    
    private func setupBindings() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updateUI()
        }
    }
    
    // MARK: - Layout
    
    private func layoutUI() {
        
        // Кнопка "Добавить категорию"
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Пустое состояние
        NSLayoutConstraint.activate([
            emptyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            emptyIcon.widthAnchor.constraint(equalToConstant: 80),
            emptyIcon.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Контейнер серого блока
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Динамическая высота контейнера
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)
        containerHeightConstraint?.isActive = true
        
        // Таблица внутри контейнера
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - UI Update
    
    private func updateUI() {
        let hasCategories = viewModel.numberOfRows() > 0
        
        containerView.isHidden = !hasCategories
        tableView.isHidden = !hasCategories
        emptyStack.isHidden = hasCategories
        
        updateContainerHeight()
    }
    
    private func updateContainerHeight() {
        tableView.layoutIfNeeded()
        containerHeightConstraint?.constant = tableView.contentSize.height
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
    
    // MARK: - Delete Alert
    
    private func showDeleteAlert(at index: Int) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        
        let delete = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: index)
        }
        
        let cancel = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    // MARK: - Context Menu (Edit / Delete)
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint)
    -> UIContextMenuConfiguration? {
        
        let title = viewModel.titleForRow(at: indexPath.row)
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { [weak self] _ in
            
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
                self.showDeleteAlert(at: indexPath.row)
            }
            
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}
