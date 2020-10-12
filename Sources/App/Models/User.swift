//
//  File.swift
//  
//
//  Created by Anders Mannberg on 2020-06-07.
//

import Vapor
import Fluent

final class User: Model {
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

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$email
    static var passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}

struct CreateStoredUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("display_name", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
