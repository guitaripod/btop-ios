import UIKit

final class ProcessSectionView: UIView {

    private let header = SectionHeaderView(title: "PROCESS (self)", accentColor: Theme.cyan)
    private let row1 = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(with p: ProcessSnapshot) {
        row1.attributedText = buildRow(p)
    }

    private func setup() {
        backgroundColor = Theme.sectionBackground
        row1.font = Theme.font
        row1.numberOfLines = 1

        let stack = UIStackView(arrangedSubviews: [header, row1])
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

    private func buildRow(_ p: ProcessSnapshot) -> NSAttributedString {
        let s = NSMutableAttributedString()
        s.append(str(" Threads ", Theme.label))
        s.append(str(String(format: "%2d", p.threadCount), Theme.textPrimary))
        s.append(str("   CPU ", Theme.label))
        s.append(str(Formatters.percent(p.cpuUsage), Theme.cyan))
        s.append(str("   Mem ", Theme.label))
        s.append(str(Formatters.bytesCompact(p.memoryFootprint), Theme.textPrimary))
        return s
    }

    private func str(_ text: String, _ color: UIColor) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: Theme.font,
        ])
    }
}
