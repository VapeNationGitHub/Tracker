import UIKit

// MARK: - EmptyStateView

final class EmptyStateView: UIView {
    
    // MARK: - UI Elements
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    // MARK: - Initializers
    
    init(image: UIImage?, title: String) {
        super.init(frame: .zero)
        setup(image: image, title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public API
    func configure(image: UIImage?, title: String) {
        imageView.image = image
        titleLabel.text = title
    }
    
    // MARK: - Private Methods
    
    /// Настройка внешнего вида и расположения элементов
    private func setup(image: UIImage?, title: String) {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка изображения
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = image ?? UIImage(systemName: "star")
        
        // Настройка текста
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        
        // Добавляем элементы в иерархию
        addSubview(imageView)
        addSubview(titleLabel)
        
        // Устанавливаем констрейнты
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
    }
}
