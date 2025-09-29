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
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        footerView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            button.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16),
            button.heightAnchor.constraint(equalToConstant: 48)
        ])
        tableView.tableFooterView = footerView
    }
    
    // MARK: - Actions
    
    @objc private func didTapDone() {
        let selected: [WeekDay] = selectedWeekdays
            .sorted()
            .compactMap { WeekDay(rawValue: $0) }
        
        onDaysSelected?(selected)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let index = sender.tag
        if sender.isOn {
            selectedWeekdays.insert(index)
        } else {
            selectedWeekdays.remove(index)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = weekdays[indexPath.row]
        
        let switchView = UISwitch()
        switchView.isOn = selectedWeekdays.contains(indexPath.row)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
}
