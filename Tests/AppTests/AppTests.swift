@testable import App
import XCTVapor
import XCTFluent
import Fluent
import scrap_data_models

final class AppTests: XCTestCase {
    func testRegisterUser_badEmailEqualsBadRequest() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let body = requestBody(from:
            UserRegistrationCandidate(
                displayName: "Joe",
                email: "joe",
                password: "abcd1234"
            )
        )
        
        try app.post(body: body, withExpectedStatus: .badRequest)
    }
    
    func testRegisterUser_emptyEmailEqualsBadRequest() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let body = requestBody(from:
            UserRegistrationCandidate(
                displayName: "Joe",
                email: "",
                password: "abcd1234"
            )
        )
        
        try app.post(body: body, withExpectedStatus: .badRequest)
    }
    
    func testRegisterUser_invalidPasswordEqualsBadRequest() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let body = requestBody(from:
            UserRegistrationCandidate(
                displayName: "Joe",
                email: "joe@south.com",
                password: "abcd12"
            )
        )
        
        try app.post(body: body, withExpectedStatus: .badRequest)
    }
    
    func testRegisterUser_validEmailAndValidPasswordEqualsOKStatusIfUserDoesNotExist() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let user = UserRegistrationCandidate(
                displayName: "Joe",
                email: "joe@south.com",
                password: "abcd1234"
        )
        
        let mockRequest = Request(
            application: app,
            method: .GET,
            url: .init(path: ""),
            on: app.eventLoopGroup.next()
        )
        
        let sfx = SideEffects.RegisterUser(
            candidate: user,
            candidateCountInStorage: { mockRequest.eventLoop.makeSucceededFuture(0) },
            hash: { $0 },
            store: { user in mockRequest.eventLoop.makeSucceededFuture(user) }
        )
        
        do {
            _ = try EventLoopFuture
                .storedUser(sfx: sfx)
                .wait()
        } catch {
            XCTFail()
        }
    }
    
    func testRegisterUser_validEmailAndValidPasswordEqualsConflictStatusIfUserExists() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let user = UserRegistrationCandidate(
                displayName: "Joe",
                email: "joe@south.com",
                password: "abcd1234"
        )
        
        let mockRequest = Request(
            application: app,
            method: .GET,
            url: .init(path: ""),
            on: app.eventLoopGroup.next()
        )
        
        let sfx = SideEffects.RegisterUser(
            candidate: user,
            candidateCountInStorage: { mockRequest.eventLoop.makeSucceededFuture(1) },
            hash: { $0 },
            store: { user in mockRequest.eventLoop.makeSucceededFuture(user) }
        )
        
        var didThrowException = false
        
        do {
            _ = try EventLoopFuture
                .storedUser(sfx: sfx)
                .wait()
        } catch {
            didThrowException = true
        }
        
        XCTAssert(didThrowException)
    }
    
    func testRegisterUser_invalidDisplayNameEqualsBadRequest() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let body = requestBody(from:
            UserRegistrationCandidate(
                displayName: "",
                email: "joe@south.com",
                password: "abcd1234"
            )
        )
        
        try app.post(body: body, withExpectedStatus: .badRequest)
    }
}

//MARK: Helpers

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

fileprivate extension Application {
    func post(body: ByteBuffer, withExpectedStatus status: HTTPStatus) throws {
        try self.test(
            .POST,
            Route.register.rawValue,
            headers: jsonHeader,
            body: body
        ) { res in
            XCTAssertEqual(res.status, status)
        }
    }
}
