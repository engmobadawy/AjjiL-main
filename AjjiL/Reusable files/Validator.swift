// just collect useful reusable things


import Foundation

enum ValidationType {
    case optional
    case mandatory
    case email
    case password
    case confirmPassword(password: String)

    var errorMessage: String {
        switch self {
        case .optional:
            return ""
        case .mandatory:
            return "This field is mandatory."
        case .email:
            return "Invalid email format."
        case .password:
            return "Password must be at least 8 characters, include 1 uppercase letter and 1 number."
        case .confirmPassword(password: _):
            return "Passwords do not match. Please try again."
        }
    }
}

struct Validator {

    private static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    private static let passwordRegex = "^(?=.*?[A-Z])(?=.*?[\\d]).{8,}$"

    static func validate(_ text: String, type: ValidationType) -> Bool {
        switch type {
        case .optional:
            return true

        case .mandatory:
            return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        case .email:
            return isValidEmail(text)

        case .password:
            return isValidPassword(text)

        case .confirmPassword(let password):
            return text == password
        }
    }

    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: trimmed)
    }

    static func isValidPassword(_ password: String) -> Bool {
        guard !password.isEmpty else { return false }
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}
