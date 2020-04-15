//
//  File.swift
//
//
//  Created by Anders Mannberg on 2020-03-24.
//

import Vapor
import IsValid

extension Validator where T == String {
    public static var customEmail: Validator<T> {
        .init {
            ValidatorResults.CustomEmail(isValid: IsValid.email($0))
        }
    }
}

extension ValidatorResults {
    public struct CustomEmail {
        public let isValid: Bool
    }
}

extension ValidatorResults.CustomEmail: ValidatorResult {
    public var isFailure: Bool {
        !self.isValid
    }

    public var successDescription: String? {
        "is a valid email adress"
    }

    public var failureDescription: String? {
        "is not a valid email adress"
    }
}
