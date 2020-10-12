//
//  File.swift
//  
//
//  Created by Anders Mannberg on 2020-10-12.
//

import Vapor
import scrap_data_models

enum SideEffects {
    struct RegisterUser {
        let candidate: UserRegistrationCandidate
        var candidateCountInStorage: () -> EventLoopFuture<Int>
        var hash: (String) throws -> String
        var storeUser: (User) -> EventLoopFuture<User>
    }
    
    struct GenerateToken {
        var generateToken: (User) throws -> UserToken
        var saveToken: (UserToken) -> EventLoopFuture<UserToken>
    }
}
