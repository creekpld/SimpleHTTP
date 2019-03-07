import XCTest
@testable import SimpleHTTP

final class SimpleHTTPTests: XCTestCase {
    
    struct TestModel: Codable {
        let message: String
    }
    
    func testJSONDecoder() {
        
        let data = "{\"message\":\"Hello, World!\"}".data(using: .utf8)!
        
        let result = data.json()! as TestModel
        
        print(result.message) // Hello, World!
        
        XCTAssertEqual(result.message, "Hello, World!")
    }
    
    func testJSONEncoder() {
        
        let obj = TestModel(message: "Hello, World!")
        
        let data = Data(encodable: obj)!
        
        let jsonString = String(data: data, encoding: .utf8)!
        
        print(jsonString) // "{\"message\":\"Hello, World!\"}"
        
        XCTAssertEqual(jsonString, "{\"message\":\"Hello, World!\"}")
    }

    static var allTests = [
        ("testJSONDecoder", testJSONDecoder),
        ("testJSONEncoder", testJSONEncoder),
    ]
}
