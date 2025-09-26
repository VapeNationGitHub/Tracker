import UIKit

// MARK: - ScheduleViewController

final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    
    var onDaysSelected: (([WeekDay]) -> Void)?
    private var selectedWeekdays: Set<Int> = []
    private let tableView = UITableView()
    
    private let weekdays: [String] = [
        "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupDoneButton()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupDoneButton() {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    // MARK: - Actions
    
    @objc private func didTapDone() {
        let selected: [WeekDay] = selectedWeekdays
            .sorted()
            .compactMap { WeekDay(rawValue: $0) }
        
        onDaysSelected?(selected)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = weekdays[indexPath.row]
        cell.accessoryType = selectedWeekdays.contains(indexPath.row) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedWeekdays.contains(indexPath.row) {
            selectedWeekdays.remove(indexPath.row)
        } else {
            selectedWeekdays.insert(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
