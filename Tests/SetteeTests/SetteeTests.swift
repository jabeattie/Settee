import XCTest
@testable import Settee

final class SetteeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Settee().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
