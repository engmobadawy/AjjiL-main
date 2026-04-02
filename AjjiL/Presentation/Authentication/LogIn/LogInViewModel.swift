import SwiftUI
import Observation

@MainActor
@Observable
final class LoginViewModel {
    
    // MARK: - Dependencies
    private let sendCodeUseCase: SendOTPUseCase
    private let userDataUseCase: UserDataUseCase
    private let loginUseCase: LoginUseCase
    private let userValidationUseCase: UserValidationUseCase
    
    init(
        loginUseCase: LoginUseCase,
        userDataUseCase: UserDataUseCase,
        userValidationUseCase: UserValidationUseCase,
        sendCodeUseCase: SendOTPUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.userDataUseCase = userDataUseCase
        self.sendCodeUseCase = sendCodeUseCase
        self.userValidationUseCase = userValidationUseCase
    }

    // MARK: - State Properties
    var isLoading = false
    var errorMessage: String?
    
    var phone = ""
    var password = ""
    
    var phoneError: String?
    var passwordError: String?
    
    var isPhoneValid = false
    var isPasswordValid = false

    // MARK: - Interaction Tracking
    var hasInteractedWithPhone = false
    var hasInteractedWithPassword = false
    var hasAttemptedSubmit = false

    var isFormReady: Bool {
        isPhoneValid && isPasswordValid
    }
    
    // MARK: - Validation
    
    func validatePhone() {
        // Suppress initial errors until the user types or tries to submit
        if !hasInteractedWithPhone && !hasAttemptedSubmit {
            updatePhoneState(isValid: false, error: nil)
            return
        }

        do {
            try userValidationUseCase.validatePhoneNumber(phoneNumber: phone.trimmingCharacters(in: .whitespaces))
            updatePhoneState(isValid: true, error: nil)
        } catch {
            updatePhoneState(isValid: false, error: error.mapErrorToMessage())
        }
    }
    
    func validatePassword() {
        // Suppress initial errors until the user types or tries to submit
        if !hasInteractedWithPassword && !hasAttemptedSubmit {
            updatePasswordState(isValid: false, error: nil)
            return
        }

        do {
            try userValidationUseCase.validatePassword(password: password)
            updatePasswordState(isValid: true, error: nil)
        } catch {
            updatePasswordState(isValid: false, error: error.mapErrorToMessage())
        }
    }

    func validateAll() -> Bool {
        // Force errors to show if the user hits "Sign In" while fields are empty
        hasAttemptedSubmit = true
        validatePhone()
        validatePassword()
        return isPhoneValid && isPasswordValid
    }

    // MARK: - Actions

    func logIn() async -> Bool {
        guard validateAll() else { return false }
        
        isLoading = true
        defer { isLoading = false }

        do {
            let parameters = [
                "phone_number": phone.trimmingCharacters(in: .whitespaces),
                "password": password
            ]
            let response = try await loginUseCase.login(with: parameters)
            userDataUseCase.saveToken(token: response.token)
            return true
        } catch {
            let mappedError = error.mapErrorToMessage()
            if errorMessage != mappedError {
                errorMessage = mappedError
            }
            return false
        }
    }
    
    // MARK: - Performance Optimizations
    
    private func updatePhoneState(isValid: Bool, error: String?) {
        if isPhoneValid != isValid { isPhoneValid = isValid }
        if phoneError != error { phoneError = error }
    }
    
    private func updatePasswordState(isValid: Bool, error: String?) {
        if isPasswordValid != isValid { isPasswordValid = isValid }
        if passwordError != error { passwordError = error }
    }
}
