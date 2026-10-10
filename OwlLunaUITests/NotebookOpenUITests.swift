import XCTest

/// Exercise the shipped editor without the DEBUG-only seeded library.
@MainActor
final class NotebookOpenUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCreateOpenAndReopenNotebook() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments = ["-storageRoot", "notebook-open", "-resetStorage",
                               "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        let newNotebook = app.buttons["New Notebook"].firstMatch
        XCTAssertTrue(newNotebook.waitForExistence(timeout: 30))
        newNotebook.tap()
        let title = app.textFields["Title"]
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        title.tap()
        title.typeText("Opening Test")
        app.buttons["Create"].tap()

        let canvas = app.element("page.canvas.1")
        XCTAssertTrue(canvas.waitForExistence(timeout: 30), "a new notebook opens its canvas")
        let pen = app.buttons["editor.tools.1"]
        XCTAssertTrue(pen.waitForExistence(timeout: 10))
        if !pen.isSelected { pen.tap() }
        pen.tap()
        XCTAssertTrue(app.buttons["editor.tools.pen.remove"].waitForExistence(timeout: 10),
                      "the editor responds after opening")
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.1)).tap()

        let back = app.buttons["editor.back"]
        XCTAssertTrue(back.waitForExistence(timeout: 10))
        back.tap()
        let notebook = app.buttons["notebook.Opening Test"]
        XCTAssertTrue(notebook.waitForExistence(timeout: 20))
        notebook.tap()
        XCTAssertTrue(canvas.waitForExistence(timeout: 20), "the saved notebook reopens")
        XCTAssertTrue(back.waitForExistence(timeout: 10))
        XCTAssertEqual(app.state, .runningForeground)

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Reopened notebook"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
