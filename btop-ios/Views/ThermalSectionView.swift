import UIKit

final class ThermalSectionView: UIView {

    private let header = SectionHeaderView(title: "THERMAL", accentColor: Theme.green)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(with t: ThermalSnapshot) {
        let color = Theme.color(forThermal: t.state)
        header.setValue(t.state.rawValue, color: color)
    }

    private func setup() {
        backgroundColor = Theme.sectionBackground

        let stack = UIStackView(arrangedSubviews: [header])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.padding),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.padding),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }
}
