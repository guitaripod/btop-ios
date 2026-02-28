import UIKit

class RootContainerViewController: UIViewController, UIScrollViewDelegate {

    let dashboard = DashboardViewController()
    private let settingsVC = SettingsViewController()
    private let pagingScrollView = UIScrollView()
    private let pageIndicator = PageIndicatorView()

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var childForStatusBarStyle: UIViewController? { dashboard }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background

        setupPagingScrollView()
        setupChildViewControllers()
        setupPageIndicator()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let w = view.bounds.width
        let h = view.bounds.height

        pagingScrollView.frame = CGRect(x: 0, y: 0, width: w, height: h)
        pagingScrollView.contentSize = CGSize(width: w * 2, height: h)

        dashboard.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        settingsVC.view.frame = CGRect(x: w, y: 0, width: w, height: h)

        let indicatorH: CGFloat = 16
        let bottom = view.safeAreaInsets.bottom
        pageIndicator.frame = CGRect(x: 0, y: h - bottom - indicatorH, width: w, height: indicatorH)
    }

    private func setupPagingScrollView() {
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.bounces = false
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.showsVerticalScrollIndicator = false
        pagingScrollView.delegate = self
        pagingScrollView.backgroundColor = Theme.background
        view.addSubview(pagingScrollView)
    }

    private func setupChildViewControllers() {
        addChild(dashboard)
        pagingScrollView.addSubview(dashboard.view)
        dashboard.didMove(toParent: self)

        addChild(settingsVC)
        pagingScrollView.addSubview(settingsVC.view)
        settingsVC.didMove(toParent: self)
    }

    private func setupPageIndicator() {
        view.addSubview(pageIndicator)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        pageIndicator.currentPage = page
        if page == 0 {
            dashboard.applySettings()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        pageIndicator.currentPage = page
    }
}
