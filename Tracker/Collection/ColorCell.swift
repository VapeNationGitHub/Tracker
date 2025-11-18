import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    // внутренний цветной квадрат 40×40
    private let colorView = UIView()
    // внешнее кольцо выбора 46×46 (обводка 3pt)
    private let ringView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        // кольцо (по умолчанию скрыто)
        ringView.backgroundColor = .clear
        ringView.layer.cornerRadius = 8
        ringView.layer.masksToBounds = true
        ringView.layer.borderWidth = 0  // только когда selected - показывается
        
        // сам цвет
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        
        contentView.addSubview(ringView)
        contentView.addSubview(colorView)
    }
    
    private func setupConstraints() {
        ringView.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        // размер кольца 46×46
        NSLayoutConstraint.activate([
            ringView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ringView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ringView.topAnchor.constraint(equalTo: contentView.topAnchor),
            ringView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // внутренний квадрат 40×40
            colorView.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: ringView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Public
    
    func configure(with color: UIColor, selected: Bool) {
        colorView.backgroundColor = color
        
        if selected {
            ringView.layer.borderColor = color.withAlphaComponent(0.3).cgColor // 30%
            ringView.layer.borderWidth = 3                                    // 3pt
        } else {
            ringView.layer.borderWidth = 0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ringView.layer.borderWidth = 0
    }
}
