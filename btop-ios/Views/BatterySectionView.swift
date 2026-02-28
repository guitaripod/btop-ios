import UIKit

final class BatterySectionView: UIView {

    private let header = SectionHeaderView(title: "BATTERY", accentColor: Theme.green)
    private let bar = BarView()
    private let simLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(with b: BatterySnapshot) {
        if b.isSimulator || b.level < 0 {
            header.setValue("N/A", color: Theme.textSecondary)
            bar.isHidden = true
            simLabel.isHidden = false
            simLabel.attributedText = str(" Simulator — Battery unavailable", Theme.textSecondary)
            return
        }

        let pct = Double(b.level * 100)
        let color = Theme.color(forBattery: b.level)
        let stateStr = b.state.rawValue

        header.setValue("\(Int(pct))%  \(stateStr)", color: color)

        bar.isHidden = false
        simLabel.isHidden = true
        bar.update(
            segments: [BarView.Segment(value: pct, color: color)],
            trailingText: "\(Int(pct))%",
            trailingColor: color
        )
    }

    private func setup() {
        backgroundColor = Theme.sectionBackground
        simLabel.font = Theme.font
        simLabel.numberOfLines = 1
        simLabel.isHidden = true

        let stack = UIStackView(arrangedSubviews: [header, bar, simLabel])
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

    private func str(_ text: String, _ color: UIColor) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: Theme.font,
        ])
    }
}
