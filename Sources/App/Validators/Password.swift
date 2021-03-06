//
//  File.swift
//  
//
//  Created by Anders Mannberg on 2020-03-24.
//

import Vapor
import IsValid

extension Validator where T == String {
    public static var password: Validator<T> {
        .init {
            ValidatorResults.Password(isValid: IsValid.password($0))
        }
    }
}

extension ValidatorResults {
    public struct Password {
        public let isValid: Bool
    }
}

extension ValidatorResults.Password: ValidatorResult {
    public var isFailure: Bool {
        !self.isValid
    }
    
    public var successDescription: String? {
        "is a valid password"
    }
    
    public var failureDescription: String? {
        "is not a valid password"
    }
}
