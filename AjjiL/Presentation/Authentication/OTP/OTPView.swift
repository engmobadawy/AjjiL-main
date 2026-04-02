import SwiftUI
import MOLH


enum OTPFlow {
    case signUp
    case forgotPassword
}

struct OTPView: View {
    // MARK: - Properties
    let phoneNumber: String
    let flow: OTPFlow
    
    let onResendTapped: () -> Void
    let onBack: () -> Void
    
    @State private var navigateNext = false
    @State private var model = OTPViewModel()
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case code
    }

    var body: some View {
        VStack(spacing: 0) {
            TopRowWithBack(onBack: onBack)
                    
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 28)
                        .padding(.bottom, 18)
                    
                    formFields
                        .padding(.bottom, 10)
                    
                    resendSection
                        .padding(.top, 8)
                        .padding(.bottom, 24)

                    GreenButton(title: "Verify...", action: handleVerification)
                        .opacity(model.isFormReady ? 1.0 : 0.45)
                        .disabled(!model.isFormReady)
                        .animation(.easeInOut(duration: 0.2), value: model.isFormReady)
                        .padding(.bottom, 24)
                    
                    Text(model.formattedTime)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .padding(.bottom, 24)
                }
                .padding(.top, 48)
                .padding(.horizontal, 18)
            }
            .scrollIndicators(.hidden)
            .background(.white, in: .rect(cornerRadius: 28))
            .contentShape(.rect)
            .onTapGesture { focusedField = nil }
            .navigationDestination(isPresented: $navigateNext) {
                // We only need navigation destination for forgot password now
                if flow == .forgotPassword {
                    ForgetPasswordView(onBack: {
                        navigateNext = false
                    })
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            model.startTimer()
            try? await Task.sleep(for: .seconds(0.5))
            focusedField = .code
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("done".localized()) {
                    hideKeyboard()
                    handleVerification()
                }
            }
        }
    }
}

// MARK: - Logic & Actions
private extension OTPView {
    func handleVerification() {
            hideKeyboard()
            Task {
                // Pass the flow to the view model so it knows whether to save a token
                if await model.verifyCode(for: flow) {
                    if flow == .signUp {
                        // Trigger root view change to LogInView
                        await MainActor.run {
                            // 1. Explicitly ensure no token exists
                            GenericUserDefault.shared.removeValue(Constants.shared.token) // Use the exact key you use for tokens
                            
                            // 2. Reset the app window. Without a token, AppDelegate will route to LogInView.
                            MOLH.reset()
                        }
                    } else {
                        // Continue to ForgetPasswordView
                        navigateNext = true
                    }
                }
            }
        }
    
    func handleResend() {
        model.resendCode()
        onResendTapped()
        focusedField = .code
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Subviews
private extension OTPView {
    var headerSection: some View {
        VStack(spacing: 0) {
            Image("Verfication")
                .resizable()
                .scaledToFit()
                .frame(height: 230)

            Text("verification_code_header".localized())
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 38)

            // Using string interpolation securely with the custom .localized() return
            Text("\("otp_sent_message".localized()) \(phoneNumber)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
    }
    
    var formFields: some View {
        CustomTextField(
            isValid: model.errorMessage == nil,
            errorMessage: model.errorMessage,
            text: $model.code,
            placeholder: "apply_code".localized(),
            backgroundColor: Color(.goodGray)
        )
        .keyboardType(.numberPad)
        .focused($focusedField, equals: .code)
        .onChange(of: model.code) { model.errorMessage = nil }
    }
    
    var resendSection: some View {
        HStack(spacing: 4) {
            Text("didnt_receive_code".localized())
                .foregroundStyle(.secondary)

            Button(action: handleResend) {
                Text("resend_it".localized())
                    .underline()
                    .foregroundStyle(.orange)
            }
            .disabled(model.isTimerRunning)
            .opacity(model.isTimerRunning ? 0.6 : 1.0)
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
