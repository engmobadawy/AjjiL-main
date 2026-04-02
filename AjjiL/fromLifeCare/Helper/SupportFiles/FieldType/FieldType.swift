//  LifeCare
//
//  FieldType.swift
//
//  Created by: M.Magdy on 5/5/25.
//

import Foundation
import SwiftUI

protocol FieldTypeProtocol {
    var title: String { get }
    var placeholder: String { get }
    var leftIcon: Image? { get }
    var keyboardType: UIKeyboardType { get }
    var isSecure: Bool { get }
}

enum FieldType: FieldTypeProtocol {
    case username
    case email
    case phone
    case password
    case confirmPassword
    case code
    case oldPassword
    case newPassword
    case confirmNewPassword
    case newPhone
    case employeeId
    case employeeIdPhoto
    case nationalId
    case iban
    case uploadImage
    case agree
    case complaint
    // Medical Info Cases
    case height
    case weight
    case medication
    case policyholderName
    case policyId
    case memberId
    case dateOfBirth
    case reportName
    case companyName
    
    // Bank Account Cases
    case accountHolderName
    case bankName
    case accountNumber
    
    // Vital Signs Cases
    case systolic
    case diastolic
    case heartRate
    case temperature
    case bloodOxygen
    case breathingRate
    case custom(placeholder: String, keyboardType: UIKeyboardType)
    
    var title: String {
        switch self {
        case .username: return "Full Name".localized()
        case .email: return "email".localized()
        case .phone: return "phone_number".localized()
        case .password: return "password".localized()
        case .confirmPassword: return "confirm_password".localized()
        case .oldPassword: return "old_password".localized()
        case .newPassword: return "new_password".localized()
        case .confirmNewPassword: return "confirm_new_password".localized()
        case .newPhone: return "phone_number".localized()
        case .employeeId: return "employee_id".localized()
        case .nationalId: return "national_id".localized()
        case .iban: return "IBAN".localized()
        case .uploadImage: return "upload_image".localized()
        case .agree: return "agree".localized()
        case .employeeIdPhoto: return "employeePhoto".localized()
        case .complaint: return "complaint".localized()
        case .height: return "Height (Cm)".localized()
        case .weight: return "Weight (Kg)".localized()
        case .medication: return "Current Medications".localized()
        case .code: return "code".localized()
        case .policyholderName: return "Policyholder Name".localized()
        case .policyId: return "Policy ID Number".localized()
        case .memberId: return "Member ID Number".localized()
        case .reportName: return "Report Name".localized()
        case .dateOfBirth: return "Date of Birth".localized()
        case .companyName: return "Company Name".localized()
        case .accountHolderName: return "Account Holder Name".localized()
        case .bankName: return "Bank Name".localized()
        case .accountNumber: return "Account Number".localized()
        case .systolic: return "Systolic".localized()
        case .diastolic: return "Diastolic".localized()
        case .heartRate: return "Heart Rate".localized()
        case .temperature: return "Temperature".localized()
        case .bloodOxygen: return "Blood Oxygen".localized()
        case .breathingRate: return "Breathing Rate".localized()
        case .custom(let placeholder, _): return placeholder
        }
    }

    var placeholder: String {
        switch self {
        case .username: return "Full Name".localized()
        case .email: return "email".localized()
        case .phone: return "phone_number_PH".localized()
        case .password: return "password_PH".localized()
        case .confirmPassword: return "confirm_password_PH".localized()
        case .oldPassword: return "old_password_PH".localized()
        case .newPassword: return "new_password_PH".localized()
        case .confirmNewPassword: return "confirm_new_password_PH".localized()
        case .newPhone: return "new_phone_PH".localized()
        case .employeeId: return "employee_id_PH".localized()
        case .nationalId: return "national_id_PH".localized()
        case .iban: return "Enter IBAN number".localized()
        case .uploadImage: return "image_PH".localized()
        case .employeeIdPhoto: return "employee_PH".localized()
        case .complaint: return "complaint".localized()
        case .height: return "Please enter height".localized()
        case .weight: return "Please enter weight".localized()
        case .medication: return "Type the medication name".localized()
        case .code: return "code_PH".localized()
        case .agree: return "".localized()
        case .policyholderName: return "Please enter full name".localized()
        case .policyId: return "Enter policy ID".localized()
        case .memberId: return "Enter member ID".localized()
        case .reportName: return "enter_report_name_PH".localized()
        case .dateOfBirth: return "enter date of Birth".localized()
        case .companyName: return "enter_company_name_PH".localized()
        case .accountHolderName: return "Enter account holder name".localized()
        case .bankName: return "Select bank name".localized()
        case .accountNumber: return "Enter account number".localized()
        case .systolic: return "Systolic".localized()
        case .diastolic: return "Diastolic".localized()
        case .heartRate: return "Enter heart rate".localized()
        case .temperature: return "Enter temperature".localized()
        case .bloodOxygen: return "Enter oxygen level".localized()
        case .breathingRate: return "Enter breathing rate".localized()
        case .custom(let placeholder, _): return placeholder
        }
    }

    var leftIcon: Image? {
        return Image("")
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        case .phone, .newPhone, .policyId, .memberId, .accountNumber:
            return .numberPad
        case .height, .weight, .temperature:
            return .decimalPad
        case .systolic, .diastolic, .heartRate, .bloodOxygen, .breathingRate:
            return .numberPad
        case .medication, .accountHolderName, .bankName:
            return .default
        case .iban:
            return .asciiCapable
        case .custom(_, let keyboardType):
            return keyboardType
        default:
            return .default
        }
    }
    
    var isSecure: Bool {
        switch self {
        case .password, .confirmPassword, .oldPassword, .newPassword, .confirmNewPassword:
            return true
        default:
            return false
        }
    }
}
