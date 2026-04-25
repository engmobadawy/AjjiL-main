//
//  ChangePasswordView.swift
//  AjjiL
//

import SwiftUI

struct ChangePasswordView: View {
    // Assuming you inject this via your DependencyContainer like the others
    @State private var model: ChangePasswordViewModel = DependencyContainer.AuthDependency.shared.changePasswordViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    let onBack: () -> Void
    
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
                    
                    GreenButton(title: "Save".localized(), action: handleChangePassword)
                        .disabled(!model.isFormValid)
                        .opacity(model.isFormValid ? 1.0 : 0.45)
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
                Button("Done".localized()) {
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
    }
    
    var formFields: some View {
        VStack(spacing: 16) {
            
            // 1. Old Password Field
            SecureCustomTextField(
                isValid: model.oldPasswordError == nil,
                errorMessage: model.oldPasswordError,
                text: $model.oldPassword,
                placeholder: "Old Password".localized(),
                backgroundColor: .goodGray,
                strokeColor: oldPasswordStrokeColor,
                preset: .password, // Assuming you have a standard password preset
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
                placeholder: "New Password".localized(),
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
                placeholder: "Confirm New Password".localized(),
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
            Text("Change Password".localized())
                .font(.custom("Poppins-Bold", size: 28))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Type your old password to verify you and then type your new password.".localized())
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    func handleChangePassword() {
        focusedField = nil
        Task {
            if await model.savePassword() {
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