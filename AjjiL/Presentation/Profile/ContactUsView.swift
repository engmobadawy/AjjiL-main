//
//  ContactUsView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 24/04/2026.
//

import SwiftUI

struct ContactUsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ContactUsViewModel
    
    // MARK: - State
    @State private var showSuccessSheet = false
    
    // MARK: - Focus
    private enum Field: Hashable {
        case email, message
    }
    @FocusState private var focusedField: Field?
    
    init(viewModel: ContactUsViewModel) {
        // Initialize the owned @Observable view model
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Row
            TopRowNotForHome(
                // 🛠️ FIX: Added .newlocalized
                title: "Contact us".newlocalized,
                showBackButton: true,
                kindOfTopRow: .none,
                onBack: {
                    dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Header Section
                    Image("getContact")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 248, height: 248)
                        .padding(.top, 28)
                        .padding(.bottom, 18)
                    
                    // 🛠️ FIX: Added .newlocalized
                    Text("Get In Touch".newlocalized)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    // 🛠️ FIX: Added .newlocalized
                    Text("Tell us about your inquiries".newlocalized)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                    
                    // MARK: - Form Fields
                    emailField
                    problemTypeMenu
                    messageField
                }
                .padding(.horizontal, 24)
            }
            .scrollIndicators(.hidden)
            .contentShape(.rect)
            .onTapGesture { focusedField = nil }
            
            // MARK: - Bottom Action Section
            bottomActionSection
        }
        .navigationBarBackButtonHidden()
        .task {
            await viewModel.fetchContactTypes()
        }
        // MARK: - Success Sheet Modifier
        .sheet(isPresented: $showSuccessSheet) {
            SuccessSheetView {
                showSuccessSheet = false
                dismiss()
            }
            .presentationDetents([.fraction(0.55), .medium])
            .presentationCornerRadius(28)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                // 🛠️ FIX: Added .newlocalized
                Button("Done".newlocalized) {
                    focusedField = nil
                }
                Spacer()
                Button {
                    focusedField = focusedField == .message ? .email : .message
                } label: {
                    Image(systemName: "chevron.up.chevron.down").foregroundStyle(.black)
                }
            }
        }
    }
}

// MARK: - Subviews
private extension ContactUsView {
    
    // MARK: - Email Field (Reusing CustomTextField)
    var emailField: some View {
        CustomTextField(
            isValid: viewModel.emailError == nil,
            errorMessage: viewModel.emailError,
            text: $viewModel.email,
            placeholder: "appssquare.com", // Usually domains aren't localized, but you can if needed
            icon: Image(systemName: "envelope.fill"),
            backgroundColor: Color(uiColor: .systemGray6),
            strokeColor: emailStrokeColor,
            preset: .email,
            submitLabel: .next,
            onSubmit: { focusedField = .message }
        )
        .focused($focusedField, equals: .email)
        .onChange(of: viewModel.email) { _, _ in
            viewModel.hasInteractedWithEmail = true
        }
        .task(id: viewModel.email) {
            do {
                try await Task.sleep(for: .milliseconds(500))
                viewModel.validateEmail()
            } catch {}
        }
    }
    
    // MARK: - Problem Type Menu
    var problemTypeMenu: some View {
        VStack(alignment: .leading, spacing: 6) {
            Menu {
                ForEach(viewModel.contactTypes) { type in
                    Button(type.name) {
                        viewModel.selectedContactTypeId = type.id
                        viewModel.hasInteractedWithType = true
                        viewModel.validateType()
                    }
                }
            } label: {
                HStack {
                    Text(selectedTypeName)
                        .foregroundStyle(viewModel.selectedContactTypeId == nil ? .gray : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.gray)
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.typeError != nil ? Color.red : (viewModel.isTypeValid ? .brandGreen : .clear), lineWidth: 1)
                }
            }
            
            // Error Message Underneath
            if let error = viewModel.typeError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 8)
            }
        }
    }
    
    // MARK: - Message Field
    var messageField: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 🛠️ FIX: Added .newlocalized
            TextField("Message".newlocalized, text: $viewModel.message, axis: .vertical)
                .lineLimit(5...8)
                .padding()
                .frame(minHeight: 120, alignment: .topLeading)
                .background(Color(uiColor: .systemGray6))
                .clipShape(.rect(cornerRadius: 12))
                .focused($focusedField, equals: .message)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.messageError != nil ? Color.red : (viewModel.isMessageValid ? .brandGreen : .clear), lineWidth: 1)
                }
                .onChange(of: viewModel.message) { _, _ in
                    viewModel.hasInteractedWithMessage = true
                }
                .task(id: viewModel.message) {
                    do {
                        try await Task.sleep(for: .milliseconds(500))
                        viewModel.validateMessage()
                    } catch {}
                }
            
            if let error = viewModel.messageError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 8)
            }
        }
    }
    
    var bottomActionSection: some View {
        VStack(spacing: 8) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            
            // 🛠️ FIX: Added .newlocalized
            GreenButton(title: viewModel.isLoading ? " " : "Send".newlocalized) {
                focusedField = nil
                Task {
                    await viewModel.submitForm()
                    if viewModel.successMessage != nil {
                        showSuccessSheet = true
                    }
                }
            }
            .disabled(!viewModel.isFormReady || viewModel.isLoading)
            .opacity((viewModel.isFormReady && !viewModel.isLoading) ? 1.0 : 0.45)
            .overlay {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isFormReady)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .padding(.top, 8)
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    // MARK: - Helpers
    var selectedTypeName: String {
        if let id = viewModel.selectedContactTypeId,
           let type = viewModel.contactTypes.first(where: { $0.id == id }) {
            return type.name
        }
        // 🛠️ FIX: Added .newlocalized
        return "Problem Type".newlocalized
    }
    
    private var emailStrokeColor: Color? {
        viewModel.isEmailValid || (focusedField == .email && viewModel.email.isEmpty) ? .brandGreen : nil
    }
}

@MainActor
@Observable
class ContactUsViewModel {
    // MARK: - Form State
    var email: String = ""
    var message: String = ""
    var selectedContactTypeId: Int?
    
    // MARK: - UI State
    var contactTypes: [ContactType] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var successMessage: String?
    
    // MARK: - Validation State
    var emailError: String?
    var typeError: String?
    var messageError: String?
    
    var isEmailValid = false
    var isTypeValid = false
    var isMessageValid = false
    
    // MARK: - Interaction Tracking
    var hasInteractedWithEmail = false
    var hasInteractedWithType = false
    var hasInteractedWithMessage = false
    var hasAttemptedSubmit = false
    
    // MARK: - Derived State
    var isFormReady: Bool {
        isEmailValid && isTypeValid && isMessageValid
    }
    
    // MARK: - Dependencies
    private let getContactTypesUseCase: GetContactTypesUseCase
    private let sendContactUsUseCase: SendContactUsUseCase
    
    init(getContactTypesUseCase: GetContactTypesUseCase,
         sendContactUsUseCase: SendContactUsUseCase) {
        self.getContactTypesUseCase = getContactTypesUseCase
        self.sendContactUsUseCase = sendContactUsUseCase
    }
    
    // MARK: - Validation Logic
    func validateEmail() {
        runValidation(hasInteracted: hasInteractedWithEmail, isValid: &isEmailValid, error: &emailError) {
            if email.trimmingCharacters(in: .whitespaces).isEmpty {
                throw ContactFormError.emptyEmail
            }
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if !emailPred.evaluate(with: email) {
                throw ContactFormError.invalidEmail
            }
        }
    }
    
    func validateType() {
        runValidation(hasInteracted: hasInteractedWithType, isValid: &isTypeValid, error: &typeError) {
            if selectedContactTypeId == nil {
                throw ContactFormError.emptyType
            }
        }
    }
    
    func validateMessage() {
        runValidation(hasInteracted: hasInteractedWithMessage, isValid: &isMessageValid, error: &messageError) {
            if message.trimmingCharacters(in: .whitespaces).isEmpty {
                throw ContactFormError.emptyMessage
            }
            if message.count < 10 {
                throw ContactFormError.shortMessage
            }
        }
    }
    
    func validateAll() -> Bool {
        hasAttemptedSubmit = true
        validateEmail()
        validateType()
        validateMessage()
        return isFormReady
    }
    
    // MARK: - Actions
    func fetchContactTypes() async {
        isLoading = true
        errorMessage = nil
        do {
            contactTypes = try await getContactTypesUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func submitForm() async {
        guard validateAll() else { return }
        guard let typeId = selectedContactTypeId else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let response = try await sendContactUsUseCase.execute(
                email: email,
                message: message,
                contactTypeId: typeId
            )
            successMessage = response
            
            hasAttemptedSubmit = false
            hasInteractedWithEmail = false
            hasInteractedWithType = false
            hasInteractedWithMessage = false
            validateEmail()
            validateType()
            validateMessage()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
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
        } catch let caughtError {
            updateState(isValid: &isValid, error: &error, newValid: false, newError: caughtError.localizedDescription)
        }
    }
    
    private func updateState(isValid: inout Bool, error: inout String?, newValid: Bool, newError: String?) {
        if isValid != newValid { isValid = newValid }
        if error != newError { error = newError }
    }
}

// MARK: - Private Error Enum
private enum ContactFormError: LocalizedError {
    case emptyEmail
    case invalidEmail
    case emptyType
    case emptyMessage
    case shortMessage
    
    var errorDescription: String? {
        switch self {
        // 🛠️ FIX: Added .newlocalized
        case .emptyEmail: return "Please enter your email.".newlocalized
        case .invalidEmail: return "Please enter a valid email address.".newlocalized
        case .emptyType: return "Please select a problem type.".newlocalized
        case .emptyMessage: return "Please enter your message.".newlocalized
        case .shortMessage: return "Message must be at least 10 characters.".newlocalized
        }
    }
}

struct SuccessSheetView: View {
    var onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image("SavedSuccessfully")
                .resizable()
                .scaledToFit()
                .frame(width: 247, height: 199)
            
            // 🛠️ FIX: Added .newlocalized
            Text("Sent Successfully".newlocalized)
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundStyle(Color(red: 65/255, green: 142/255, blue: 125/255))
            
            Spacer()
            
            // 🛠️ FIX: Added .newlocalized
            GreenButton(title: "Done".newlocalized) {
                onDone()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .padding(.top, 24)
        .background(Color(uiColor: .systemBackground))
    }
}
