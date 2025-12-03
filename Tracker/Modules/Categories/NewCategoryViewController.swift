import UIKit

// MARK: - NewCategoryViewController

final class NewCategoryViewController: UIViewController {

    // MARK: - Public Callback

    var onSave: ((String) -> Void)?

    // MARK: - UI

    private let containerView = UIView()
    private let textField = UITextField()
    private let doneButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Новая категория"
        view.backgroundColor = .systemBackground

        setupUI()
        layoutUI()
        updateButtonState()
    }

    // MARK: - Setup UI

    private func setupUI() {
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textField)

        doneButton.setTitle("Готово", for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        view.addSubview(doneButton)
    }

    // MARK: - Layout

    private func layoutUI() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75),

            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions

    @objc private func textDidChange() {
        updateButtonState()
    }

    private func updateButtonState() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let enabled = !text.isEmpty

        doneButton.isEnabled = enabled
        if enabled {
            doneButton.backgroundColor = UIColor(named: "BlackDay") ?? .black
            doneButton.setTitleColor(.white, for: .normal)
        } else {
            doneButton.backgroundColor = .systemGray4
            doneButton.setTitleColor(.white, for: .normal)
        }
    }

    @objc private func didTapDone() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }

        onSave?(text)
        navigationController?.popViewController(animated: true)
    }
}
