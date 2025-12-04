import UIKit

// MARK: - CreateCategoryViewController

final class CreateCategoryViewController: UIViewController {
    
    // MARK: - Callback
    var onCategoryCreated: ((TrackerCategoryCoreData) -> Void)?
    
    // MARK: - UI
    private let textField = UITextField()
    private let doneButton = UIButton(type: .system)
    
    private let viewModel = CategoryViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Новая категория"
        view.backgroundColor = .systemBackground
        
        setupTextField()
        setupDoneButton()
        updateButtonState()
    }
    
    // MARK: - Setup UI
    
    private func setupTextField() {
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updateButtonState() {
        let enabled = !(textField.text ?? "").isEmpty
        
        doneButton.isEnabled = enabled
        doneButton.backgroundColor = enabled ?
            UIColor(named: "Black [day]") ?? .black :
            UIColor.lightGray
        
        doneButton.setTitleColor(.white, for: .normal)
    }
    
    // MARK: - Actions
    
    @objc private func textChanged() {
        updateButtonState()
    }
    
    @objc private func doneTapped() {
        guard let title = textField.text, !title.isEmpty else { return }
        
        try? TrackerCategoryStore.shared.create(title: title)
        
        let category = TrackerCategoryStore.shared.fetch().first(where: { $0.title == title })!
        
        onCategoryCreated?(category)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Helpers

private extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
