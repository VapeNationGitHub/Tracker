import UIKit

// MARK: - Протокол делегата ячейки

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapComplete(_ cell: TrackerCell)
}

// MARK: - Ячейка коллекции для трекера

final class TrackerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backgroundCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var isCompleted: Bool = false
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: frame.width)
        ])
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int) {
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        counterLabel.text = "Дней: \(completedDays)"
        backgroundCardView.backgroundColor = tracker.color
        self.isCompleted = isCompleted
        
        let imageName = isCompleted ? "checkmark" : "plus"
        plusButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        if isCompleted {
            plusButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
            plusButton.tintColor = tracker.color
        } else {
            plusButton.backgroundColor = tracker.color
            plusButton.tintColor = .white
        }
        
    }
    
    // MARK: - Private
    
    @objc private func plusButtonTapped() {
        delegate?.trackerCellDidTapComplete(self)
    }
    
    private func setupLayout() {
        contentView.addSubview(backgroundCardView)
        backgroundCardView.addSubview(emojiLabel)
        backgroundCardView.addSubview(nameLabel)
        contentView.addSubview(counterLabel)
        contentView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundCardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundCardView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            backgroundCardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: -12),
            
            counterLabel.topAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            plusButton.centerYAnchor.constraint(equalTo: counterLabel.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
