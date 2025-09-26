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
    
    // MARK: - Data
    
    var onTrackerCreated: ((Tracker) -> Void)?  // Замыкание для передачи данных
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedDays: [WeekDay] = []
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layoutUI()
        setupCallbacks()
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
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreate() {
        guard
            let title = titleTextField.text,
            !title.isEmpty,
            let emoji = selectedEmoji,
            let color = selectedColor
        else {
            
            return
        }
        
        let tracker = Tracker(
            id: UUID(),
            name: title,
            color: color,
            emoji: emoji,
            schedule: selectedDays
        )
        
        onTrackerCreated?(tracker)
        navigationController?.dismiss(animated: true)
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
        
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
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
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.systemBlue, for: .normal)
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        
        [titleTextField, categoryButton, scheduleButton,
         emojiLabel, emojiCollection, colorLabel, colorCollection,
         cancelButton, createButton]
            .forEach { contentView.addSubview($0) }
        
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
    }
    
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
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
            
            cancelButton.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: 32),
            cancelButton.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            
            createButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            createButton.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
        ])
    }
    
    private func setupCallbacks() {
        emojiCollection.onEmojiSelected = { [weak self] emoji in
            self?.selectedEmoji = emoji
        }
        
        colorCollection.onColorSelected = { [weak self] color in
            self?.selectedColor = color
        }
    }
}
