// MARK: - ScheduleViewController

import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Public
    
    /// Callback для передачи выбранных дней недели назад
    var onDaysSelected: (([WeekDay]) -> Void)?
    
    // MARK: - UI
    
    private let cardView = UIView()
    private let stackView = UIStackView()
    private let doneButton = UIButton(type: .system)
    
    // MARK: - Data
    
    private var selectedWeekdays: Set<Int> = []
    
    private let weekdays = [
        "Понедельник", "Вторник", "Среда", "Четверг",
        "Пятница", "Суббота", "Воскресенье"
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        view.backgroundColor = .systemBackground
        setupUI()
        layoutUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Подложка с закруглениями
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        // Вертикальный стек для ScheduleCell
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stackView)
        
        // Заполняем стек ячейками для каждого дня недели
        for i in 0..<weekdays.count {
            let cell = ScheduleCell()
            let title = weekdays[i]
            let isLast = i == weekdays.count - 1
            let isOn = selectedWeekdays.contains(i)
            
            cell.configure(
                title: title,
                isOn: isOn,
                showSeparator: !isLast,
                toggleTag: i,
                toggleTarget: self,
                toggleAction: #selector(switchChanged(_:))
            )
            stackView.addArrangedSubview(cell)
        }
        
        // Кнопка "Готово"
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 16
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        view.addSubview(doneButton)
    }
    
    // MARK: - Layout
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            // Подложка
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Стек внутри подложки
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: CGFloat(weekdays.count) * 75),
            
            // Кнопка
            doneButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 32),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    
    /// Обработка нажатия на кнопку "Готово"
    @objc private func didTapDone() {
        let selected: [WeekDay] = selectedWeekdays.sorted().compactMap { WeekDay(rawValue: $0) }
        onDaysSelected?(selected)
        navigationController?.popViewController(animated: true)
    }
    
    /// Обработка изменения значения UISwitch в ячейке
    @objc private func switchChanged(_ sender: UISwitch) {
        let i = sender.tag
        if sender.isOn {
            selectedWeekdays.insert(i)
        } else {
            selectedWeekdays.remove(i)
        }
    }
}
