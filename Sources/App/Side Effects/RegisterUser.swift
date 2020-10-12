//
//  File.swift
//  
//
//  Created by Anders Mannberg on 2020-10-12.
//

import Vapor
import Fluent
import scrap_data_models

extension SideEffects.RegisterUser {
    static func live(req: Request, candidate: UserRegistrationCandidate) -> SideEffects.RegisterUser {
        SideEffects.RegisterUser(
            candidate: candidate,
            candidateCountInStorage: {
                User
                    .query(on: req.db)
                    .filter(\.$email == candidate.email)
                    .count()
            },
            hash: req.password.hash,
            storeUser: { user in user.create(on: req.db).map { user } }
        )
    }
}
