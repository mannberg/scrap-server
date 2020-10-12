import Vapor
import Fluent
import scrap_data_models

enum Route: String {
    case register
    case login
}

func routes(_ app: Application) throws {
    
    //MARK: Register
    app.post(.constant(Route.register.rawValue)) { req -> EventLoopFuture<UserToken> in
        
        try UserRegistrationCandidate.validate(req)
        let candidate = try req.content.decode(UserRegistrationCandidate.self)
        
        return EventLoopFuture<User>
            .storeUser(sideEffects: .live(req: req, candidate: candidate))
            .generateLoginToken(sideEffects: .live(req: req))
    }
    
    //MARK: Login
    let passwordProtected = app.grouped(User.authenticator())
    
    passwordProtected.post(.constant(Route.login.rawValue)) { req -> EventLoopFuture<UserToken> in
        let user = try req.auth.require(User.self)
        
        return req.eventLoop
            .makeSucceededFuture(user)
            .generateLoginToken(sideEffects: .live(req: req))
    }
    
    //MARK: Test
    let tokenProtected = app.grouped(UserToken.authenticator())
    
    tokenProtected.get("me") { req -> User in
        try req.auth.require(User.self)
    }
}

extension EventLoopFuture where Value == User {
    static func storeUser(sideEffects: SideEffects.RegisterUser) -> EventLoopFuture<User> {
        
        return sideEffects.candidateCountInStorage()
                .flatMapThrowing { (count: Int) -> User in
                    guard count == 0 else { throw Abort(.conflict, reason: "Email adress already registered.") }
                    
                    let passwordDigest = try sideEffects.hash(sideEffects.candidate.password)
                    let user = User(
                        displayName: sideEffects.candidate.displayName,
                        email: sideEffects.candidate.email,
                        password: passwordDigest
                    )
                    
                    return user
                }
                .flatMap(sideEffects.storeUser)
    }
    
    func generateLoginToken(sideEffects: SideEffects.GenerateToken) -> EventLoopFuture<UserToken> {
        self
            .flatMapThrowing(sideEffects.generateToken)
            .flatMap(sideEffects.saveToken)
    }
}

extension UserRegistrationCandidate: Content {}

extension User: Content {}

extension UserRegistrationCandidate: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("displayName", as: String.self, is: .displayName)
        validations.add("email", as: String.self, is: .customEmail)
        validations.add("password", as: String.self, is: .password)
    }
}
