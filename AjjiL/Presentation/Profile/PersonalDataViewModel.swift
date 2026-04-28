import SwiftUI
import Observation

@MainActor
@Observable
final class PersonalDataViewModel {
    
    // MARK: - Use Cases
    private let updateProfileInfoUC: UpdateProfileInfoUC
    
    // MARK: - Network State
    var isLoading = false
    var errorMessage: String?

    // MARK: - Input Fields
    var username: String
    var email: String
    var profileImage: UIImage?

    // MARK: - Validation State
    var usernameError: String?
    var emailError: String?
    
    var isUsernameValid = false
    var isEmailValid = false

    // MARK: - Interaction Tracking
    var hasInteractedWithUsername = false
    var hasInteractedWithEmail = false
    var hasAttemptedSubmit = false
    
    init(
        updateProfileInfoUC: UpdateProfileInfoUC,
        username: String = "",
        email: String = "",
        profileImage: UIImage? = nil
    ) {
        self.updateProfileInfoUC = updateProfileInfoUC
        self.username = username
        self.email = email
        self.profileImage = profileImage
        
        // Treat pre-filled data as already interacted with and valid to show green border
        if !username.isEmpty {
            self.hasInteractedWithUsername = true
            self.isUsernameValid = true
        }
        
        if !email.isEmpty {
            self.hasInteractedWithEmail = true
            self.isEmailValid = true
        }
    }

    var isFormReady: Bool {
        isUsernameValid && isEmailValid
    }
    
    // MARK: - Actions
    func saveChanges() async -> Bool {
        guard validateAll() else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await updateProfileInfoUC.execute(name: username, email: email)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Validation Methods
    func validateUsername() {
        runValidation(hasInteracted: hasInteractedWithUsername, isValid: &isUsernameValid, error: &usernameError) {
            if username.isEmpty { throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Username cannot be empty".newlocalized]) }
        }
    }
    
    func validateEmail() {
        runValidation(hasInteracted: hasInteractedWithEmail, isValid: &isEmailValid, error: &emailError) {
            if email.isEmpty { throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Email cannot be empty".newlocalized]) }
        }
    }
    
    func validateAll() -> Bool {
        hasAttemptedSubmit = true
        validateUsername()
        validateEmail()
        return isFormReady
    }

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
            updateState(isValid: &isValid, error: &error, newValid: false, newError: validationError.localizedDescription)
        }
    }
    
    private func updateState(isValid: inout Bool, error: inout String?, newValid: Bool, newError: String?) {
        if isValid != newValid { isValid = newValid }
        if error != newError { error = newError }
    }
}
