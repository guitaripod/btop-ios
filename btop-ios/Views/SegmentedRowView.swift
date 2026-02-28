import UIKit

final class SegmentedRowView: UIView {

    var selectedIndex: Int = 0 { didSet { updateDisplay() } }
    var onSelect: ((Int) -> Void)?

    private var buttons: [UIButton] = []
    private let stack = UIStackView()

    init(options: [String], selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        super.init(frame: .zero)
        setup(options: options)
        updateDisplay()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup(options: [String]) {
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        for (i, title) in options.enumerated() {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = Theme.fontBold
            btn.setTitle("  \(title)  ", for: .normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
            btn.contentHorizontalAlignment = .center
            buttons.append(btn)
            stack.addArrangedSubview(btn)
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: Theme.rowHeight + 12),
        ])
    }

    @objc private func segmentTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        onSelect?(selectedIndex)
    }

    private func updateDisplay() {
        for (i, btn) in buttons.enumerated() {
            let title = btn.title(for: .normal)?.trimmingCharacters(in: .whitespaces) ?? ""
            if i == selectedIndex {
                btn.setTitle(" [\(title)] ", for: .normal)
                btn.setTitleColor(Theme.cyan, for: .normal)
            } else {
                btn.setTitle("  \(title)  ", for: .normal)
                btn.setTitleColor(Theme.textSecondary, for: .normal)
            }
        }
    }
}
