// MARK: - ListRowView

import UIKit

final class ListRowView: UIControl {
    
    // MARK: - UI
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let separator = UIView()
    private let contentStack = UIStackView()
    
    // MARK: - Public Properties
    
    var text: String {
        get { titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }
    
    var showsSeparator: Bool = false {
        didSet { separator.isHidden = !showsSeparator }
    }
    
    // MARK: - Public Methods
    
    /// Показывает подзаголовок («Пн, Ср»)
    func setSubtitle(_ text: String?) {
        let s = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        subtitleLabel.text = s
        subtitleLabel.isHidden = s.isEmpty
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        self.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        // Заголовок
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .label
        
        // Подзаголовок
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.isHidden = true
        
        // Стрелочка
        chevronView.tintColor = .tertiaryLabel
        chevronView.setContentHuggingPriority(.required, for: .horizontal)
        
        // Разделитель
        separator.backgroundColor = .systemGray2
        separator.isHidden = true
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        // Stack с заголовком и подписью
        let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labels.axis = .vertical
        labels.alignment = .leading
        labels.spacing = 2
        labels.isUserInteractionEnabled = false
        
        // Горизонтальный стек
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 8
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(labels)
        contentStack.addArrangedSubview(chevronView)
        contentStack.isUserInteractionEnabled = false
        chevronView.isUserInteractionEnabled = false
        
        addSubview(contentStack)
        addSubview(separator)
        
        // MARK: - Layout
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 75),
            
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
