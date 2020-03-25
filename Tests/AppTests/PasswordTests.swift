@testable import App
import XCTVapor

final class PasswordTests: XCTestCase {
    func testPassword_shouldContainAtLeastEightCharacters() {
        XCTAssert(Validator.password.validate("aaaaaaa").isFailure)
    }
    
    func testPassword_shouldContainAtLeastOneDigit() {
        XCTAssert(Validator.password.validate("aaaaaaaa").isFailure)
    }
    
    func testPassword_shouldContainAtLeastCharacter() {
        XCTAssertFalse(Validator.password.validate("ABCDEFG1").isFailure)
        XCTAssert(Validator.password.validate("11111111").isFailure)
        XCTAssert(Validator.password.validate("1#######").isFailure)
    }
    
    func testPassword_shouldContainOnlyEnglishLettersNumbersAndSomeSpecialCharacters() {
        XCTAssert(Validator.password.validate("aaaaaaå1").isFailure)
        XCTAssertFalse(Validator.password.validate("aaaaaaa1").isFailure)
        XCTAssertFalse(Validator.password.validate("aaaaaa1_").isFailure)
        XCTAssertFalse(Validator.password.validate("aaaaaa1!").isFailure)
        XCTAssertFalse(Validator.password.validate("aaaaaa1#").isFailure)
        XCTAssertFalse(Validator.password.validate("aaaaaa1$").isFailure)
        XCTAssertFalse(Validator.password.validate("aaaaaa1&").isFailure)
        XCTAssertFalse(Validator.password.validate("aaaaaa1*").isFailure)
    }
    
    func testPassword_shouldContainMaximum20Characters() {
        let twentyOneCharacterString = "aaaaaaaaaaaaaaaaaaa1a"
        XCTAssert(Validator.password.validate(twentyOneCharacterString).isFailure)
    }
}
