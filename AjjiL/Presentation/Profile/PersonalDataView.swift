//
//  Personal Data.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 18/02/2026.
//
import SwiftUI

struct PersonalDataView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: PersonalDataViewModel
    @State private var successItem: SuccessSheetItem?
    
    var onSaveSuccess: () -> Void
    
    init(
        updateProfileInfoUC: UpdateProfileInfoUC,
        username: String = "",
        email: String = "",
        profileImage: UIImage? = nil,
        onSaveSuccess: @escaping () -> Void = {}
    ) {
        self.onSaveSuccess = onSaveSuccess
        _model = State(initialValue: PersonalDataViewModel(
            updateProfileInfoUC: updateProfileInfoUC,
            username: username,
            email: email,
            profileImage: profileImage
        ))
    }
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable { case username, email }
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "Personal Data",
                showBackButton: true,
                kindOfTopRow: .justNotification,
                onBack: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 28) {
                    Text("Your Registration Data")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                    
                    StoresAvatarView(image: model.profileImage)
                        .padding(.vertical, 10)
                    
                    formFields
                    
                    GreenButton(
                        title: model.isLoading ? " " : "Save",
                        backgroundColor: Color(red: 142/255, green: 166/255, blue: 161/255)
                    ) {
                        Task {
                            if await model.saveChanges() {
                                // Trigger the success sheet instead of dismissing immediately
                                successItem = SuccessSheetItem()
                            }
                        }
                    }
                    .disabled(!model.isFormReady || model.isLoading)
                    .overlay {
                        if model.isLoading { ProgressView().tint(.white) }
                    }
                  
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 28)
            }
            .scrollIndicators(.hidden)
            .contentShape(.rect)
            .onTapGesture { focusedField = nil }
            .background(.background)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("done".localized()) { focusedField = nil }
                Spacer()
                Button(action: showPreviousTextField) { Image(systemName: "chevron.up").foregroundStyle(.black) }
                Button(action: showNextTextField) { Image(systemName: "chevron.down").foregroundStyle(.black) }
            }
        }
        // Attach the sheet modifier here
        .sheet(item: $successItem) { _ in
            SuccessSheetVieww(onDone: {
                onSaveSuccess()
                dismiss()
            })
            .background(.white)
        }
    }
}

// MARK: - Logic & Subviews
private extension PersonalDataView {
    var formFields: some View {
        VStack(spacing: 18) {
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
                onSubmit: { focusedField = .email }
            )
            .focused($focusedField, equals: .username)
            .onChange(of: model.username) { _, _ in model.hasInteractedWithUsername = true }
            .task(id: model.username) {
                try? await Task.sleep(for: .milliseconds(500))
                model.validateUsername()
            }
            
            CustomTextField(
                isValid: model.emailError == nil,
                errorMessage: model.emailError,
                text: $model.email,
                placeholder: "email_placeholder".localized(),
                icon: Image(systemName: "envelope.fill"),
                backgroundColor: .goodGray,
                strokeColor: emailStrokeColor,
                preset: .email,
                submitLabel: .done,
                onSubmit: { focusedField = nil }
            )
            .focused($focusedField, equals: .email)
            .onChange(of: model.email) { _, _ in model.hasInteractedWithEmail = true }
            .task(id: model.email) {
                try? await Task.sleep(for: .milliseconds(500))
                model.validateEmail()
            }
        }
    }
    
    private var usernameStrokeColor: Color? {
        model.isUsernameValid || (focusedField == .username && model.username.isEmpty) ? .brandGreen : nil
    }
    
    private var emailStrokeColor: Color? {
        model.isEmailValid || (focusedField == .email && model.email.isEmpty) ? .brandGreen : nil
    }
    
    func showNextTextField() {
        if focusedField == .username { focusedField = .email } else { focusedField = nil }
    }
    
    func showPreviousTextField() {
        if focusedField == .email { focusedField = .username } else { focusedField = nil }
    }
}

// MARK: - Success Sheet Components

// A simple model to drive the sheet presentation safely
struct SuccessSheetItem: Identifiable {
    let id = UUID()
}

struct SuccessSheetVieww: View {
    @Environment(\.dismiss) private var dismiss
    var onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image("saved")
                .resizable()
                .scaledToFit()
                .frame(width: 275, height: 179)
            
            Text("Saved Successfully")
                .font(.system(size: 28, weight: .semibold))
                // Using the same theme color as your save button for consistency
                .foregroundStyle(Color(red: 142/255, green: 166/255, blue: 161/255))
            
            Spacer()
            
            GreenButton(title: "Done", action: {
                dismiss() // Sheet dismisses itself first
                onDone()  // Then triggers the parent to close
            })
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
    }
}
