import UIKit

// MARK: - CategoryContextMenu

final class CategoryContextMenu: UIView {

    // MARK: - Public Callbacks

    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    // MARK: - UI Elements

    private let stack = UIStackView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.masksToBounds = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)

        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Добавляем кнопки
        addMenuButton(
            title: "Редактировать",
            color: .label,
            action: { [weak self] in self?.onEdit?() }
        )

        addSeparator()

        addMenuButton(
            title: "Удалить",
            color: .systemRed,
            action: { [weak self] in self?.onDelete?() }
        )
    }

    // MARK: - Button Builder

    private func addMenuButton(
        title: String,
        color: UIColor,
        action: @escaping () -> Void
    ) {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(color, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        btn.backgroundColor = .white
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true

        btn.addAction(UIAction { _ in action() }, for: .touchUpInside)
        stack.addArrangedSubview(btn)
    }

    private func addSeparator() {
        let sep = UIView()
        sep.backgroundColor = UIColor.separator.withAlphaComponent(0.25)
        sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stack.addArrangedSubview(sep)
    }
}
