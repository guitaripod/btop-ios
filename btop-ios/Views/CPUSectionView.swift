import UIKit

final class CPUSectionView: UIView {

    private let header = SectionHeaderView(title: "CPU", accentColor: Theme.cyan)
    private let row1 = UILabel()
    private let row2 = UILabel()
    private let bar = BarView()
    private let sparkline = SparklineView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func refreshGraphHeight() {
        sparkline.invalidateIntrinsicContentSize()
    }

    func update(with cpu: CPUSnapshot) {
        let color = Theme.color(forPercent: cpu.usagePercent)
        header.setValue(Formatters.percent(cpu.usagePercent), color: color)

        row1.attributedText = buildRow1(cpu)
        row2.attributedText = buildRow2(cpu)

        bar.update(
            segments: [BarView.Segment(value: cpu.usagePercent, color: color)],
            trailingText: Formatters.percent(cpu.usagePercent),
            trailingColor: color
        )

        sparkline.update(series: [
            SparklineView.Series(data: cpu.history, color: Theme.cyan, fillAlpha: 0.3),
        ])
    }

    private func setup() {
        backgroundColor = Theme.sectionBackground
        sparkline.setFixedMax(100)

        let labels = [row1, row2]
        for l in labels {
            l.font = Theme.font
            l.numberOfLines = 1
        }

        let stack = UIStackView(arrangedSubviews: [header, row1, row2, bar, sparkline])
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

    private func buildRow1(_ c: CPUSnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(str(" User ", Theme.label))
        s.append(str(Formatters.percent(c.userPercent), Theme.textPrimary))
        s.append(str("  System ", Theme.label))
        s.append(str(Formatters.percent(c.systemPercent), Theme.textPrimary))
        s.append(str("  Idle ", Theme.label))
        s.append(str(Formatters.percent(c.idlePercent), Theme.textSecondary))
        return s
    }

    private func buildRow2(_ c: CPUSnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(str(" Cores ", Theme.label))
        s.append(str("\(c.coreCount)", Theme.textPrimary))
        s.append(str("      Nice ", Theme.label))
        s.append(str(Formatters.percent(c.nicePercent), Theme.textSecondary))
        return s
    }

    private func str(_ text: String, _ color: UIColor) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: Theme.font,
        ])
    }
}
