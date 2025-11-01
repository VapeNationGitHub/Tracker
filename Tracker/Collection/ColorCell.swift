import UIKit

// MARK: - ColorCell

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(with color: UIColor, selected: Bool) {
        contentView.backgroundColor = color
        contentView.layer.borderColor = selected ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}
