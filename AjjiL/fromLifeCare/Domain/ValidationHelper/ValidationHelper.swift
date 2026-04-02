import Foundation

// MARK: - Validation Error
enum ValidationError: Error, LocalizedError {
    case invalidUsername
    case invalidEmail
    case invalidPhoneNumber
    case invalidCode
    case invalidPassword
    case invalidNewPassword
    case invalidOldPassword
    case newPasswordSameAsOldPassword
    case passwordMismatch
    case missingRequiredField(String)
    
    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let message): return message
        // Add other localized strings here as needed
        default: return String(describing: self)
        }
    }
}

// MARK: - Protocol
protocol InputValidator {
    func validateUsername(_ username: String) throws
    func validateEmail(_ email: String) throws
    func validatePhoneNumber(_ phoneNumber: String) throws
    func validateEmployeeId(_ employeeId: String) throws
    func validateNationalId(_ nationalId: String) throws
    func validateIban(_ iban: String) throws
    func validateOTPCode(_ code: String) throws
    func validatePassword(_ password: String) throws
    func validateConfirmPassword(_ password: String, confirmPassword: String) throws
    func validateOldPassword(_ oldPassword: String, _ newPassword: String) throws
    func validateAgreeTerms(_ isAgreeTerms: Bool) throws
}

// MARK: - Implementation
class ValidationHelper: InputValidator {

    func validateUsername(_ username: String) throws {
        guard !username.isEmpty else {
            throw ValidationError.missingRequiredField("empty_username".localized())
        }
        let usernameRegex = "^[a-zA-Z\\u0600-\\u06FF ]{2,50}$"
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        guard usernameTest.evaluate(with: username) else {
            throw ValidationError.invalidUsername
        }
    }

    func validateEmail(_ email: String) throws {
        guard !email.isEmpty else {
            throw ValidationError.missingRequiredField("empty_email".localized())
        }
        let emailRegex = "^[a-zA-Z0-9]+(?:[._%+-]*[a-zA-Z0-9])*@(?:[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*\\.)+[a-zA-Z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailTest.evaluate(with: email) else {
            throw ValidationError.invalidEmail
        }
    }
    
    private func normalizeKSAMobile(_ input: String) -> String? {
        let digits = input.compactMap { ch -> String? in
            if let v = ch.wholeNumberValue { return String(v) }
            return nil
        }.joined()

        let trimmed: Substring
        if digits.hasPrefix("00966") {
            trimmed = digits.dropFirst(5)
        } else if digits.hasPrefix("966") {
            trimmed = digits.dropFirst(3)
        } else {
            trimmed = Substring(digits)
        }

        let local: Substring = trimmed.hasPrefix("05") ? trimmed.dropFirst(1) : trimmed
        guard local.count == 9, local.first == "5" else { return nil }

        return "+966" + local
    }

    func validatePhoneNumber(_ phoneNumber: String) throws {
        guard !phoneNumber.isEmpty else {
            throw ValidationError.missingRequiredField("empty_phone".localized())
        }
        guard normalizeKSAMobile(phoneNumber) != nil else {
            throw ValidationError.invalidPhoneNumber
        }
    }

    func validateEmployeeId(_ employeeId: String) throws {
        guard !employeeId.isEmpty else {
            throw ValidationError.missingRequiredField("empty_employee_id".localized())
        }
    }
    
    func validateNationalId(_ nationalId: String) throws {
        guard !nationalId.isEmpty else {
            throw ValidationError.missingRequiredField("empty_national_id".localized())
        }
    }
    
    func validateIban(_ iban: String) throws {
        if iban.isEmpty { return } // Assuming empty is allowed based on your original logic
        
        let saudiIbanPattern = "^SA[0-9]{22}$"
        let regex = try? NSRegularExpression(pattern: saudiIbanPattern)
        
        let isValidLength = iban.count == 24
        let isValidFormat = regex?.firstMatch(in: iban, range: NSRange(location: 0, length: iban.count)) != nil
        
        guard isValidLength && isValidFormat else {
            throw ValidationError.missingRequiredField("invalid_IBAN".localized())
        }
    }
    
    func validateOTPCode(_ code: String) throws {
        guard !code.isEmpty else {
            throw ValidationError.missingRequiredField("empty_code".localized())
        }
        guard code.count == 4 else {
            throw ValidationError.invalidCode
        }
    }
    
    func validatePassword(_ password: String) throws {
        guard !password.isEmpty else {
            throw ValidationError.missingRequiredField("empty_password".localized())
        }
        guard password.count >= 8 else {
            throw ValidationError.invalidPassword
        }
    }
    
    func validateConfirmPassword(_ password: String, confirmPassword: String) throws {
        guard !confirmPassword.isEmpty else {
            throw ValidationError.missingRequiredField("empty_confirm_password".localized())
        }
        guard confirmPassword.count >= 8 && password == confirmPassword else {
            throw ValidationError.passwordMismatch
        }
    }

    func validateOldPassword(_ oldPassword: String, _ newPassword: String) throws {
        guard !oldPassword.isEmpty else {
            throw ValidationError.missingRequiredField("empty_old_password".localized())
        }
        guard !newPassword.isEmpty else {
            throw ValidationError.missingRequiredField("empty_new_password".localized())
        }
        guard oldPassword.count >= 8 else {
            throw ValidationError.invalidOldPassword
        }
        guard oldPassword != newPassword else {
            throw ValidationError.newPasswordSameAsOldPassword
        }
    }
    
    func validateAgreeTerms(_ isAgreeTerms: Bool) throws {
        guard isAgreeTerms else {
            throw ValidationError.missingRequiredField("empty_is_agree_terms".localized())
        }
    }
}
