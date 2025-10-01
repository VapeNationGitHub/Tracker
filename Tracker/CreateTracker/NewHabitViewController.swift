import UIKit

// MARK: - NewHabitViewController

final class NewHabitViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleTextField = UITextField()
    private let categoryButton = UIButton(type: .system)
    private let scheduleButton = UIButton(type: .system)
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
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
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
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreate() {
        guard
            let title = titleTextField.text, !title.isEmpty,
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
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        titleTextField.placeholder = "Введите название трекера"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        
        categoryButton.setTitle("Категория", for: .normal)
        categoryButton.setTitleColor(.label, for: .normal)
        categoryButton.backgroundColor = .secondarySystemBackground
        categoryButton.layer.cornerRadius = 8
        categoryButton.contentHorizontalAlignment = .left
        categoryButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        categoryButton.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)
        
        scheduleButton.setTitle("Расписание", for: .normal)
        scheduleButton.setTitleColor(.label, for: .normal)
        scheduleButton.backgroundColor = .secondarySystemBackground
        scheduleButton.layer.cornerRadius = 8
        scheduleButton.contentHorizontalAlignment = .left
        scheduleButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        scheduleButton.addTarget(self, action: #selector(didTapSchedule), for: .touchUpInside)
        
        emojiLabel.text = "Emoji"
        colorLabel.text = "Цвет"
        
        
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
        
        
        [titleTextField, categoryButton, scheduleButton,
         emojiLabel, emojiCollection, colorLabel, colorCollection]
            .forEach { contentView.addSubview($0) }
        
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        
        bottomStack.addArrangedSubview(cancelButton)
        bottomStack.addArrangedSubview(createButton)
        view.addSubview(bottomStack)
    }
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            
            scrollView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -16),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 16),
            scheduleButton.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 24),
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
            
            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bottomStack.heightAnchor.constraint(equalToConstant: 56)
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
    
    @objc private func textFieldDidChange() {
        validateForm()
    }
    
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
    
    // MARK: - Keyboard Handling
    
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
