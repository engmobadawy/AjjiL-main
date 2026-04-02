import SwiftUI

struct LogInView: View {
    @State private var toast: FancyToast?
    @State private var model: LoginViewModel = DependencyContainer.AuthDependency.shared.loginViewModel
    
    @State private var navigateToSignUp = false
    @State private var navigateOTP = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case phone, password
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopRow()
                
                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                            .padding(.bottom, 18)
                            .padding(.top, 28)
                        
                        formFields
                            .padding(.top, 28)
                            .padding(.bottom, 10)
                        
                        GreenButton(title: model.isLoading ? " " : "sign_in".localized(), action: handleSignIn)
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
                        
                        Button(action: handleForgotPassword) {
                            Text("forgot_password_question".localized())
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.customOrange)
                                .underline()
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.bottom, 24)
                        
                        VStack(spacing: 4) {
                            Text("dont_have_account".localized())
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            WhiteButton(title: "create_an_account".localized(), action: {
                                navigateToSignUp = true
                            })
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 25)
                }
                .scrollIndicators(.hidden)
                .onTapGesture { focusedField = nil }
            }
            .background(.white)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToSignUp) {
                SignUpView()
            }
            .navigationDestination(isPresented: $navigateOTP) {
                OTPView(
                    phoneNumber: model.phone,
                    flow: .forgotPassword,
                    onResendTapped: {},
                    onBack: { navigateOTP = false }
                )
            }
            .task {
                try? await Task.sleep(for: .seconds(0.5))
                focusedField = .phone
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("done".localized()) {
                        focusedField = nil
                        handleSignIn()
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
            .toastView(toast: $toast)
            .onChange(of: model.errorMessage) { _, newError in
                if let message = newError {
                    toast = FancyToast(type: .error, title: "error".localized(), message: message)
                    model.errorMessage = nil
                }
            }
        }
    }
}

private extension LogInView {
    func handleSignIn() {
        focusedField = nil
        Task {
            if await model.logIn() {
                await MainActor.run { MOLH.reset() }
            }
        }
    }
    
    func handleForgotPassword() {
        focusedField = nil
        model.validatePhone()
        
        if model.isPhoneValid {
            navigateOTP = true
        } else {
            toast = FancyToast(
                type: .error,
                title: "error".localized(),
                message: model.phoneError ?? "please_enter_phone_first".localized()
            )
        }
    }
    
    func showNextTextField() {
        if focusedField == .phone { focusedField = .password }
        else { handleSignIn() }
    }
    
    func showPreviousTextField() {
        if focusedField == .password { focusedField = .phone }
    }

    var formFields: some View {
            VStack(spacing: 18) {
                PhoneTextField(
                    isValid: model.phoneError == nil,
                    errorMessage: model.phoneError,
                    text: $model.phone.noSpaces,
                    backgroundColor: .goodGray,
                    strokeColor: phoneStrokeColor,
                    preset: .phone,
                    submitLabel: .next,
                    onSubmit: { focusedField = .password }
                )
                .focused($focusedField, equals: .phone)
                // 1. Detect actual user typing (does not fire on initial load)
                .onChange(of: model.phone) { _, _ in
                    model.hasInteractedWithPhone = true
                }
                // 2. Debounce the validation
                .task(id: model.phone) {
                    do {
                        try await Task.sleep(for: .milliseconds(500))
                        model.validatePhone()
                    } catch {
                        // Task cancelled cleanly by new typing
                    }
                }
                
                SecureCustomTextField(
                    isValid: model.passwordError == nil,
                    errorMessage: model.passwordError,
                    text: $model.password,
                    placeholder: "password".localized(),
                    backgroundColor: .goodGray,
                    strokeColor: passwordStrokeColor,
                    preset: .password,
                    submitLabel: .go,
                    onSubmit: handleSignIn
                )
                .focused($focusedField, equals: .password)
                .onChange(of: model.password) { _, _ in
                    model.hasInteractedWithPassword = true
                }
                .task(id: model.password) {
                    do {
                        try await Task.sleep(for: .milliseconds(500))
                        model.validatePassword()
                    } catch {
                       // Task cancelled cleanly by new typing
                    }
                }
            }
        }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("welcome_back_header".localized())
                .font(.custom("Poppins-Bold", size: 28))
            Text("welcome_subtext".localized())
                .font(.custom("Poppins-Regular", size: 18))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var phoneStrokeColor: Color? {
        model.isPhoneValid || (focusedField == .phone && model.phone.isEmpty) ? .brandGreen : nil
    }
    
    private var passwordStrokeColor: Color? {
        model.isPasswordValid || (focusedField == .password && model.password.isEmpty) ? .brandGreen : nil
    }
}
