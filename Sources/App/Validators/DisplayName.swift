//
//  File.swift
//  
//
//  Created by Anders Mannberg on 2020-04-19.
//

import Vapor
import IsValid

extension Validator where T == String {
    public static var displayName: Validator<T> {
        .init {
            ValidatorResults.DisplayName(isValid: IsValid.displayName($0))
        }
    }
}

extension ValidatorResults {
    public struct DisplayName {
        public let isValid: Bool
    }
}

extension ValidatorResults.DisplayName: ValidatorResult {
    public var isFailure: Bool {
        !self.isValid
    }

    public var successDescription: String? {
        "is a valid display name"
    }

    public var failureDescription: String? {
        "is not a valid display name"
    }
}
