import UIKit

final class StatisticsCardView: UIView {

    private let gradientBorderLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(hex: "#1A1B22")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(hex: "#1A1B22")
        label.numberOfLines = 1

        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 18
        paragraph.maximumLineHeight = 18

        label.attributedText = NSAttributedString(
            string: NSLocalizedString("stats_completed", comment: ""),
            attributes: [
                .paragraphStyle: paragraph
            ]
        )

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(count: Int, title: String) {
        super.init(frame: .zero)
        setup()
        configure(count: count, title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(count: Int, title: String) {
        countLabel.text = "\(count)"
        titleLabel.text = title
    }

    private func setup() {
        backgroundColor = .clear
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false

        addGradientBorder()

        addSubview(countLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            titleLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: countLabel.leadingAnchor)
        ])
    }

    private func addGradientBorder() {
        gradientBorderLayer.colors = [
            UIColor(hex: "#007BFA").cgColor,
            UIColor(hex: "#46E69D").cgColor,
            UIColor(hex: "#FD4C49").cgColor
        ]
        gradientBorderLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderLayer.frame = bounds
        gradientBorderLayer.cornerRadius = 16
        gradientBorderLayer.masksToBounds = true

        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: 16
        ).cgPath

        gradientBorderLayer.mask = shapeLayer
        layer.addSublayer(gradientBorderLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorderLayer.frame = bounds
        shapeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: 16
        ).cgPath
    }
}
