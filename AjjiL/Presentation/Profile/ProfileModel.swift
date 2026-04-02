//
//  ProfileResponseModel.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/03/2026.
//


import Foundation

// MARK: - Network DTOs
struct ProfileModel: Codable {
    let status: Bool?
    let message: String?
    let data: ProfileData?
}

struct ProfileData: Identifiable, Codable {
    var id: Int?
    var name: String?
    var email: String?
    var phone: String?
    var phoneNumber: String?
    var isActive: Int?
    var referralCode: String?
    var registeredWithReferralCode: String?
    var smsVerified: Int?
    var photo: String?
    var points: Int?
    var device: String?
    var addresses: [AddressData]?
    var isCashier: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case phoneNumber = "phone_number"
        case isActive = "is_active"
        case referralCode = "referral_code"
        case registeredWithReferralCode = "registered_with_referralcode"
        case smsVerified = "sms_verified"
        case photo
        case points
        case device
        case addresses
        case isCashier = "is_cashier"
    }
}

struct AddressData: Identifiable, Codable {
    var id: Int?
    // Add future address fields here based on your API
}

// MARK: - Domain Entities
struct ProfileEntity: Identifiable, Hashable {
    var id: Int
    var name: String
    var email: String
    var phone: String
    var phoneNumber: String
    var isActive: Bool
    var referralCode: String
    var registeredWithReferralCode: Bool
    var smsVerified: Bool
    var photoURL: String
    var points: Int
    var device: String
    var addresses: [AddressEntity]
    var isCashier: Bool
}

struct AddressEntity: Identifiable, Hashable {
    var id: Int
    // Add future address fields here
}

// MARK: - Mappers
extension ProfileModel {
    func map() -> ProfileEntity? {
        return data?.map()
    }
}

extension ProfileData {
    func map() -> ProfileEntity {
        ProfileEntity(
            id: self.id ?? 0,
            name: self.name ?? "Unknown",
            email: self.email ?? "",
            phone: self.phone ?? "",
            phoneNumber: self.phoneNumber ?? "",
            isActive: self.isActive == 1,
            referralCode: self.referralCode ?? "",
            registeredWithReferralCode: self.registeredWithReferralCode == "1",
            smsVerified: self.smsVerified == 1,
            photoURL: self.photo ?? "",
            points: self.points ?? 0,
            device: self.device ?? "",
            addresses: self.addresses?.compactMap { $0.map() } ?? [],
            isCashier: self.isCashier ?? false
        )
    }
}

extension AddressData {
    func map() -> AddressEntity {
        AddressEntity(
            id: self.id ?? 0
        )
    }
}
