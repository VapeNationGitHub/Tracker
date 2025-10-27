import UIKit

final class ListRowViewView: UIControl {
    private let titleLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let separator = UIView()

    var text: String {
        get { titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }

    var showsSeparator: Bool = false {
        didSet { separator.isHidden = !showsSeparator }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    convenience init(title: String) {
        self.init(frame: .zero)
        self.text = title
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        chevronView.tintColor = .tertiaryLabel
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.setContentHuggingPriority(.required, for: .horizontal)

        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.5)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.isHidden = true

        addSubview(titleLabel)
        addSubview(chevronView)
        addSubview(separator)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
