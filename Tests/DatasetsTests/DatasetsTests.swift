import XCTest
@testable import Datasets

final class DatasetsTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(Datasets().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
