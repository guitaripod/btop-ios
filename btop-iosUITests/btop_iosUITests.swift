import XCTest

final class btop_iosUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testSettingsNavigation() throws {
        let dashboard = app.otherElements["dashboardView"]
        XCTAssertTrue(dashboard.waitForExistence(timeout: 5))
        screenshot("01_dashboard")

        app.swipeLeft()
        let settings = app.otherElements["settingsView"]
        XCTAssertTrue(settings.waitForExistence(timeout: 3))
        sleep(1)
        screenshot("02_settings_top")

        settings.swipeUp()
        sleep(1)
        screenshot("03_settings_scrolled")

        app.swipeRight()
        XCTAssertTrue(dashboard.waitForExistence(timeout: 3))
        screenshot("04_back_to_dashboard")
    }

    private func screenshot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
