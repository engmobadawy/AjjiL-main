import SwiftUI
import Observation

@MainActor
@Observable
final class SignUpViewModel {
    
    private let signUpUseCase: SignUpUseCase
    private let userValidationUseCase: UserValidationUseCase
    
    init(signUpUseCase: SignUpUseCase, userValidationUseCase: UserValidationUseCase) {
        self.signUpUseCase = signUpUseCase
        self.userValidationUseCase = userValidationUseCase
    }

    // MARK: - Network State
    var isLoading = false
    var errorMessage: String?

    // MARK: - Input Fields
    var username = ""
    var email = ""
    var phone = ""
    var password = ""
    var confirmPassword = ""
    var isAgreed = false

    // MARK: - Validation State
    var usernameError: String?
    var emailError: String?
    var phoneError: String?
    var passwordError: String?
    var confirmationPasswordError: String?
    
    var isUsernameValid = false
    var isEmailValid = false
    var isPhoneValid = false
    var isPasswordValid = false
    var isConfirmPasswordValid = false

    // MARK: - Interaction Tracking
    var hasInteractedWithUsername = false
    var hasInteractedWithEmail = false
    var hasInteractedWithPhone = false
    var hasInteractedWithPassword = false
    var hasInteractedWithConfirmPassword = false
    var hasAttemptedSubmit = false

    // MARK: - Derived State
    var isFormReady: Bool {
        isUsernameValid && isEmailValid && isPhoneValid && isPasswordValid && isConfirmPasswordValid && isAgreed
    }
    

    
    func validateUsername() {
        runValidation(hasInteracted: hasInteractedWithUsername, isValid: &isUsernameValid, error: &usernameError) {
            try userValidationUseCase.validateUsername(username: username)
        }
    }
    
    func validateEmail() {
        runValidation(hasInteracted: hasInteractedWithEmail, isValid: &isEmailValid, error: &emailError) {
            try userValidationUseCase.validateEmail(email: email)
        }
    }
    
    func validatePhone() {
        runValidation(hasInteracted: hasInteractedWithPhone, isValid: &isPhoneValid, error: &phoneError) {
            try userValidationUseCase.validatePhoneNumber(phoneNumber: phone)
        }
    }
    
    func validatePassword() {
        runValidation(hasInteracted: hasInteractedWithPassword, isValid: &isPasswordValid, error: &passwordError) {
            try userValidationUseCase.validatePassword(password: password)
            
            // Re-evaluate confirmation if the user has already interacted with it
            if hasInteractedWithConfirmPassword || hasAttemptedSubmit {
                validateConfirmPassword()
            }
        }
    }
    
    func validateConfirmPassword() {
        runValidation(hasInteracted: hasInteractedWithConfirmPassword, isValid: &isConfirmPasswordValid, error: &confirmationPasswordError) {
            try userValidationUseCase.validateConfirmPassword(password: password, confirmPassword: confirmPassword)
        }
    }
    
    func validateAll() -> Bool {
        hasAttemptedSubmit = true
        validateUsername()
        validateEmail()
        validatePhone()
        validatePassword()
        validateConfirmPassword()
        
        return isFormReady
    }

    // MARK: - Actions
    
    func signUp() async -> Bool {
        guard validateAll() else { return false }
        
        isLoading = true
        defer { isLoading = false }

        do {
            let parameters: [String: Any] = [
                "name": username,
                "phone_number": phone,
                "email": email,
                "password": password,
                "password_confirmation": confirmPassword
            ]
            
            let response = try await signUpUseCase.signUp(with: parameters)
            print("Successfully registered. User ID: \(response.userId), Name: \(response.name)")
            return true
        } catch {
            let mappedError = error.mapErrorToMessage()
            if errorMessage != mappedError { errorMessage = mappedError }
            return false
        }
    }
    
    // MARK: - Generic Validation Engine
    
    /// Reusable helper to remove redundant do-catch blocks and interaction checks.
    private func runValidation(
        hasInteracted: Bool,
        isValid: inout Bool,
        error: inout String?,
        validationBlock: () throws -> Void
    ) {
        // Suppress errors until user types or attempts to submit
        guard hasInteracted || hasAttemptedSubmit else {
            updateState(isValid: &isValid, error: &error, newValid: false, newError: nil)
            return
        }
        
        do {
            try validationBlock()
            updateState(isValid: &isValid, error: &error, newValid: true, newError: nil)
        } catch let validationError {
            updateState(isValid: &isValid, error: &error, newValid: false, newError: validationError.mapErrorToMessage())
        }
    }
    
    /// Centralized performance check to avoid redundant view updates
    private func updateState(isValid: inout Bool, error: inout String?, newValid: Bool, newError: String?) {
        if isValid != newValid { isValid = newValid }
        if error != newError { error = newError }
    }
}
