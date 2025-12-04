import UIKit

// MARK: - NewCategoryViewController

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Public Callback
    
    var onSave: ((String) -> Void)?
    
    // MARK: - UI
    
    /// Серая карточка с текстовым полем
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Поле ввода названия категории
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название категории"
        tf.font = .systemFont(ofSize: 17)
        tf.textColor = UIColor(resource: .blackDay)
        tf.attributedPlaceholder = NSAttributedString(
            string: "Введите название категории",
            attributes: [.foregroundColor: UIColor.placeholderText]
        )
        tf.backgroundColor = .clear
        tf.borderStyle = .none
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .done
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    /// Кнопка "Готово"
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Новая категория"
        view.backgroundColor = .systemBackground
        
        setupUI()
        layoutUI()
        setupActions()
        updateButtonState()
        setupKeyboardToolbar()
        setupKeyboardDismissRecognizer()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(textField)
        view.addSubview(doneButton)
    }
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            // Контейнер
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75),
            
            // Текстовое поле
            textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Кнопка "Готово"
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions Setup
    
    private func setupActions() {
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
    }
    
    // MARK: - Form Validation
    
    @objc private func textDidChange() {
        updateButtonState()
    }
    
    private func updateButtonState() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let enabled = !text.isEmpty
        
        doneButton.isEnabled = enabled
        
        if enabled {
            doneButton.backgroundColor = UIColor(resource: .blackDay)
            doneButton.setTitleColor(.white, for: .normal)
        } else {
            doneButton.backgroundColor = .systemGray4
            doneButton.setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: - Save Action
    
    @objc private func didTapDone() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        
        onSave?(text)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Keyboard UX
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flex = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.setItems([flex, done], animated: false)
        textField.inputAccessoryView = toolbar
    }
    
    private func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
