import Vapor
import Fluent
//import scrap_data_models

enum Route: String {
    case register
}

func routes(_ app: Application) throws {
    app.get { req in
        return #"{"name":"test"}"#
    }
    
    app.post(.constant(Route.register.rawValue)) { req -> EventLoopFuture<StoredUser> in
        try UserRegistrationCandidate.validate(req)
        let candidate = try req.content.decode(UserRegistrationCandidate.self)
        
        let sfx = SideEffects.RegisterUser(
            candidate: candidate,
            candidateCountInStorage: {
                StoredUser
                    .query(on: req.db)
                    .filter(\.$email == candidate.email)
                    .count()
            },
            hash: req.password.hash,
            store: { user in user.create(on: req.db).map { user } }
        )
        
        return .storedUser(sfx: sfx)
    }
}

enum SideEffects {
    struct RegisterUser {
        let candidate: UserRegistrationCandidate
        var candidateCountInStorage: () -> EventLoopFuture<Int>
        var hash: (String) throws -> String
        var store: (StoredUser) -> EventLoopFuture<StoredUser>
    }
}

extension EventLoopFuture where Value == StoredUser {
    static func storedUser(sfx: SideEffects.RegisterUser) -> EventLoopFuture<StoredUser> {
        
        return sfx.candidateCountInStorage()
                .flatMapThrowing { (count: Int) -> StoredUser in
                    guard count == 0 else { throw Abort(.conflict) }
                    
                    let passwordDigest = try sfx.hash(sfx.candidate.password)
                    let user = StoredUser(
                        displayName: sfx.candidate.displayName,
                        email: sfx.candidate.email,
                        password: passwordDigest
                    )
                    
                    return user
                }
                .flatMap { user in sfx.store(user) }
    }
}

struct UserRegistrationCandidate: Codable {
    var displayName: String
    var email: String
    var password: String
    
    public init(
        displayName: String,
        email: String,
        password: String
    ) {
        self.displayName = displayName
        self.email = email
        self.password = password
    }
}
extension UserRegistrationCandidate: Content {}

final class StoredUser: Model {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "display_name")
    var displayName: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String

    init() { }

    init(
        id: UUID? = nil,
        displayName: String,
        email: String,
        password: String
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.password = password
    }
}

struct CreateStoredUser: Migration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("display_name", .string)
            .field("email", .string)
            .field("password", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}

extension StoredUser: Content {}

extension UserRegistrationCandidate: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("displayName", as: String.self, is: .displayName)
        validations.add("email", as: String.self, is: .customEmail)
        validations.add("password", as: String.self, is: .password)
    }
}
