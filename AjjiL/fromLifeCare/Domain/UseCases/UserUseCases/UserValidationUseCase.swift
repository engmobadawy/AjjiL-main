//
// UserValidationUseCase.swift
//

import Foundation

protocol UserValidationUseCase {
    func validateUsername(username: String) throws
    func validateEmail(email: String) throws
    func validatePhoneNumber(phoneNumber: String) throws
    func validateEmployeeId(employeeId: String) throws
    func validateNationalId(nationalId: String) throws
    func validateIban(iban: String) throws
    func validateOTPCode(code: String) throws
    func validatePassword(password: String) throws
    func validateConfirmPassword(password: String, confirmPassword: String) throws
    func validateAgreeTerms(isAgreeTerms: Bool) throws
}

class UserValidationUseCaseImpl: UserValidationUseCase {

    private let inputValidator: InputValidator

    init(inputValidator: InputValidator) {
        self.inputValidator = inputValidator
    }

    func validateUsername(username: String) throws {
        try inputValidator.validateUsername(username)
    }

    func validateEmail(email: String) throws {
        try inputValidator.validateEmail(email)
    }

    func validatePhoneNumber(phoneNumber: String) throws {
        try inputValidator.validatePhoneNumber(phoneNumber)
    }

    func validateEmployeeId(employeeId: String) throws {
        try inputValidator.validateEmployeeId(employeeId)
    }
    
    func validateNationalId(nationalId: String) throws {
        try inputValidator.validateNationalId(nationalId)
    }
    
    func validateIban(iban: String) throws {
        try inputValidator.validateIban(iban)
    }
    
    func validateOTPCode(code: String) throws {
        try inputValidator.validateOTPCode(code)
    }

    func validatePassword(password: String) throws {
        try inputValidator.validatePassword(password)
    }

    func validateConfirmPassword(password: String, confirmPassword: String) throws {
        try inputValidator.validateConfirmPassword(password, confirmPassword: confirmPassword)
    }
    
    func validateAgreeTerms(isAgreeTerms: Bool) throws {
        try inputValidator.validateAgreeTerms(isAgreeTerms)
    }
}
