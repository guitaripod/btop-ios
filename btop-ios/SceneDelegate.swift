import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var rootContainer: RootContainerViewController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark

        let container = RootContainerViewController()
        window.rootViewController = container
        window.makeKeyAndVisible()

        self.window = window
        self.rootContainer = container

        UIApplication.shared.isIdleTimerDisabled = Settings.shared.keepScreenOn
        container.dashboard.startPolling()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.isIdleTimerDisabled = Settings.shared.keepScreenOn
        rootContainer?.dashboard.startPolling()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        UIApplication.shared.isIdleTimerDisabled = false
        rootContainer?.dashboard.stopPolling()
    }
}
