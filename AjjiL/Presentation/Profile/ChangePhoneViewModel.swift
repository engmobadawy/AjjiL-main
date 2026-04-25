//
//  ChangePhoneViewModel.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/04/2026.
//


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




import SwiftUI

struct ChangePhoneView: View {
    @State private var model: ChangePhoneViewModel
    @State private var toast: FancyToast?
    @State private var navigateToOTP = false
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    init() {
        // Initialize dependencies locally to keep them out of the global container
        let validationUseCase = DependencyContainer.ValidationDependency.shared.userValidationUseCase
        let networkService = DependencyContainer.shared.networkService
        let profileRepo = ProfileRepositoryImp(networkService: networkService)
        let changePhoneUseCase = ChangePhoneUseCase(profileRepo: profileRepo)
        
        let vm = ChangePhoneViewModel(
            userValidationUseCase: validationUseCase,
            changePhoneUseCase: changePhoneUseCase
        )
        _model = State(initialValue: vm)
    }
    
    private enum Field: Hashable, CaseIterable {
        case phone, password
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopRowNotForHome(title: "Change Phone Number".localized(), showBackButton: true, kindOfTopRow: .justNotification
                ,onBack: {
                    dismiss()
                }
                
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        formFields
                        
                        GreenButton(title: model.isLoading ? " " : "Save".localized(), action: handleSave)
                            .disabled(!model.isFormValid || model.isLoading)
                            .opacity((model.isFormValid && !model.isLoading) ? 1.0 : 0.45)
                            .overlay {
                                if model.isLoading {
                                    ProgressView().tint(.white)
                                }
                            }
                            .animation(.easeInOut(duration: 0.2), value: model.isLoading)
                            .animation(.easeInOut(duration: 0.2), value: model.isFormValid)
                            .padding(.top, 8)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 18)
                }
                .scrollIndicators(.hidden)
                .background(.white)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Done".localized()) {
                        hideKeyboard()
                        handleSave()
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
                focusedField = .phone
            }
            .navigationBarBackButtonHidden(true)
            .toastView(toast: $toast)
            .onChange(of: model.errorMessage) { _, newError in
                if let message = newError {
                    toast = FancyToast(type: .error, title: "error".localized(), message: message)
                    model.errorMessage = nil
                }
            }
            .onChange(of: model.successMessage) { _, newSuccess in
                if let message = newSuccess {
                    toast = FancyToast(type: .success, title: "success".localized(), message: message)
                    model.successMessage = nil
                }
            }
            .navigationDestination(isPresented: $navigateToOTP) {
                // Adjust parameters here to match your exact OTPView requirements
//                OTPView(
//                    phoneNumber: model.phone,
//                    flow: .changePhone, // Assuming you add a .changePhone case to your Flow enum
//                    onResendTapped: {
//                        // Re-trigger the change phone API call to send a new code
//                        Task { await model.savePhone() }
//                    },
//                    onBack: { navigateToOTP = false }
//                )
            }
        }
    }
    
    var formFields: some View {
        VStack(spacing: 20) {
            
            // 1. Phone Field
            VStack(alignment: .leading, spacing: 8) {
                fieldHeader(title: "Type Your New Phone Number".localized())
                
                PhoneTextField(
                    isValid: model.phoneError == nil,
                    errorMessage: model.phoneError,
                    text: $model.phone, // Add .noSpaces if you use that extension from LogInView
                    backgroundColor: .goodGray,
                    strokeColor: phoneStrokeColor,
                    preset: .phone,
                    submitLabel: .next,
                    onSubmit: { focusedField = .password }
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
            }
            
            // 2. Password Field
            VStack(alignment: .leading, spacing: 8) {
                fieldHeader(title: "Write Your Password To Confirm".localized())
                
                SecureCustomTextField(
                    isValid: model.passwordError == nil,
                    errorMessage: model.passwordError,
                    text: $model.password,
                    placeholder: "password".localized(),
                    backgroundColor: .goodGray,
                    strokeColor: passwordStrokeColor,
                    preset: .password,
                    submitLabel: .done,
                    onSubmit: handleSave
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
            }
        }
    }
}

// MARK: - Private Methods & Helpers
private extension ChangePhoneView {
    
    func fieldHeader(title: String) -> some View {
        Text(title)
            .font(.custom("Poppins-SemiBold", size: 16))
            .foregroundStyle(.black.opacity(0.85))
    }
    
    func handleSave() {
        focusedField = nil
        Task {
            if await model.savePhone() {
                // Wait slightly for the toast to be readable before navigation
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    navigateToOTP = true
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
    
    private var phoneStrokeColor: Color? {
        model.isPhoneValid || (focusedField == .phone && model.phone.isEmpty) ? .brandGreen : nil
    }
    
    private var passwordStrokeColor: Color? {
        model.isPasswordValid || (focusedField == .password && model.password.isEmpty) ? .brandGreen : nil
    }
}
