//
//  LoginModel.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 25/02/2026.
//




import Foundation

// MARK: - LoginModel
struct LoginModel: Codable {
   
        let token: String
        let userId: Int
        let isCashier: Bool
        let branch: String?
        
        enum CodingKeys: String, CodingKey {
            case token
            case userId = "user_id"
            case isCashier = "is_cashier"
            case branch
        }
    }

// MARK: - DataClass
struct UserData: Codable {
    var id, uncompletedData: Int?
    var email: String?
    var profileImage: String?
    var name: String?
    var address: String?
    var mrNum: String?
    var firstLogin: Int?
    enum CodingKeys: String, CodingKey {
        case id
        case uncompletedData = "uncompleted_data"
        case profileImage = "profile_image"
        case mrNum = "mr_num"
        case name
        case address
        case email
        case firstLogin = "first_login"
    }
}

