import UIKit

// MARK: - EmojiCell

final class EmojiCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"
    
    // MARK: - UI
    private let emojiLabel = UILabel()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        emojiLabel.font = .systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
    }
    
    // MARK: - Configure
    func configure(with emoji: String, selected: Bool) {
        emojiLabel.text = emoji
        contentView.backgroundColor = selected ? UIColor.systemGray5 : .clear
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
