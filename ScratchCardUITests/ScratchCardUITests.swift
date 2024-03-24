//
//  ScratchCardUITests.swift
//

import XCTest

final class ScratchCardUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasicWorkflow() throws {
        // Opportunities for improvement:
        // - support for localization
        // - mocked URLSession that's already used in unit tests

        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.buttons["Scratch Card"].isEnabled)
        XCTAssertFalse(app.buttons["Activate Card"].isEnabled)

        app.buttons["Scratch Card"].tap()
        app.buttons["Scratch it!"].tap()

        sleep(3)

        app.navigationBars["Scratch Card"].buttons["My Scratch Cards"].tap()

        XCTAssertFalse(app.buttons["Scratch Card"].isEnabled)
        XCTAssert(app.buttons["Activate Card"].isEnabled)

        app.buttons["Activate Card"].tap()
        app.buttons["Activate It!"].tap()

        if app.staticTexts["Activated Successfully"].waitForExistence(timeout: 10) {
            app.navigationBars["Activate Card"].buttons["My Scratch Cards"].tap()

            XCTAssertFalse(app.buttons["Scratch Card"].isEnabled)
            XCTAssertFalse(app.buttons["Activate Card"].isEnabled)
        }
        else {
            XCTFail("Failed to activate card")
        }
    }

    /*
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    */
}
