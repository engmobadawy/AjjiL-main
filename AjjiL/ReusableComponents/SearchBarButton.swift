//
//  StoreSearchBar.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/02/2026.
//

import SwiftUI
struct SearchBarButton: View {
    @Binding var text: String
    var placeholder: String = "Find The Store or Product"
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder).font(.custom("Poppins-Regular", size: 16))
            )
            .focused($isFocused)
            .submitLabel(.search)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .onSubmit { onSubmit?() }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.black.opacity(0.08), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
        .contentShape(.rect(cornerRadius: 8))
        .onTapGesture { isFocused = true }
    }
}


