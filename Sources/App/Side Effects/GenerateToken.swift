//
//  File.swift
//  
//
//  Created by Anders Mannberg on 2020-10-12.
//

import Vapor
import scrap_data_models

extension SideEffects.GenerateToken {
    static func live(req: Request) -> SideEffects.GenerateToken {
        SideEffects.GenerateToken(
            generateToken: { user in try user.generateToken() },
            saveToken: { token in token.save(on: req.db).map { token }}
        )
    }
}
