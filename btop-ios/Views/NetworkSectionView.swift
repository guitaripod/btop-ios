import UIKit

final class NetworkSectionView: UIView {

    private let header = SectionHeaderView(title: "NETWORK", accentColor: Theme.netIn)
    private let contentStack = UIStackView()
    private var interfaceViews: [String: InterfaceRowGroup] = [:]
    private var currentOrder: [String] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(with net: NetworkSnapshot) {
        let newOrder = net.interfaces.map { $0.name }

        if net.interfaces.isEmpty {
            hideAllInterfaces()
            ensureEmptyLabel()
            return
        }

        removeEmptyLabel()

        if newOrder != currentOrder {
            rebuildLayout(interfaces: net.interfaces)
        }

        for iface in net.interfaces {
            if let group = interfaceViews[iface.name] {
                updateGroup(group, with: iface)
            }
        }

        currentOrder = newOrder
    }

    private func setup() {
        backgroundColor = Theme.sectionBackground

        contentStack.axis = .vertical
        contentStack.spacing = 2

        let outer = UIStackView(arrangedSubviews: [header, contentStack])
        outer.axis = .vertical
        outer.spacing = 2
        outer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outer)

        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            outer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.padding),
            outer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.padding),
            outer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }

    private func rebuildLayout(interfaces: [InterfaceSnapshot]) {
        for v in contentStack.arrangedSubviews {
            contentStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        for iface in interfaces {
            let group: InterfaceRowGroup
            if let existing = interfaceViews[iface.name] {
                group = existing
            } else {
                group = InterfaceRowGroup()
                interfaceViews[iface.name] = group
            }

            contentStack.addArrangedSubview(group.nameLabel)
            contentStack.addArrangedSubview(group.rateLabel)
            contentStack.addArrangedSubview(group.totalLabel)
            contentStack.addArrangedSubview(group.sparkline)
        }

        for key in interfaceViews.keys where !interfaces.contains(where: { $0.name == key }) {
            let group = interfaceViews.removeValue(forKey: key)
            group?.nameLabel.removeFromSuperview()
            group?.rateLabel.removeFromSuperview()
            group?.totalLabel.removeFromSuperview()
            group?.sparkline.removeFromSuperview()
        }
    }

    private func updateGroup(_ group: InterfaceRowGroup, with iface: InterfaceSnapshot) {
        let nameStr = NSMutableAttributedString()
        nameStr.append(str(" \(iface.displayName)", Theme.textPrimary, Theme.fontBold))
        nameStr.append(str(" (\(iface.name))", Theme.textSecondary))
        if let ip = iface.ipv4Address {
            nameStr.append(str(" \(ip)", Theme.blue))
        }
        group.nameLabel.attributedText = nameStr

        let rateStr = NSMutableAttributedString()
        rateStr.append(str("  \u{25BC} ", Theme.netIn))
        rateStr.append(str(Formatters.rate(iface.rateIn), Theme.netIn))
        rateStr.append(str("  \u{25B2} ", Theme.netOut))
        rateStr.append(str(Formatters.rate(iface.rateOut), Theme.netOut))
        group.rateLabel.attributedText = rateStr

        let hasCumulative = iface.cumulativeIn > 0 || iface.cumulativeOut > 0
        group.totalLabel.isHidden = !hasCumulative
        if hasCumulative {
            let totalStr = NSMutableAttributedString()
            totalStr.append(str("  Total ", Theme.label))
            totalStr.append(str("\u{25BC} ", Theme.netIn))
            totalStr.append(str(Formatters.bytesCompact(iface.cumulativeIn), Theme.textSecondary))
            totalStr.append(str("  \u{25B2} ", Theme.netOut))
            totalStr.append(str(Formatters.bytesCompact(iface.cumulativeOut), Theme.textSecondary))
            group.totalLabel.attributedText = totalStr
        }

        let hasRecentActivity = iface.historyIn.contains { $0 > 0 } || iface.historyOut.contains { $0 > 0 }
        group.sparkline.isHidden = !hasRecentActivity
        if hasRecentActivity {
            group.sparkline.update(series: [
                SparklineView.Series(data: iface.historyIn, color: Theme.netIn, fillAlpha: 0.2),
                SparklineView.Series(data: iface.historyOut, color: Theme.netOut, fillAlpha: 0.2),
            ])
        }
    }

    private var emptyLabel: UILabel?

    private func ensureEmptyLabel() {
        if emptyLabel == nil {
            let l = makeLabel()
            l.attributedText = str(" No active interfaces", Theme.textSecondary)
            emptyLabel = l
        }
        if emptyLabel?.superview == nil {
            contentStack.addArrangedSubview(emptyLabel!)
        }
    }

    private func removeEmptyLabel() {
        emptyLabel?.removeFromSuperview()
    }

    private func hideAllInterfaces() {
        for v in contentStack.arrangedSubviews where v !== emptyLabel {
            contentStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
    }

    private func makeLabel() -> UILabel {
        let l = UILabel()
        l.font = Theme.font
        l.numberOfLines = 1
        return l
    }

    private func str(_ text: String, _ color: UIColor, _ font: UIFont? = nil) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: font ?? Theme.font,
        ])
    }
}

private final class InterfaceRowGroup {
    let nameLabel = UILabel()
    let rateLabel = UILabel()
    let totalLabel = UILabel()
    let sparkline = SparklineView()

    init() {
        for l in [nameLabel, rateLabel, totalLabel] {
            l.font = Theme.font
            l.numberOfLines = 1
        }
    }
}
