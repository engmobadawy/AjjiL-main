//
// ValidationError+Extension.swift
//

import Foundation

extension Result where Failure == ValidationError {
    func mapErrorToMessage() -> String? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error.mapValidationErrorToMessage()
        }
    }
}

extension ValidationError {
    func mapValidationErrorToMessage() -> String {
        switch self {
        case .invalidUsername:
          return "username_msg".localized()
        case .invalidEmail:
          return "email_msg".localized()
        case .invalidPhoneNumber:
          return "phone_msg".localized()
        case .invalidCode:
          return "code_msg".localized()
        case .invalidPassword:
          return "password_msg".localized()
        case .passwordMismatch:
          return "confirm_password_msg".localized()
        case .invalidNewPassword:
          return "empty_new_password".localized()
        case .invalidOldPassword:
          return "empty_old_password".localized()
        case .newPasswordSameAsOldPassword: 
          return "old_password_new_password".localized()
        case .missingRequiredField(let emptyMessage):
          return emptyMessage
        }
    }
}
