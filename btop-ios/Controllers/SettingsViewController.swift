import UIKit

class SettingsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let settings = Settings.shared

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        view.accessibilityIdentifier = "settingsView"
        setupScrollView()
        setupStackView()
        buildContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let top = view.safeAreaInsets.top
        let bottom = view.safeAreaInsets.bottom
        scrollView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom + 8, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = Theme.background
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = Theme.sectionSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }

    private func buildContent() {
        addSection(title: "SETTINGS", accentColor: Theme.cyan, content: [])

        addSection(title: "REFRESH RATE", accentColor: Theme.cyan, content: [
            makeRefreshRateControl(),
        ])

        addSection(title: "DISPLAY", accentColor: Theme.blue, content: [
            makeKeepScreenOnToggle(),
        ])

        addSection(title: "GRAPHS", accentColor: Theme.green, content: [
            makeGraphHeightControl(),
        ])

        addSection(title: "SECTIONS", accentColor: Theme.yellow, content: [
            makeSectionToggles(),
        ])

        addSection(title: "ABOUT", accentColor: Theme.textSecondary, content: [
            makeAboutRow(),
        ])
    }

    private func addSection(title: String, accentColor: UIColor, content: [UIView]) {
        let container = UIView()
        container.backgroundColor = Theme.sectionBackground

        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 2
        inner.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(inner)

        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            inner.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Theme.padding),
            inner.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Theme.padding),
            inner.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
        ])

        let header = SectionHeaderView(title: title, accentColor: accentColor)
        inner.addArrangedSubview(header)

        for v in content {
            inner.addArrangedSubview(v)
        }

        stackView.addArrangedSubview(container)
    }

    private func makeRefreshRateControl() -> UIView {
        let options = Settings.RefreshRate.allCases.map { $0.label }
        let current = Settings.RefreshRate.allCases.firstIndex(of: settings.refreshRate) ?? 3
        let seg = SegmentedRowView(options: options, selectedIndex: current)
        seg.onSelect = { [weak self] idx in
            self?.settings.refreshRate = Settings.RefreshRate.allCases[idx]
        }
        return seg
    }

    private func makeKeepScreenOnToggle() -> UIView {
        let toggle = ToggleRowView(title: "Keep Screen On", isOn: settings.keepScreenOn)
        toggle.onToggle = { [weak self] on in
            self?.settings.keepScreenOn = on
            UIApplication.shared.isIdleTimerDisabled = on
        }
        return toggle
    }

    private func makeGraphHeightControl() -> UIView {
        let options = Settings.GraphHeight.allCases.map { $0.label }
        let current = Settings.GraphHeight.allCases.firstIndex(of: settings.graphHeight) ?? 1
        let seg = SegmentedRowView(options: options, selectedIndex: current)
        seg.onSelect = { [weak self] idx in
            self?.settings.graphHeight = Settings.GraphHeight.allCases[idx]
        }
        return seg
    }

    private func makeSectionToggles() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 0

        for section in Settings.Section.allCases {
            let toggle = ToggleRowView(title: section.label, isOn: settings.isSectionVisible(section))
            toggle.onToggle = { [weak self] on in
                self?.settings.setSectionVisible(section, visible: on)
            }
            container.addArrangedSubview(toggle)
        }

        return container
    }

    private func makeAboutRow() -> UIView {
        let label = UILabel()
        label.font = Theme.font

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

        let s = NSMutableAttributedString()
        s.append(NSAttributedString(string: " btop-ios", attributes: [
            .foregroundColor: Theme.textPrimary,
            .font: Theme.fontBold,
        ]))
        s.append(NSAttributedString(string: " ", attributes: [
            .foregroundColor: UIColor.clear,
            .font: Theme.font,
        ]))

        let right = UILabel()
        right.font = Theme.font
        right.textColor = Theme.textSecondary
        right.text = "v\(version) (\(build)) "
        right.textAlignment = .right

        let row = UIStackView(arrangedSubviews: [label, right])
        row.axis = .horizontal

        label.attributedText = s

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: Theme.rowHeight + 8),
        ])

        return row
    }
}
