import XCTest
@testable import SimpleHTTP

final class SimpleHTTPTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual(SimpleHTTP().text, "Hello, World!")
        struct YourResultModel: Codable {
            let message: String
        }
        
        let data = "{\"message\":\"Hello, World!\"}".data(using: .utf8)!
        
        let result = data.json()! as YourResultModel
        
        print(result.message) // Hello, World!
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
