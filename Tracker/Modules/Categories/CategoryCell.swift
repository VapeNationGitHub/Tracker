import UIKit

// MARK: - CategoryCell

final class CategoryCell: UITableViewCell {
    
    // MARK: - UI
    
    private let backgroundContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Название категории
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor(resource: .blackDay)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Галочка выбранной категории
    private let checkmark: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    /// Разделитель между ячейками
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.separator.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        layoutUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(backgroundContainer)
        backgroundContainer.addSubview(titleLabel)
        backgroundContainer.addSubview(checkmark)
        backgroundContainer.addSubview(separator)
    }
    
    // MARK: - Layout
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            // Подложка
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            backgroundContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Метка
            titleLabel.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: backgroundContainer.centerYAnchor),
            
            // Галочка
            checkmark.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor, constant: -16),
            checkmark.centerYAnchor.constraint(equalTo: backgroundContainer.centerYAnchor),
            
            // Разделитель
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: backgroundContainer.bottomAnchor)
        ])
    }
    
    // MARK: - Configure
    
    /// Настройка содержимого ячейки
    func configure(with title: String, selected: Bool, isLast: Bool) {
        titleLabel.text = title
        checkmark.isHidden = !selected
        separator.isHidden = isLast
    }
}
