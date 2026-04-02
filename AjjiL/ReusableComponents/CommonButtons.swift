//
//  PrimaryActionButton.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 09/02/2026.
//


import SwiftUI

struct GreenButton: View {
    let title: String
    var isEnabled: Bool = true
    // Add optional background color with a default value (your brand green)
    var backgroundColor: Color = Color(red: 1/255, green: 150/255, blue: 131/255)
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Poppins-Bold", size: 18)) // Using your preferred Poppins font
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
        }
        // Pass the color into your custom ButtonStyle
        .buttonStyle(GreenActionButtonStyle(isEnabled: isEnabled, customColor: backgroundColor))
        .disabled(!isEnabled)
        .animation(.easeInOut, value: isEnabled)
        .padding(.top, 16)
    }
}

// Update your ButtonStyle to handle the custom color
struct GreenActionButtonStyle: ButtonStyle {
    var isEnabled: Bool
    var customColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(isEnabled ? customColor : .gray.opacity(0.5))
            .clipShape(.rect(cornerRadius: 12)) // Modern API usage
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}



struct WhiteButton: View {
    let title: String
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.brandGreen)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
        }
        .buttonStyle(WhiteActionButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
        .animation(.easeInOut, value: isEnabled)
        .padding(.top, 16)
//        .padding(.horizontal, 18)
    }
}




private struct WhiteActionButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white )
            }
            .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.brandGreen
                            , lineWidth: 1.5)
        }
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
    }
}
