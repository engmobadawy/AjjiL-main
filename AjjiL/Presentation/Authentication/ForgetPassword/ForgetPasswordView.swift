//
//  NewPasswordView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 11/02/2026.
//

import SwiftUI
import MOLH

struct ForgetPasswordView: View {
    // Assuming you inject this via your DependencyContainer like SignUpView
    @State private var model: ForgetPasswordViewModel = DependencyContainer.AuthDependency.shared.forgetViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    let onBack: () -> Void
    
    private enum Field: Hashable {
        case password, confirm
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowWithBack(onBack: onBack)
            ScrollView {
                VStack(spacing: 18) {
                    headerSection
                    formFields
                    
                    GreenButton(title: "save".localized(), action: handleForgetPassword)
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
                Button("done".localized()) {
                    hideKeyboard()
                    handleForgetPassword()
                }
                Spacer()
                Button(action: { focusedField = .password }) {
                    Image(systemName: "chevron.up").foregroundStyle(.black)
                }
                Button(action: { focusedField = .confirm }) {
                    Image(systemName: "chevron.down").foregroundStyle(.black)
                }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.5))
            focusedField = .password
        }
        .navigationBarBackButtonHidden(true)
    }
    
    var formFields: some View {
        VStack(spacing: 16) {
            SecureCustomTextField(
                isValid: model.passwordError == nil,
                errorMessage: model.passwordError,
                text: $model.password,
                placeholder: "new_password".localized(),
                backgroundColor: .goodGray,
                strokeColor: passwordStrokeColor,
                preset: .newPassword,
                submitLabel: .next,
                onSubmit: { focusedField = .confirm }
            )
            .focused($focusedField, equals: .password)
            .onChange(of: model.password) { _, _ in
                model.hasInteractedWithPassword = true
            }
            .task(id: model.password) {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    model.validatePassword()
                } catch {}
            }
            
            SecureCustomTextField(
                isValid: model.confirmError == nil,
                errorMessage: model.confirmError,
                text: $model.confirmPassword,
                placeholder: "confirm_password".localized(),
                backgroundColor: .goodGray,
                strokeColor: confirmStrokeColor,
                preset: .newPassword,
                submitLabel: .done,
                onSubmit: handleForgetPassword
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

private extension ForgetPasswordView {
    func handleForgetPassword() {
        focusedField = nil
        Task {
            if await model.saveNewPassword() {
                await MainActor.run {
                    GenericUserDefault.shared.setValue(true, Constants.shared.passwordChanged)
                    MOLH.reset()
                }
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Stroke Color Logic (Refactored to match SignUpView)
    private var passwordStrokeColor: Color? {
        model.isPasswordValid || (focusedField == .password && model.password.isEmpty) ? .brandGreen : nil
    }
    
    private var confirmStrokeColor: Color? {
        model.isConfirmValid || (focusedField == .confirm && model.confirmPassword.isEmpty) ? .brandGreen : nil
    }
}

private extension ForgetPasswordView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("set_new_password_header".localized())
                .font(.custom("Poppins-Bold", size: 28))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("set_new_password_subtext".localized())
                .font(.custom("Poppins-Regular", size: 18))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
