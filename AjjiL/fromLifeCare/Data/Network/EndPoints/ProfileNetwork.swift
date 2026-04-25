import Foundation

enum ProfileNetwork {
    case getProfile
    case updateProfileInfo(name: String, email: String)
    case updateProfileImage(imageData: Data)
    case changePassword(current: String, new: String, confirm: String)
    
    // MARK: - New Endpoints
    case changePhone(newPhone: String, password: String)
    case verifyChangePhone(newPhone: String, code: String)
    case getPromoCodes
}

extension ProfileNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case .getProfile, .updateProfileInfo, .updateProfileImage:
            return "profile"
        case .changePassword:
            return "profile/change-password"
        case .changePhone:
            return "profile/change-phone"
        case .verifyChangePhone:
            return "profile/change-phone/verify"
        case .getPromoCodes:
                    return "promo-codes"
        }
    }

    var methods: HTTPMethod {
            switch self {
            case .getProfile, .getPromoCodes:
                return .get
            case .updateProfileInfo, .updateProfileImage, .changePassword, .changePhone, .verifyChangePhone:
                return .post
            }
        }
    var task: TaskRequest {
        switch self {
        case .getProfile, .getPromoCodes:
            return .requestPlain
            
        case .updateProfileInfo(let name, let email):
            let params: [String: Any] = [
                "name": name,
                "email": email
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
            
        case .updateProfileImage(let imageData):
            let base64String = imageData.base64EncodedString()
            let params: [String: Any] = [
                "photo": "data:image/jpeg;base64,\(base64String)"
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
            
        case .changePassword(let current, let new, let confirm):
            let params: [String: Any] = [
                "current_password": current,
                "password": new,
                "password_confirmation": confirm
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
            
        // MARK: - New Tasks
        case .changePhone(let newPhone, let password):
            let params: [String: Any] = [
                "new_phone": newPhone,
                "password": password
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
            
        case .verifyChangePhone(let newPhone, let code):
            let params: [String: Any] = [
                "new_phone": newPhone,
                "code": code
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}

// MARK: - Responses

struct ChangePasswordResponse: Decodable {
    let status: Bool?
    let message: String?
}

// You can use this for both the change-phone and verify endpoints
// since the structure (status, message) is the same in your screenshots.
struct ChangePhoneResponse: Decodable {
    let status: Bool?
    let message: String?
}





import Foundation

// MARK: - Promo Codes Response
struct PromoCodesResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: [PromoCodeDTO]?
}

// MARK: - Promo Code DTO
struct PromoCodeDTO: Decodable {
    let id: Int?
    let code: String?
    let type: Int?
    let value: Double?
    let expirationDate: String?
    let isUsed: Bool?
    let stores: [StoreDTO]?
    
    enum CodingKeys: String, CodingKey {
        case id, code, type, value, stores
        case expirationDate = "expiration_date"
        case isUsed = "is_used"
    }
}

// MARK: - Store DTO
struct StoreDTO: Decodable {
    let id: Int?
    let name: String?
    let image: String?
    let rateAvg: String?
    let rateCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, image
        case rateAvg = "rate_avg"
        case rateCount = "rate_count"
    }
}
