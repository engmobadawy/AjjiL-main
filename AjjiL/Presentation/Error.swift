//
//  eror.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 12/03/2026.
//

import Foundation

extension Error {
    func mapErrorToMessage() -> String {
        // If the error is our specific ValidationError, handle its cases
        if let validationError = self as? ValidationError {
            switch validationError {
            case .invalidUsername:
                return "invalid_username_message".localized()
            case .invalidEmail:
                return "invalid_email_message".localized()
            case .invalidPhoneNumber:
                return "invalid_phone_message".localized()
            case .invalidCode:
                return "invalid_code_message".localized()
            case .invalidPassword:
                return "invalid_password_message".localized()
            case .invalidNewPassword:
                return "invalid_new_password_message".localized()
            case .invalidOldPassword:
                return "invalid_old_password_message".localized()
            case .newPasswordSameAsOldPassword:
                return "password_same_as_old_message".localized()
            case .passwordMismatch:
                return "password_mismatch_message".localized()
            case .missingRequiredField(let message):
                return message
            }
        }
        
        // Fallback for unexpected errors
        return self.localizedDescription
    }
}
