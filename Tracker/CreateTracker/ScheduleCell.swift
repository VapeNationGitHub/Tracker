// MARK: - ScheduleCell

import UIKit

final class ScheduleCell: UITableViewCell {
    
    // MARK: - Static
    static let reuseID = "ScheduleCell"
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    private let separator = UIView()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .secondarySystemBackground
        
        // Название дня недели
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Тумблер (UISwitch)
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.onTintColor = .systemBlue
        
        // Разделитель
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.35)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем на экран
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        contentView.addSubview(separator)
    }
    
    // MARK: - Layout
    private func layoutUI() {
        NSLayoutConstraint.activate([
            // Название
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Тумблер
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Разделитель снизу
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
    }
    
    // MARK: - Configuration
    /// Настраивает ячейку с заголовком, состоянием тумблера, видимостью разделителя и обработчиком переключения
    func configure(title: String,
                   isOn: Bool,
                   showSeparator: Bool,
                   toggleTag: Int,
                   toggleTarget: Any,
                   toggleAction: Selector) {
        titleLabel.text = title
        toggleSwitch.isOn = isOn
        toggleSwitch.tag = toggleTag
        
        // Обновляем цель/действие для переключателя
        toggleSwitch.removeTarget(nil, action: nil, for: .allEvents)
        toggleSwitch.addTarget(toggleTarget, action: toggleAction, for: .valueChanged)
        
        separator.isHidden = !showSeparator
    }
}
