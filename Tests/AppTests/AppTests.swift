@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testRegisterUser_badEmailEqualsBadRequest() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let body = requestBody(from:
            RegisterUser(email: "joe", password: "abcd1234")
        )
        
        try app.test(.POST, "register", headers: jsonHeader, body: body) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testRegisterUser_emptyEmailEqualsBadRequest() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let body = requestBody(from:
            RegisterUser(email: "", password: "abcd1234")
        )
        
        try app.test(.POST, "register", headers: jsonHeader, body: body) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testRegisterUser_invalidPasswordEqualsBadRequest() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let body = requestBody(from:
            RegisterUser(email: "joe@south.com", password: "abcd12")
        )
        
        try app.test(.POST, "register", headers: jsonHeader, body: body) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testRegisterUser_validEmailAndValidPasswordEqualsOKStatus() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let body = requestBody(from:
            RegisterUser(email: "joe@south.com", password: "abcd1234")
        )
        
        try app.test(.POST, "register", headers: jsonHeader, body: body) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
}

fileprivate func requestBody<T: Content>(from content: T) -> ByteBuffer {
    let data = try! JSONEncoder().encode(content)
    
    var buffer = ByteBufferAllocator().buffer(capacity: 0)
    buffer.writeString(
        String(data: data, encoding: .utf8)!
    )
    
    return buffer
}

fileprivate var jsonHeader: HTTPHeaders {
    HTTPHeaders([("Content-Type", "application/json")])
}
