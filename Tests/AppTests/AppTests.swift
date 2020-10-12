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
        
        let mockRequest = Request.mock(for: app)
        
        let sideEffects = SideEffects.RegisterUser(
            candidate: .validCandidate,
            candidateCountInStorage: { mockRequest.eventLoop.makeSucceededFuture(0) },
            hash: { $0 },
            storeUser: { user in mockRequest.eventLoop.makeSucceededFuture(user) }
        )
        
        do {
            _ = try EventLoopFuture
                .storeUser(sideEffects: sideEffects)
                .wait()
        } catch {
            XCTFail()
        }
    }
    
    func testRegisterUser_passwordHashingIsPerformed() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let mockRequest = Request.mock(for: app)
        
        var didPerformHash = false
        
        let sideEffects = SideEffects.RegisterUser(
            candidate: .validCandidate,
            candidateCountInStorage: { mockRequest.eventLoop.makeSucceededFuture(0) },
            hash: { _ in
                didPerformHash = true
                return ""
            },
            storeUser: { user in mockRequest.eventLoop.makeSucceededFuture(user) }
        )
        
        do {
            _ = try EventLoopFuture
                .storeUser(sideEffects: sideEffects)
                .wait()
            XCTAssert(didPerformHash)
        } catch {
            XCTFail()
        }
    }
    
    func testRegisterUser_validEmailAndValidPasswordEqualsConflictStatusIfUserExists() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let mockRequest = Request.mock(for: app)
        
        let sideEffects = SideEffects.RegisterUser(
            candidate: .validCandidate,
            candidateCountInStorage: { mockRequest.eventLoop.makeSucceededFuture(1) },
            hash: { $0 },
            storeUser: { user in mockRequest.eventLoop.makeSucceededFuture(user) }
        )
        
        var didThrowException = false
        
        do {
            _ = try EventLoopFuture
                .storeUser(sideEffects: sideEffects)
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
    
    func testGenerateToken_tokenIsGeneratedAndSaved() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let mockRequest = Request.mock(for: app)
        
        var didPerformGenerateToken = false
        var didSaveToken = false
        
        let sideEffects = SideEffects.GenerateToken(
            generateToken: { _ in
                didPerformGenerateToken = true
                return UserToken()
            },
            saveToken: { _ in
                didSaveToken = true
                return mockRequest.eventLoop.makeSucceededFuture(UserToken())
            }
        )
        
        do {
            _ = try mockRequest.eventLoop.makeSucceededFuture(User())
                .generateLoginToken(sideEffects: sideEffects)
                .wait()
            XCTAssert(didPerformGenerateToken && didSaveToken)
        } catch {
            XCTFail()
        }
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

fileprivate extension UserRegistrationCandidate {
    static var validCandidate: UserRegistrationCandidate {
        UserRegistrationCandidate(
            displayName: "Joe",
            email: "joe@south.com",
            password: "abcd1234"
        )
    }
}

fileprivate extension Request {
    static func mock(for app: Application) -> Request {
        Request(
            application: app,
            method: .GET,
            url: .init(path: ""),
            on: app.eventLoopGroup.next()
        )
    }
}
