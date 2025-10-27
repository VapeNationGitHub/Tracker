import UIKit

private final class ListRowView: UIControl {
    private let titleLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let separator = UIView()
    
    var text: String {
        get { titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }
    
    var showsSeparator: Bool = false {
        didSet { separator.isHidden = !showsSeparator }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    convenience init(title: String) {
        self.init(frame: .zero); self.text = title
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        chevronView.tintColor = .tertiaryLabel
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.setContentHuggingPriority(.required, for: .horizontal)
        
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.5)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.isHidden = true
        
        addSubview(titleLabel)
        addSubview(chevronView)
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - NewHabitViewController

final class NewHabitViewController: UIViewController {
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField = UITextField()
    
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
        titleTextField.becomeFirstResponder()
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
            self?.selectedDays = days
            self?.validateForm()
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc private func didTapCancel() { dismiss(animated: true) }
    
    @objc private func didTapCreate() {
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
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Новая привычка"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(didTapClose)
        )
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        titleTextField.placeholder = "Введите название трекера"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Группа строк (категория/расписание)
        listGroupView.translatesAutoresizingMaskIntoConstraints = false
        listGroupView.backgroundColor = .secondarySystemBackground
        listGroupView.layer.cornerRadius = 16
        
        categoryRow.showsSeparator = true
        categoryRow.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)
        scheduleRow.addTarget(self, action: #selector(didTapSchedule), for: .touchUpInside)
        
        listGroupView.addSubview(categoryRow)
        listGroupView.addSubview(scheduleRow)
        
        emojiLabel.text = "Emoji"
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        
        colorLabel.text = "Цвет"
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        
        // Нижние кнопки
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
        [titleTextField, listGroupView, emojiLabel, emojiCollection, colorLabel, colorCollection]
            .forEach { contentView.addSubview($0) }
        
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        bottomStack.addArrangedSubview(cancelButton)
        bottomStack.addArrangedSubview(createButton)
        view.addSubview(bottomStack)
    }
    
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
            
            // Поля
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Контейнер с двумя строками
            listGroupView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            listGroupView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            listGroupView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryRow.topAnchor.constraint(equalTo: listGroupView.topAnchor),
            categoryRow.leadingAnchor.constraint(equalTo: listGroupView.leadingAnchor),
            categoryRow.trailingAnchor.constraint(equalTo: listGroupView.trailingAnchor),
            
            scheduleRow.topAnchor.constraint(equalTo: categoryRow.bottomAnchor),
            scheduleRow.leadingAnchor.constraint(equalTo: listGroupView.leadingAnchor),
            scheduleRow.trailingAnchor.constraint(equalTo: listGroupView.trailingAnchor),
            scheduleRow.bottomAnchor.constraint(equalTo: listGroupView.bottomAnchor),
            
            // Остальное
            emojiLabel.topAnchor.constraint(equalTo: listGroupView.bottomAnchor, constant: 24),
            emojiLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            
            emojiCollection.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollection.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            emojiCollection.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            emojiCollection.heightAnchor.constraint(equalToConstant: 100),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 24),
            colorLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            
            colorCollection.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollection.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            colorCollection.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            colorCollection.heightAnchor.constraint(equalToConstant: 100),
            
            colorCollection.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -32),
            
            // Нижняя панель кнопок
            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bottomStack.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
    
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
    
    // MARK: - Validation
    
    @objc private func textFieldDidChange() { validateForm() }
    
    private func validateForm() {
        let isTitleFilled = !(titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isFormValid = isTitleFilled && isEmojiSelected && isColorSelected
        
        createButton.isEnabled = isFormValid
        if isFormValid {
            createButton.backgroundColor = .systemBlue
            createButton.setTitleColor(.white, for: .normal)
        } else {
            createButton.backgroundColor = .systemGray4
            createButton.setTitleColor(.white, for: .normal)
        }
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.setTitleColor(.systemRed, for: .normal)
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
