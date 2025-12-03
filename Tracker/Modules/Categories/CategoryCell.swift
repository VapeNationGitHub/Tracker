import UIKit

// MARK: - CategoryCell

final class CategoryCell: UITableViewCell {

    // MARK: - UI

    private let separator = UIView()
    private let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        textLabel?.font = .systemFont(ofSize: 17)
        textLabel?.textColor = UIColor(named: "BlackDay") ?? .label

        checkmark.tintColor = .systemBlue
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkmark)

        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.3)
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([
            checkmark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Configure

    func configure(with title: String, selected: Bool, isLast: Bool) {
        textLabel?.text = title
        checkmark.isHidden = !selected
        separator.isHidden = isLast
    }
}
