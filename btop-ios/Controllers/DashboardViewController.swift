import UIKit

class DashboardViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let deviceSection = DeviceSectionView()
    private let cpuSection = CPUSectionView()
    private let memorySection = MemorySectionView()
    private let storageSection = StorageSectionView()
    private let networkSection = NetworkSectionView()
    private let batterySection = BatterySectionView()
    private let thermalSection = ThermalSectionView()
    private let processSection = ProcessSectionView()

    private let collector = SystemCollector()

    private lazy var sectionMap: [(Settings.Section, UIView)] = [
        (.device, deviceSection),
        (.cpu, cpuSection),
        (.memory, memorySection),
        (.storage, storageSection),
        (.network, networkSection),
        (.battery, batterySection),
        (.thermal, thermalSection),
        (.process, processSection),
    ]

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        view.accessibilityIdentifier = "dashboardView"
        setupScrollView()
        setupStackView()
        addSections()
        applySectionVisibility()
    }

    func startPolling() {
        collector.start(interval: Settings.shared.refreshRate.rawValue) { [weak self] snapshot in
            self?.update(with: snapshot)
        }
    }

    func applySettings() {
        collector.stop()
        collector.start(interval: Settings.shared.refreshRate.rawValue) { [weak self] snapshot in
            self?.update(with: snapshot)
        }

        applySectionVisibility()

        cpuSection.refreshGraphHeight()
        networkSection.refreshGraphHeight()

        UIApplication.shared.isIdleTimerDisabled = Settings.shared.keepScreenOn
    }

    private func applySectionVisibility() {
        for (section, sectionView) in sectionMap {
            sectionView.isHidden = !Settings.shared.isSectionVisible(section)
        }
    }

    func stopPolling() {
        collector.stop()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let top = view.safeAreaInsets.top
        let bottom = view.safeAreaInsets.bottom
        scrollView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom + 8, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    private func addSections() {
        let sections: [UIView] = [
            deviceSection, cpuSection, memorySection, storageSection,
            networkSection, batterySection, thermalSection, processSection,
        ]
        for section in sections {
            stackView.addArrangedSubview(section)
        }
    }

    private func update(with snapshot: SystemSnapshot) {
        deviceSection.update(with: snapshot.device)
        cpuSection.update(with: snapshot.cpu)
        memorySection.update(with: snapshot.memory)
        storageSection.update(with: snapshot.storage)
        networkSection.update(with: snapshot.network)
        batterySection.update(with: snapshot.battery)
        thermalSection.update(with: snapshot.thermal)
        processSection.update(with: snapshot.process)
        ActivityManager.shared.update(with: snapshot)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        collector.trimHistory()
    }
}
