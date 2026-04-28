//
//  ChangePasswordView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/04/2026.
//

import SwiftUI

struct ChangePasswordView: View {
    @State private var model: ChangePasswordViewModel
    @State private var toast: FancyToast?
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    let onBack: () -> Void
    
    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
        
        let validationUseCase = DependencyContainer.ValidationDependency.shared.userValidationUseCase
        let networkService = DependencyContainer.shared.networkService
        let profileRepo = ProfileRepositoryImp(networkService: networkService)
        let changePasswordUseCase = ChangePasswordUseCaseImpl(profileRepo: profileRepo)
        
        let vm = ChangePasswordViewModel(
            userValidationUseCase: validationUseCase,
            changePasswordUseCase: changePasswordUseCase
        )
        _model = State(initialValue: vm)
    }
    
    private enum Field: Hashable, CaseIterable {
        case oldPassword, newPassword, confirm
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowWithBack(onBack: onBack)
            
            ScrollView {
                VStack(spacing: 18) {
                    headerSection
                    formFields
                    
                    // 🛠️ FIX: Added .newlocalized
                    GreenButton(title: model.isLoading ? " " : "Save".newlocalized, action: handleChangePassword)
                        .disabled(!model.isFormValid || model.isLoading)
                        .opacity((model.isFormValid && !model.isLoading) ? 1.0 : 0.45)
                        .overlay {
                            if model.isLoading {
                                ProgressView().tint(.white)
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: model.isLoading)
                        .animation(.easeInOut(duration: 0.2), value: model.isFormValid)
                }
                .padding(.top, 38)
                .padding(.horizontal, 18)
            }
            .scrollIndicators(.hidden)
            .background(.white, in: .rect(cornerRadius: 28))
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                // 🛠️ FIX: Added .newlocalized
                Button("Done".newlocalized) {
                    hideKeyboard()
                    handleChangePassword()
                }
                Spacer()
                Button(action: { moveFocus(direction: -1) }) {
                    Image(systemName: "chevron.up").foregroundStyle(.black)
                }
                Button(action: { moveFocus(direction: 1) }) {
                    Image(systemName: "chevron.down").foregroundStyle(.black)
                }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.5))
            focusedField = .oldPassword
        }
        .navigationBarBackButtonHidden(true)
        .toastView(toast: $toast)
        .onChange(of: model.errorMessage) { _, newError in
            if let message = newError {
                // 🛠️ FIX: Added .newlocalized
                toast = FancyToast(type: .error, title: "error".newlocalized, message: message)
                model.errorMessage = nil
            }
        }
        .onChange(of: model.successMessage) { _, newSuccess in
            if let message = newSuccess {
                // 🛠️ FIX: Added .newlocalized
                toast = FancyToast(type: .success, title: "success".newlocalized, message: message)
                model.successMessage = nil
            }
        }
    }
    
    var formFields: some View {
        VStack(spacing: 16) {
            
            // 1. Old Password Field
            SecureCustomTextField(
                isValid: model.oldPasswordError == nil,
                errorMessage: model.oldPasswordError,
                text: $model.oldPassword,
                // 🛠️ FIX: Added .newlocalized
                placeholder: "Old Password".newlocalized,
                backgroundColor: .goodGray,
                strokeColor: oldPasswordStrokeColor,
                preset: .password,
                submitLabel: .next,
                onSubmit: { focusedField = .newPassword }
            )
            .focused($focusedField, equals: .oldPassword)
            .onChange(of: model.oldPassword) { _, _ in
                model.hasInteractedWithOldPassword = true
            }
            .task(id: model.oldPassword) {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    model.validateOldPassword()
                } catch {}
            }
            
            // 2. New Password Field
            SecureCustomTextField(
                isValid: model.newPasswordError == nil,
                errorMessage: model.newPasswordError,
                text: $model.newPassword,
                // 🛠️ FIX: Added .newlocalized
                placeholder: "New Password".newlocalized,
                backgroundColor: .goodGray,
                strokeColor: newPasswordStrokeColor,
                preset: .newPassword,
                submitLabel: .next,
                onSubmit: { focusedField = .confirm }
            )
            .focused($focusedField, equals: .newPassword)
            .onChange(of: model.newPassword) { _, _ in
                model.hasInteractedWithNewPassword = true
            }
            .task(id: model.newPassword) {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    model.validateNewPassword()
                } catch {}
            }
            
            // 3. Confirm New Password Field
            SecureCustomTextField(
                isValid: model.confirmError == nil,
                errorMessage: model.confirmError,
                text: $model.confirmPassword,
                // 🛠️ FIX: Added .newlocalized
                placeholder: "Confirm New Password".newlocalized,
                backgroundColor: .goodGray,
                strokeColor: confirmStrokeColor,
                preset: .newPassword,
                submitLabel: .done,
                onSubmit: handleChangePassword
            )
            .focused($focusedField, equals: .confirm)
            .onChange(of: model.confirmPassword) { _, _ in
                model.hasInteractedWithConfirmPassword = true
            }
            .task(id: model.confirmPassword) {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    model.validateConfirm()
                } catch {}
            }
        }
    }
}

private extension ChangePasswordView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 🛠️ FIX: Added .newlocalized
            Text("Change Password".newlocalized)
                .font(.custom("Poppins-Bold", size: 28))
                .frame(maxWidth: .infinity, alignment: .leading)

            // 🛠️ FIX: Added .newlocalized
            Text("Type your old password to verify you and then type your new password.".newlocalized)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    func handleChangePassword() {
        focusedField = nil
        Task {
            if await model.savePassword() {
                try? await Task.sleep(for: .seconds(1.5))
                await MainActor.run {
                    dismiss()
                }
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func moveFocus(direction: Int) {
        guard let current = focusedField,
              let currentIndex = Field.allCases.firstIndex(of: current) else { return }
        
        let nextIndex = currentIndex + direction
        if Field.allCases.indices.contains(nextIndex) {
            focusedField = Field.allCases[nextIndex]
        }
    }
    
    // MARK: - Stroke Color Logic
    
    private var oldPasswordStrokeColor: Color? {
        model.isOldPasswordValid || (focusedField == .oldPassword && model.oldPassword.isEmpty) ? .brandGreen : nil
    }
    
    private var newPasswordStrokeColor: Color? {
        model.isNewPasswordValid || (focusedField == .newPassword && model.newPassword.isEmpty) ? .brandGreen : nil
    }
    
    private var confirmStrokeColor: Color? {
        model.isConfirmValid || (focusedField == .confirm && model.confirmPassword.isEmpty) ? .brandGreen : nil
    }
}


import SwiftUI
import Observation

@MainActor
@Observable
final class ChangePasswordViewModel {
    
    private let userValidationUseCase: UserValidationUseCase
    private let changePasswordUseCase: ChangePasswordUseCase
    
    init(userValidationUseCase: UserValidationUseCase, changePasswordUseCase: ChangePasswordUseCase) {
        self.userValidationUseCase = userValidationUseCase
        self.changePasswordUseCase = changePasswordUseCase
    }

    // MARK: - State Properties
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?
    
    // MARK: - Input Fields
    var oldPassword = ""
    var newPassword = ""
    var confirmPassword = ""
    
    // MARK: - Validation State
    var oldPasswordError: String?
    var newPasswordError: String?
    var confirmError: String?
    
    var isOldPasswordValid = false
    var isNewPasswordValid = false
    var isConfirmValid = false
    
    // MARK: - Interaction Tracking
    var hasInteractedWithOldPassword = false
    var hasInteractedWithNewPassword = false
    var hasInteractedWithConfirmPassword = false
    var hasAttemptedSubmit = false
    
    // MARK: - Derived State
    var isFormValid: Bool {
        isOldPasswordValid && isNewPasswordValid && isConfirmValid
    }
    
    // MARK: - Validation
    
    func validateOldPassword() {
        runValidation(hasInteracted: hasInteractedWithOldPassword, isValid: &isOldPasswordValid, error: &oldPasswordError) {
            try userValidationUseCase.validatePassword(password: oldPassword)
        }
    }
    
    func validateNewPassword() {
        runValidation(hasInteracted: hasInteractedWithNewPassword, isValid: &isNewPasswordValid, error: &newPasswordError) {
            try userValidationUseCase.validatePassword(password: newPassword)
            
            // Re-evaluate confirmation if the user has already interacted with it
            if hasInteractedWithConfirmPassword || hasAttemptedSubmit {
                validateConfirm()
            }
        }
    }
    
    func validateConfirm() {
        runValidation(hasInteracted: hasInteractedWithConfirmPassword, isValid: &isConfirmValid, error: &confirmError) {
            try userValidationUseCase.validateConfirmPassword(password: newPassword, confirmPassword: confirmPassword)
        }
    }
    
    func validateAll() -> Bool {
        hasAttemptedSubmit = true
        validateOldPassword()
        validateNewPassword()
        validateConfirm()
        
        return isFormValid
    }
    
    // MARK: - Actions
    
    func savePassword() async -> Bool {
        guard validateAll() else { return false }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let message = try await changePasswordUseCase.execute(
                current: oldPassword,
                new: newPassword,
                confirm: confirmPassword
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
