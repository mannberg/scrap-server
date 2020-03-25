//
//  File.swift
//  
//
//  Created by Anders Mannberg on 2020-03-24.
//

import Vapor
import Foundation

extension Validator where T == String {
    public static var password: Validator<T> {
        .init {
            guard $0.range(of: regex, options: .regularExpression) != nil else {
                return ValidatorResults.Password(isValid: false)
            }
            return ValidatorResults.Password(isValid: true)
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

fileprivate let regex = "^(?=.*[A-Za-z])(?=.*[0-9])(?!.*[^a-zA-Z0-9_!@#$&*]).{8,20}$"

