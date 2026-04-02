//
//  NewPasswordViewModel.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 18/02/2026.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class ForgetPasswordViewModel {
    
    private let userValidationUseCase: UserValidationUseCase
    
    init(userValidationUseCase: UserValidationUseCase) {
        self.userValidationUseCase = userValidationUseCase
    }

    // MARK: - Input Fields
    var password = ""
    var confirmPassword = ""
    
    // MARK: - Validation State
    var passwordError: String?
    var confirmError: String?
    
    var isPasswordValid = false
    var isConfirmValid = false
    
    // MARK: - Interaction Tracking
    var hasInteractedWithPassword = false
    var hasInteractedWithConfirmPassword = false
    var hasAttemptedSubmit = false
    
    // MARK: - Derived State
    var isFormValid: Bool {
        isPasswordValid && isConfirmValid
    }
    
    // MARK: - Validation
    
    func validatePassword() {
        runValidation(hasInteracted: hasInteractedWithPassword, isValid: &isPasswordValid, error: &passwordError) {
            try userValidationUseCase.validatePassword(password: password)
            
            // Re-evaluate confirmation if the user has already interacted with it
            if hasInteractedWithConfirmPassword || hasAttemptedSubmit {
                validateConfirm()
            }
        }
    }
    
    func validateConfirm() {
        runValidation(hasInteracted: hasInteractedWithConfirmPassword, isValid: &isConfirmValid, error: &confirmError) {
            try userValidationUseCase.validateConfirmPassword(password: password, confirmPassword: confirmPassword)
        }
    }
    
    func validateAll() -> Bool {
        hasAttemptedSubmit = true
        validatePassword()
        validateConfirm()
        
        return isFormValid
    }
    
    // MARK: - Actions
    
    func saveNewPassword() async -> Bool {
        guard validateAll() else { return false }
        
        do {
            // Perform network request to reset password
            try await Task.sleep(for: .seconds(1))
            return true
        } catch {
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
    
    private func updateState(isValid: inout Bool, error: inout String?, newValid: Bool, newError: String?) {
        if isValid != newValid { isValid = newValid }
        if error != newError { error = newError }
    }
}
