import UIKit

final class StorageSectionView: UIView {

    private let header = SectionHeaderView(title: "STORAGE", accentColor: Theme.blue)
    private let row1 = UILabel()
    private let bar = BarView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(with s: StorageSnapshot) {
        let color = Theme.color(forPercent: s.usagePercent)
        header.setValue(Formatters.percent(s.usagePercent), color: color)

        row1.attributedText = buildRow(s)

        bar.update(
            segments: [BarView.Segment(value: s.usagePercent, color: color)],
            trailingText: Formatters.percent(s.usagePercent),
            trailingColor: color
        )
    }

    private func setup() {
        backgroundColor = Theme.sectionBackground
        row1.font = Theme.font
        row1.numberOfLines = 1

        let stack = UIStackView(arrangedSubviews: [header, row1, bar])
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

    private func buildRow(_ s: StorageSnapshot) -> NSAttributedString {
        let a = NSMutableAttributedString()
        a.append(str(" Total ", Theme.label))
        a.append(str(Formatters.bytes(s.totalBytes), Theme.textPrimary))
        a.append(str("  Used ", Theme.label))
        a.append(str(Formatters.bytes(s.usedBytes), Theme.textPrimary))
        a.append(str("  Free ", Theme.label))
        a.append(str(Formatters.bytes(s.availableBytes), Theme.green))
        return a
    }

    private func str(_ text: String, _ color: UIColor) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: Theme.font,
        ])
    }
}
