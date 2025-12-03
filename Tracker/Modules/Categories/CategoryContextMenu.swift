import UIKit

final class CategoryContextMenu: UIView {

    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)

        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addButton("Редактировать", color: .black) { [weak self] in self?.onEdit?() }
        addButton("Удалить", color: .red) { [weak self] in self?.onDelete?() }
    }

    private func addButton(_ title: String, color: UIColor, action: @escaping () -> Void) {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(color, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17)
        btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        btn.addAction(UIAction { _ in action() }, for: .touchUpInside)

        stack.addArrangedSubview(btn)
    }
}
