//
//  SignUpView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 10/02/2026.
//
import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
   
    // MARK: - State
    @State private var model: SignUpViewModel = DependencyContainer.AuthDependency.shared.signUpViewModel
    @State private var toast: FancyToast?
    
    // Navigation Booleans
    @State private var showOTP = false
    @State private var showTerms = false
    
    // MARK: - Focus
    private enum Field: Hashable {
        case username, phone, email, password, confirmPassword
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 0) {
            TopRow()
               
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.bottom, 18)
                        .padding(.top, 28)

                    formFields
                        .padding(.bottom, 20)
                    
                    GreenButton(title: model.isLoading ? " " : "sign_up".localized(), action: handleSignUp)
                        .disabled(!model.isFormReady || model.isLoading)
                        .opacity((model.isFormReady && !model.isLoading) ? 1.0 : 0.45)
                        .overlay {
                            if model.isLoading {
                                ProgressView().tint(.white)
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: model.isLoading)
                        .animation(.easeInOut(duration: 0.2), value: model.isFormReady)
                        .padding(.bottom, 24)

                    TermsAgreementView(
                        isAgreed: $model.isAgreed,
                        onAgreementTapped: { showTerms = true }
                    )
                
                    WhiteButton(title: "sign_in".localized(), action: { dismiss() })
                        .padding(.top, 8)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 25)
            }
            .scrollIndicators(.hidden)
            .contentShape(.rect)
            .onTapGesture { focusedField = nil }
            .background(.background)
        }
        // MARK: - Navigation
        .navigationDestination(isPresented: $showOTP) {
            OTPView(
                phoneNumber: model.phone,
                flow: .signUp,
                onResendTapped: {},
                onBack: { showOTP = false }
            )
        }
        .navigationDestination(isPresented: $showTerms) {
            TermsAndConditionView()
        }
        .navigationBarBackButtonHidden(true)
        .toastView(toast: $toast)
        .onChange(of: model.errorMessage) { _, newError in
            if let message = newError {
                toast = FancyToast(type: .error, title: "error".localized(), message: message)
                model.errorMessage = nil
            }
        }
        .task {
            // Initial focus after a small delay for smooth transition
            try? await Task.sleep(for: .seconds(0.5))
            focusedField = .username
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("done".localized()) {
                    focusedField = nil
                    handleSignUp()
                }
                Spacer()
                Button(action: showPreviousTextField) {
                    Image(systemName: "chevron.up").foregroundStyle(.black)
                }
                Button(action: showNextTextField) {
                    Image(systemName: "chevron.down").foregroundStyle(.black)
                }
            }
        }
    }
}

// MARK: - Logic & Actions
private extension SignUpView {
    func handleSignUp() {
        focusedField = nil
        Task {
            if await model.signUp() {
                showOTP = true
            }
        }
    }
    
    func showNextTextField() {
        switch focusedField {
        case .username: focusedField = .phone
        case .phone:    focusedField = .email
        case .email:    focusedField = .password
        case .password: focusedField = .confirmPassword
        default:        handleSignUp()
        }
    }
    
    func showPreviousTextField() {
        switch focusedField {
        case .confirmPassword: focusedField = .password
        case .password:        focusedField = .email
        case .email:           focusedField = .phone
        case .phone:           focusedField = .username
        default:               focusedField = nil
        }
    }
}

// MARK: - Subviews
private extension SignUpView {
    var formFields: some View {
        VStack(spacing: 18) {
            // MARK: Username
            CustomTextField(
                isValid: model.usernameError == nil,
                errorMessage: model.usernameError,
                text: $model.username,
                placeholder: "username".localized(),
                icon: Image(systemName: "person.fill"),
                backgroundColor: .goodGray,
                strokeColor: usernameStrokeColor,
                preset: .username,
                submitLabel: .next,
                onSubmit: { focusedField = .phone }
            )
            .focused($focusedField, equals: .username)
            .onChange(of: model.username) { _, _ in
                model.hasInteractedWithUsername = true
            }
            .task(id: model.username) {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    model.validateUsername()
                } catch {}
            }

            // MARK: Phone
            PhoneTextField(
                isValid: model.phoneError == nil,
                errorMessage: model.phoneError,
                text: $model.phone.noSpaces,
                backgroundColor: .goodGray,
                strokeColor: phoneStrokeColor,
                preset: .phone,
                submitLabel: .next,
                onSubmit: { focusedField = .email }
            )
            .focused($focusedField, equals: .phone)
            .onChange(of: model.phone) { _, _ in
                model.hasInteractedWithPhone = true
            }
            .task(id: model.phone) {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    model.validatePhone()
                } catch {}
            }

            // MARK: Email
            CustomTextField(
                isValid: model.emailError == nil,
                errorMessage: model.emailError,
                text: $model.email.noSpaces,
                placeholder: "email_placeholder".localized(),
                icon: Image(systemName: "envelope.fill"),
                backgroundColor: .goodGray,
                strokeColor: emailStrokeColor,
                preset: .email,
                submitLabel: .next,
                onSubmit: { focusedField = .password }
            )
            .focused($focusedField, equals: .email)
            .onChange(of: model.email) { _, _ in
                model.hasInteractedWithEmail = true
            }
            .task(id: model.email) {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    model.validateEmail()
                } catch {}
            }

            // MARK: Password
            SecureCustomTextField(
                isValid: model.passwordError == nil,
                errorMessage: model.passwordError,
                text: $model.password,
                placeholder: "password".localized(),
                backgroundColor: .goodGray,
                strokeColor: passwordStrokeColor,
                preset: .newPassword,
                submitLabel: .next,
                onSubmit: { focusedField = .confirmPassword }
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

            // MARK: Confirm Password
            SecureCustomTextField(
                isValid: model.confirmationPasswordError == nil,
                errorMessage: model.confirmationPasswordError,
                text: $model.confirmPassword,
                placeholder: "confirm_password".localized(),
                backgroundColor: .goodGray,
                strokeColor: confirmPasswordStrokeColor,
                preset: .newPassword,
                submitLabel: .done,
                onSubmit: handleSignUp
            )
            .focused($focusedField, equals: .confirmPassword)
            .onChange(of: model.confirmPassword) { _, _ in
                model.hasInteractedWithConfirmPassword = true
            }
            .task(id: model.confirmPassword) {
                do {
                    try await Task.sleep(for: .milliseconds(500))
                    model.validateConfirmPassword()
                } catch {}
            }
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("create_account_header".localized())
                .font(.title.bold())
            Text("create_account_subtext".localized())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stroke Color Logic
    private var usernameStrokeColor: Color? {
        model.isUsernameValid || (focusedField == .username && model.username.isEmpty) ? .brandGreen : nil
    }
    
    private var phoneStrokeColor: Color? {
        model.isPhoneValid || (focusedField == .phone && model.phone.isEmpty) ? .brandGreen : nil
    }
    
    private var emailStrokeColor: Color? {
        model.isEmailValid || (focusedField == .email && model.email.isEmpty) ? .brandGreen : nil
    }
    
    private var passwordStrokeColor: Color? {
        model.isPasswordValid || (focusedField == .password && model.password.isEmpty) ? .brandGreen : nil
    }
    
    private var confirmPasswordStrokeColor: Color? {
        model.isConfirmPasswordValid || (focusedField == .confirmPassword && model.confirmPassword.isEmpty) ? .brandGreen : nil
    }
}
