import UIKit

final class FilterCell: UITableViewCell {

    static let reuseID = "FilterCell"

    // MARK: - UI
    private let titleLabel = UILabel()
    private let separator = UIView()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .secondarySystemBackground
        contentView.backgroundColor = .secondarySystemBackground

        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configure(title: String, isSelected: Bool, isLast: Bool) {
        titleLabel.text = title
        accessoryType = isSelected ? .checkmark : .none
        tintColor = .systemBlue

        separator.isHidden = isLast
    }

    // MARK: - Setup
    private func setupUI() {

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIColor.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        separator.backgroundColor = UIColor.systemGray3
        separator.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(separator)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),

            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
