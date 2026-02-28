import UIKit

final class PageIndicatorView: UIView {

    var currentPage: Int = 0 { didSet { updateIndicators() } }

    private let bar0 = UIView()
    private let bar1 = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        let stack = UIStackView(arrangedSubviews: [bar0, bar1])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        for bar in [bar0, bar1] {
            bar.layer.cornerRadius = 1
            NSLayoutConstraint.activate([
                bar.widthAnchor.constraint(equalToConstant: 20),
                bar.heightAnchor.constraint(equalToConstant: 2),
            ])
        }

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 16),
        ])

        updateIndicators()
    }

    private func updateIndicators() {
        bar0.backgroundColor = currentPage == 0 ? Theme.cyan : Theme.border
        bar1.backgroundColor = currentPage == 1 ? Theme.cyan : Theme.border
    }
}
