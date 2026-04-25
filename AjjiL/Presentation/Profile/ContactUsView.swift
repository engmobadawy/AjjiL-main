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
    
    init(viewModel: ContactUsViewModel) {
        // Initialize the owned @Observable view model
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Row
            TopRowNotForHome(
                title: "Contact us",
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
                    
                    Text("Get In Touch")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text("Tell us about your inquiries")
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
            
            // MARK: - Bottom Action Section
            bottomActionSection
        }
        .navigationBarBackButtonHidden()
        .task {
            // Fetch the picker options when the view appears
            await viewModel.fetchContactTypes()
        }
    }
}

// MARK: - Subviews
private extension ContactUsView {
    
    var emailField: some View {
        HStack {
            Image(systemName: "envelope.fill")
                .foregroundStyle(.gray)
            
            TextField("appssquare.com", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .clipShape(.rect(cornerRadius: 12))
    }
    
    var problemTypeMenu: some View {
        Menu {
            ForEach(viewModel.contactTypes) { type in
                Button(type.name) {
                    viewModel.selectedContactTypeId = type.id
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
        }
    }
    
    var messageField: some View {
        TextField("Message", text: $viewModel.message, axis: .vertical)
            .lineLimit(5...8)
            .padding()
            .frame(minHeight: 120, alignment: .topLeading)
            .background(Color(uiColor: .systemGray6))
            .clipShape(.rect(cornerRadius: 12))
    }
    
    var bottomActionSection: some View {
        VStack(spacing: 8) {
            // Status Messages
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            
            if let success = viewModel.successMessage {
                Text(success)
                    .font(.caption)
                    .foregroundStyle(.green)
                    .padding(.horizontal)
            }
            
            // Send Button
            GreenButton(title: "Send") {
                Task {
                    await viewModel.submitForm()
                }
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.6 : 1.0)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .padding(.top, 8)
        }
        .background(Color(uiColor: .systemBackground)) 
    }
    
    // Helper property to resolve the selected picker text
    var selectedTypeName: String {
        if let id = viewModel.selectedContactTypeId,
           let type = viewModel.contactTypes.first(where: { $0.id == id }) {
            return type.name
        }
        return "Problem Type"
    }
}