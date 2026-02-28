import UIKit

final class DeviceSectionView: UIView {

    private let header = SectionHeaderView(title: "DEVICE", accentColor: Theme.blue)
    private let row1 = UILabel()
    private let row2 = UILabel()
    private let row3 = UILabel()
    private let row4 = UILabel()
    private let row5 = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(with d: DeviceSnapshot) {
        row1.attributedText = buildRow1(d)
        row2.attributedText = buildRow2(d)
        row3.attributedText = buildRow3(d)
        row4.attributedText = buildRow4(d)
        row5.attributedText = buildRow5(d)
    }

    private func setup() {
        backgroundColor = Theme.sectionBackground
        let labels = [row1, row2, row3, row4, row5]
        for l in labels {
            l.font = Theme.font
            l.numberOfLines = 1
        }

        let stack = UIStackView(arrangedSubviews: [header] + labels)
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

    private func buildRow1(_ d: DeviceSnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(str(" \(d.modelName)", Theme.textPrimary, Theme.fontBold))
        s.append(str(" (\(d.modelIdentifier))", Theme.textSecondary))
        let pad = "     "
        s.append(str("\(pad)\(d.osVersion)", Theme.cyan))
        return s
    }

    private func buildRow2(_ d: DeviceSnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(str(" \(d.deviceName)", Theme.textPrimary))
        let time = Formatters.time(d.currentTime)
        s.append(str("  \(time)", Theme.textSecondary))
        return s
    }

    private func buildRow3(_ d: DeviceSnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(str(" Uptime ", Theme.label))
        s.append(str(Formatters.uptime(d.uptimeSeconds), Theme.textPrimary))
        s.append(str("  Display ", Theme.label))
        s.append(str("\(d.maxFPS)Hz", Theme.textPrimary))
        s.append(str(" @\(d.screenScale)x", Theme.textSecondary))
        return s
    }

    private func buildRow4(_ d: DeviceSnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        let pct = Int(d.brightness * 100)
        s.append(str(" Bright ", Theme.label))
        s.append(str("\(pct)%", Theme.textPrimary))
        s.append(str("  Low Power ", Theme.label))
        s.append(str(d.isLowPowerMode ? "On" : "Off", d.isLowPowerMode ? Theme.yellow : Theme.green))
        s.append(str("  \(d.biometricType)", Theme.textSecondary))
        return s
    }

    private func buildRow5(_ d: DeviceSnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(str(" \(d.locale)", Theme.textSecondary))
        s.append(str("  \(d.timeZone)", Theme.textSecondary))
        return s
    }

    private func str(_ text: String, _ color: UIColor, _ font: UIFont? = nil) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: font ?? Theme.font,
        ])
    }
}
