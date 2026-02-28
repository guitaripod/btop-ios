import UIKit

final class SectionHeaderView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let lineLayer = CAShapeLayer()
    private let accentColor: UIColor

    init(title: String, accentColor: UIColor) {
        self.accentColor = accentColor
        super.init(frame: .zero)
        setup(title: title)
    }

    required init?(coder: NSCoder) { fatalError() }

    func setValue(_ text: String?, color: UIColor? = nil) {
        valueLabel.text = text.map { " \($0) " }
        valueLabel.textColor = color ?? Theme.textPrimary
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLine()
    }

    private func setup(title: String) {
        lineLayer.strokeColor = Theme.border.cgColor
        lineLayer.lineWidth = 1
        lineLayer.lineDashPattern = [3, 2]
        lineLayer.fillColor = nil
        lineLayer.actions = ["path": NSNull()]
        layer.addSublayer(lineLayer)

        titleLabel.text = " \(title) "
        titleLabel.font = Theme.fontHeader
        titleLabel.textColor = accentColor
        titleLabel.backgroundColor = Theme.sectionBackground
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        valueLabel.font = Theme.fontBold
        valueLabel.textColor = Theme.textPrimary
        valueLabel.textAlignment = .right
        valueLabel.backgroundColor = Theme.sectionBackground
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 4),

            heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    private func updateLine() {
        let y = bounds.midY
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: bounds.width, y: y))
        lineLayer.path = path
        lineLayer.frame = bounds
    }
}
