// MARK: - NewHabitViewController

import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField = UITextField()
    private let titleContainer = UIView()
    
    private let listGroupView = UIView()
    private let categoryRow = ListRowView(title: "Категория")
    private let scheduleRow = ListRowView(title: "Расписание")
    
    private let emojiLabel = UILabel()
    private let emojiCollection = EmojiCollectionView()
    private let colorLabel = UILabel()
    private let colorCollection = ColorCollectionView()
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let bottomStack = UIStackView()
    
    // MARK: - Data
    
    var onTrackerCreated: ((Tracker) -> Void)?
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedDays: [WeekDay] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layoutUI()
        setupCallbacks()
        setupKeyboardDismissRecognizer()
        addKeyboardToolbarToTextField()
        validateForm()
        updateScheduleSummary()
        titleTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Новая привычка"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Поле "Название"
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.backgroundColor = .secondarySystemBackground
        titleContainer.layer.cornerRadius = 16
        titleContainer.layer.masksToBounds = true
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.backgroundColor = .clear
        titleTextField.borderStyle = .none
        titleTextField.clearButtonMode = .whileEditing
        titleTextField.textAlignment = .left
        titleTextField.returnKeyType = .done
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [.foregroundColor: UIColor.placeholderText]
        )
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Группа строк
        listGroupView.translatesAutoresizingMaskIntoConstraints = false
        listGroupView.backgroundColor = .secondarySystemBackground
        listGroupView.layer.cornerRadius = 16
        
        categoryRow.showsSeparator = true
        categoryRow.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)
        scheduleRow.addTarget(self, action: #selector(didTapSchedule), for: .touchUpInside)
        
        listGroupView.addSubview(categoryRow)
        listGroupView.addSubview(scheduleRow)
        
        // Emoji и Цвет
        emojiLabel.text = "Emoji"
        emojiLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        emojiLabel.textColor = UIColor(named: "BlackDay")
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        
        colorLabel.text = "Цвет"
        colorLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        colorLabel.textColor = UIColor(named: "BlackDay")
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        
        // Кнопки
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 14
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 14
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        
        bottomStack.axis = .horizontal
        bottomStack.spacing = 16
        bottomStack.distribution = .fillEqually
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Иерархия
        contentView.addSubview(titleContainer)
        titleContainer.addSubview(titleTextField)
        
        [listGroupView, emojiLabel, emojiCollection, colorLabel, colorCollection]
            .forEach { contentView.addSubview($0) }
        
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        bottomStack.addArrangedSubview(cancelButton)
        bottomStack.addArrangedSubview(createButton)
        view.addSubview(bottomStack)
        
    }
    
    // MARK: - Layout
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            // Scroll
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -16),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Название
            titleContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleContainer.heightAnchor.constraint(equalToConstant: 75),
            
            titleTextField.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 16),
            titleTextField.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: -16),
            titleTextField.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -16),
            
            // Категория и Расписание
            listGroupView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 24),
            listGroupView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            listGroupView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryRow.topAnchor.constraint(equalTo: listGroupView.topAnchor),
            categoryRow.leadingAnchor.constraint(equalTo: listGroupView.leadingAnchor),
            categoryRow.trailingAnchor.constraint(equalTo: listGroupView.trailingAnchor),
            categoryRow.heightAnchor.constraint(equalToConstant: 75),
            
            scheduleRow.topAnchor.constraint(equalTo: categoryRow.bottomAnchor),
            scheduleRow.leadingAnchor.constraint(equalTo: listGroupView.leadingAnchor),
            scheduleRow.trailingAnchor.constraint(equalTo: listGroupView.trailingAnchor),
            scheduleRow.heightAnchor.constraint(equalToConstant: 75),
            scheduleRow.bottomAnchor.constraint(equalTo: listGroupView.bottomAnchor),
            
            // Emoji и Цвет
            emojiLabel.topAnchor.constraint(equalTo: listGroupView.bottomAnchor, constant: 24),
            emojiLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            
            emojiCollection.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollection.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            emojiCollection.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor),
            emojiCollection.heightAnchor.constraint(equalToConstant: 204),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 24),
            colorLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            
            colorCollection.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollection.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            colorCollection.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor),
            colorCollection.heightAnchor.constraint(equalToConstant: 180),
            
            colorCollection.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -32),
            
            
            // Кнопки
            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bottomStack.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Callbacks
    
    private func setupCallbacks() {
        emojiCollection.onEmojiSelected = { [weak self] emoji in
            self?.selectedEmoji = emoji
            self?.validateForm()
        }
        colorCollection.onColorSelected = { [weak self] color in
            self?.selectedColor = color
            self?.validateForm()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose() { dismiss(animated: true) }
    
    @objc private func didTapCategory() {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Категория"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapSchedule() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.onDaysSelected = { [weak self] days in
            guard let self else { return }
            print("🟡 Days received from Schedule:", days)
            self.selectedDays = days
            self.updateScheduleSummary()
            self.validateForm()
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc private func didTapCancel() { dismiss(animated: true) }
    
    @objc private func didTapCreate() {
        print("🟣 selectedDays BEFORE CREATE:", selectedDays)
        guard
            let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty,
            let emoji = selectedEmoji,
            let color = selectedColor
        else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: title,
            color: color,
            emoji: emoji,
            schedule: selectedDays
        )
        onTrackerCreated?(tracker)
        dismiss(animated: true)
    }
    
    // MARK: - Validation
    
    @objc private func textFieldDidChange() { validateForm() }
    
    private func validateForm() {
        let isTitleFilled = !(titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isFormValid = isTitleFilled && isEmojiSelected && isColorSelected
        
        createButton.isEnabled = isFormValid
        if isFormValid {
            createButton.backgroundColor = .black
            createButton.setTitleColor(.white, for: .normal)
        } else {
            createButton.backgroundColor = .systemGray4
            createButton.setTitleColor(.white, for: .normal)
        }
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.setTitleColor(.systemRed, for: .normal)
    }
    
    // MARK: - Helpers
    
    private func updateScheduleSummary() {
        let summary = formattedDays(selectedDays)
        scheduleRow.setSubtitle(summary.isEmpty ? nil : summary)
    }
    
    private func formattedDays(_ days: [WeekDay]) -> String {
        guard !days.isEmpty else { return "" }
        let short: [WeekDay: String] = [
            .monday: "Пн", .tuesday: "Вт", .wednesday: "Ср",
            .thursday: "Чт", .friday: "Пт", .saturday: "Сб", .sunday: "Вс"
        ]
        return days.sorted { $0.rawValue < $1.rawValue }
            .compactMap { short[$0] }
            .joined(separator: ", ")
    }
    
    // MARK: - Keyboard
    
    private func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func addKeyboardToolbarToTextField() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexible, done], animated: false)
        titleTextField.inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() { view.endEditing(true) }
}
