//
//  TextInputPreset.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 14/02/2026.
//


import SwiftUI

public enum TextInputPreset: Sendable {
    case `default`
    case name
    case username
    case email
    case phone
    case number
    case url
    case password
    case newPassword
    case oneTimeCode

    var keyboardType: UIKeyboardType {
        switch self {
        case .email: .emailAddress
        case .phone: .phonePad
        case .number: .numberPad
        case .url: .URL
        default: .default
        }
    }

    var contentType: UITextContentType? {
        switch self {
        case .name: .name
        case .username: .username
        case .email: .emailAddress
        case .phone: .telephoneNumber
        case .url: .URL
        case .password: .password
        case .newPassword: .newPassword
        case .oneTimeCode: .oneTimeCode
        default: nil
        }
    }

    var capitalization: TextInputAutocapitalization {
        switch self {
        case .name: .words
        case .email, .username, .url, .password, .newPassword, .oneTimeCode: .never
        default: .sentences
        }
    }

    var disableAutocorrection: Bool {
        switch self {
        case .email, .username, .url, .number, .phone, .password, .newPassword, .oneTimeCode: true
            
        default: false
        }
    }
}

private struct TextInputPresetModifier: ViewModifier {
    let preset: TextInputPreset

    func body(content: Content) -> some View {
        content
            .textInputAutocapitalization(preset.capitalization)
            .autocorrectionDisabled(preset.disableAutocorrection)
            .keyboardType(preset.keyboardType)
            .textContentType(preset.contentType)
    }
}

public extension View {
    func textInputPreset(_ preset: TextInputPreset) -> some View {
        modifier(TextInputPresetModifier(preset: preset))
    }
}
