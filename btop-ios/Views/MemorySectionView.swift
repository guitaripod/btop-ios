import UIKit

final class MemorySectionView: UIView {

    private let header = SectionHeaderView(title: "MEMORY", accentColor: Theme.memActive)
    private let row1 = UILabel()
    private let row2 = UILabel()
    private let row3 = UILabel()
    private let bar = BarView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(with m: MemorySnapshot) {
        let color = Theme.color(forPercent: m.usagePercent)
        header.setValue(Formatters.percent(m.usagePercent), color: color)

        row1.attributedText = buildRow1(m)
        row2.attributedText = buildRow2(m)
        row3.attributedText = buildRow3(m)

        let total = max(Double(m.totalBytes), 1)
        let activePct = (Double(m.activeBytes) / total) * 100
        let wiredPct = (Double(m.wiredBytes) / total) * 100
        let compPct = (Double(m.compressedBytes) / total) * 100

        bar.update(
            segments: [
                BarView.Segment(value: activePct, color: Theme.memActive),
                BarView.Segment(value: wiredPct, color: Theme.memWired),
                BarView.Segment(value: compPct, color: Theme.memCompressed),
            ],
            trailingText: Formatters.percent(m.usagePercent),
            trailingColor: color
        )
    }

    private func setup() {
        backgroundColor = Theme.sectionBackground
        let labels = [row1, row2, row3]
        for l in labels {
            l.font = Theme.font
            l.numberOfLines = 1
        }

        let stack = UIStackView(arrangedSubviews: [header, row1, row2, row3, bar])
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

    private func buildRow1(_ m: MemorySnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(str(" Total ", Theme.label))
        s.append(str(Formatters.bytes(m.totalBytes), Theme.textPrimary))
        s.append(str("  Used ", Theme.label))
        s.append(str(Formatters.bytes(m.usedBytes), Theme.textPrimary))
        s.append(str("  Free ", Theme.label))
        s.append(str(Formatters.bytes(m.freeBytes), Theme.green))
        return s
    }

    private func buildRow2(_ m: MemorySnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(str(" Active ", Theme.label))
        s.append(str(Formatters.bytes(m.activeBytes), Theme.memActive))
        s.append(str("  Wired ", Theme.label))
        s.append(str(Formatters.bytes(m.wiredBytes), Theme.memWired))
        s.append(str("  Comp ", Theme.label))
        s.append(str(Formatters.bytes(m.compressedBytes), Theme.memCompressed))
        return s
    }

    private func buildRow3(_ m: MemorySnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(str(" Inactive ", Theme.label))
        s.append(str(Formatters.bytes(m.inactiveBytes), Theme.textSecondary))
        s.append(str("             App ", Theme.label))
        s.append(str(Formatters.bytesCompact(m.appFootprintBytes), Theme.textPrimary))
        return s
    }

    private func str(_ text: String, _ color: UIColor) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: Theme.font,
        ])
    }
}
