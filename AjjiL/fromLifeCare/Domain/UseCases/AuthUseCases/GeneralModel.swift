//
//  GeneralModel.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 25/02/2026.
//



import Foundation

// MARK: - GeneralModel

struct GeneralModel: Codable {
    let status: Bool?
    let message: String?
  enum CodingKeys: String, CodingKey {
    case status = "status"
    case message = "message"
  }
}


// MARK: - StaticPagesModel
struct StaticPagesModel: Codable {
    let status: Bool?
    let message: String?
    let data: StaticPagesData?
}
// MARK: - StaticPagesData
struct StaticPagesData: Codable {
    let privacyPolicy: String?
    let terms: String?
    let aboutUs: String?
    let exchangePolicy: String?
    enum CodingKeys: String, CodingKey {
        case terms
        case privacyPolicy = "privacy_policy"
        case aboutUs = "about_us"
        case exchangePolicy = "exchange_policy"
    }
}


//MARK: - notificationList
//struct NotificationsModel: Codable {
//    let data: [NotificationsData]?
//    let count: Int?
//    let status: Bool?
//}
//
//// MARK: - NotificationsData
//struct NotificationsData: Codable {
//    let orderId, actionType, iconType,visitType, id, isRead, patientId,reportId: Int?
//    let title,  createdAt, body, data, time: String?
//}
// MARK: - Log

struct loginModel : Codable {
    let status: Bool?
    let message: String?
    let data: LoginData?
}

// MARK: - LoginData
//struct LoginData:Codable, Equatable {
//    var name, phone, email, profileImage, redeemPointsCount, redeemPointsPrice: String?
//    var status, accountType, activeNotification, uncompletedData, countPoints: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case name, email, phone,status
//        case profileImage = "profile_image"
//        case accountType = "account_type"
//        case activeNotification = "active_notification"
//        case uncompletedData = "uncompleted_data"
//        case countPoints = "count_points"
//        case redeemPointsCount = "redeem_points_count"
//        case redeemPointsPrice = "redeem_points_price"
//    }
//}

struct LoginData:Codable, Equatable {
      var name, email, phone, profileImage: String?
      var countPoints: Int?
      var redeemPointsCount, redeemPointsPrice: String?

      enum CodingKeys: String, CodingKey {
          case name, email, phone
          case profileImage = "profile_image"
          case countPoints = "count_points"
          case redeemPointsCount = "redeem_points_count"
          case redeemPointsPrice = "redeem_points_price"
      }
}


struct QuestionsListModel: Codable {
    let data: [QuestionsListData]?
    let message: String?
}

struct QuestionsListData: Codable, Identifiable {
    let id: Int?
    let question: String?
    let answer: String?
    var _isExpanded: Bool? // Private variable to hold the actual value

        var isExpanded: Bool {
            get {
                return _isExpanded ?? false // Return false if _isExpanded is nil
            }
            set {
                _isExpanded = newValue
            }
        }
}


// MARK: - ContactModel
struct ContactModel:Codable {
    let status: Bool?
    let message: String?
    let data: ContactData?
}

// MARK: - ContactData
struct ContactData: Codable{
    let problemId:Int?
    let email, message: String?
}

// MARK: - RegisterModel
struct RegisterModel: Codable {
    let status: Bool?
    let message: String?
    let data: RegisterDataModel?
}

// MARK: - RegisterDataModel
struct RegisterDataModel: Codable {
    let email, phone: [String]?
}


// MARK: - CountryCityModel
struct CountryCityModel: Codable  {
    let status: Bool?
    let message: String?
    let data: [CountryCityModelData]?
    let count: Int?
}

// MARK: - CountryCityModelData
struct CountryCityModelData : Codable, Equatable {
    let id: Int?
    let name: String?
}

