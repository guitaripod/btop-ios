import UIKit

final class ToggleRowView: UIView {

    var isOn: Bool = true { didSet { updateDisplay() } }
    var onToggle: ((Bool) -> Void)?

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    init(title: String, isOn: Bool) {
        self.isOn = isOn
        super.init(frame: .zero)
        setup(title: title)
        updateDisplay()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup(title: String) {
        titleLabel.text = " \(title)"
        titleLabel.font = Theme.font
        titleLabel.textColor = Theme.textPrimary

        valueLabel.font = Theme.fontBold
        valueLabel.textAlignment = .right

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: Theme.rowHeight + 8),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @objc private func tapped() {
        isOn.toggle()
        onToggle?(isOn)
    }

    private func updateDisplay() {
        if isOn {
            valueLabel.text = "[ON] "
            valueLabel.textColor = Theme.green
        } else {
            valueLabel.text = "[OFF] "
            valueLabel.textColor = Theme.textSecondary
        }
    }
}
