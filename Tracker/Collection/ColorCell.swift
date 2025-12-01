import UIKit

final class ColorCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ColorCell"
    
    // MARK: - UI
    
    /// «ореол» вокруг выбранного цвета
    private let selectionBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Рамка
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Внутренний квадрат
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(selectionBackgroundView)
        selectionBackgroundView.addSubview(borderView)
        borderView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            // item
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: 52),
            selectionBackgroundView.heightAnchor.constraint(equalToConstant: 52),
            selectionBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // рамка
            borderView.widthAnchor.constraint(equalToConstant: 46),
            borderView.heightAnchor.constraint(equalToConstant: 46),
            borderView.centerXAnchor.constraint(equalTo: selectionBackgroundView.centerXAnchor),
            borderView.centerYAnchor.constraint(equalTo: selectionBackgroundView.centerYAnchor),
            
            colorView.widthAnchor.constraint(equalToConstant: 36),
            colorView.heightAnchor.constraint(equalToConstant: 36),
            colorView.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionBackgroundView.backgroundColor = .clear
        borderView.backgroundColor = .clear
        borderView.layer.borderWidth = 0
        borderView.layer.borderColor = nil
        colorView.backgroundColor = nil
    }
    
    // MARK: - Configure
    
    func configure(with color: UIColor, selected: Bool) {
        colorView.backgroundColor = color
        
        if selected {
            // рамка 46x46, 3pt, цветом квадрата
            borderView.backgroundColor = .clear
            borderView.layer.borderWidth = 3
            borderView.layer.borderColor = color.cgColor
        } else {
            selectionBackgroundView.backgroundColor = .clear
            borderView.backgroundColor = .clear
            borderView.layer.borderWidth = 0
            borderView.layer.borderColor = nil
        }
    }
}
