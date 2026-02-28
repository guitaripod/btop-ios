import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var dashboard: DashboardViewController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark

        let vc = DashboardViewController()
        window.rootViewController = vc
        window.makeKeyAndVisible()

        self.window = window
        self.dashboard = vc

        UIApplication.shared.isIdleTimerDisabled = true
        vc.startPolling()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.isIdleTimerDisabled = true
        dashboard?.startPolling()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        UIApplication.shared.isIdleTimerDisabled = false
        dashboard?.stopPolling()
    }
}
