import UIKit

// MARK: - ScheduleCell

final class ScheduleCell: UITableViewCell {
    
    private var toggleAction: ((Bool) -> Void)?
    
    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with day: WeekDay, isOn: Bool, toggleAction: @escaping (Bool) -> Void) {
        titleLabel.text = day.shortName
        toggleSwitch.isOn = isOn
        self.toggleAction = toggleAction
    }
    
    @objc private func switchChanged() {
        toggleAction?(toggleSwitch.isOn)
    }
}
