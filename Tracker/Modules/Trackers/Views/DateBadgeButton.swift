import UIKit

// MARK: - DateBadgeButton

final class DateBadgeButton: UIButton {
    
    // MARK: - Private Properties
    
    /// Форматтер даты для отображения в кнопке
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "dd.MM.yy"
        return f
    }()
    
    // MARK: - Public Methods
    
    /// Устанавливает текст кнопки в виде даты
    func setDate(_ date: Date) {
        setTitle(formatter.string(from: date), for: .normal)
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    /// Настройка внешнего вида кнопки
    private func configureAppearance() {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 6, leading: 10, bottom: 6, trailing: 10)
        self.configuration = config
        
        setTitleColor(.label, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        layer.cornerRadius = 8
        backgroundColor = .secondarySystemBackground
    }
}
