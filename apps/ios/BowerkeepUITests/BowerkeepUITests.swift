import XCTest

final class BowerkeepUITests: XCTestCase {
    @MainActor
    func testAppLaunches() {
        let app = XCUIApplication()

        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
}
