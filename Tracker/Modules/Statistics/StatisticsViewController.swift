import UIKit

// MARK: - StatisticsViewController

final class StatisticsViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPlaceholder()
    }
    
    // MARK: - Private Methods
    
    /// Настройка базового UI
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Статистика"
    }
    
    /// Добавление временного текста-заглушки
    private func setupPlaceholder() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Здесь появится статистика"
        label.textColor = .secondaryLabel
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
