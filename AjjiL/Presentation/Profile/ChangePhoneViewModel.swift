import SwiftUI
import Observation

@MainActor
@Observable
final class ChangePhoneViewModel {
    
    private let userValidationUseCase: UserValidationUseCase
    private let changePhoneUseCase: ChangePhoneUseCase
    
    init(userValidationUseCase: UserValidationUseCase, changePhoneUseCase: ChangePhoneUseCase) {
        self.userValidationUseCase = userValidationUseCase
        self.changePhoneUseCase = changePhoneUseCase
    }

    // MARK: - State Properties
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?
    
    // MARK: - Input Fields
    var phone = ""
    var password = ""
    
    // MARK: - Validation State
    var phoneError: String?
    var passwordError: String?
    
    var isPhoneValid = false
    var isPasswordValid = false
    
    // MARK: - Interaction Tracking
    var hasInteractedWithPhone = false
    var hasInteractedWithPassword = false
    var hasAttemptedSubmit = false
    
    // MARK: - Derived State
    var isFormValid: Bool {
        isPhoneValid && isPasswordValid
    }
    
    // MARK: - Validation
    
    func validatePhone() {
        runValidation(hasInteracted: hasInteractedWithPhone, isValid: &isPhoneValid, error: &phoneError) {
            // Assuming your validation use case trims whitespaces as done in LogInViewModel
            try userValidationUseCase.validatePhoneNumber(phoneNumber: phone.trimmingCharacters(in: .whitespaces))
        }
    }
    
    func validatePassword() {
        runValidation(hasInteracted: hasInteractedWithPassword, isValid: &isPasswordValid, error: &passwordError) {
            try userValidationUseCase.validatePassword(password: password)
        }
    }
    
    func validateAll() -> Bool {
        hasAttemptedSubmit = true
        validatePhone()
        validatePassword()
        return isFormValid
    }
    
    // MARK: - Actions
    
    func savePhone() async -> Bool {
        guard validateAll() else { return false }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let message = try await changePhoneUseCase.execute(
                newPhone: phone.trimmingCharacters(in: .whitespaces),
                password: password
            )
            
            if successMessage != message {
                successMessage = message
            }
            return true
            
        } catch {
            let mappedError = error.mapErrorToMessage()
            if errorMessage != mappedError {
                errorMessage = mappedError
            }
            return false
        }
    }
    
    // MARK: - Generic Validation Engine
    
    private func runValidation(
        hasInteracted: Bool,
        isValid: inout Bool,
        error: inout String?,
        validationBlock: () throws -> Void
    ) {
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
    
    private func updateState(isValid: inout Bool, error: inout String?, newValid: Bool, newError: String?) {
        if isValid != newValid { isValid = newValid }
        if error != newError { error = newError }
    }
}