//
//  CouponsNetwork.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//


//  CouponsNetwork.swift
import Foundation

enum CouponsNetwork {
    case getCoupons(search: String?)
    case getCouponBranches(couponId: Int)
    case getCouponStores(couponId: Int)
}

extension CouponsNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case .getCoupons:
            return "coupons"
        case .getCouponBranches(let id):
            return "coupons/\(id)/branches"
        case .getCouponStores(let id):
            return "coupons/\(id)/stores"
        }
    }

    var methods: HTTPMethod {
        return .get
    }

    var task: TaskRequest {
        switch self {
        case .getCoupons(let search):
            // Only attach the parameter if a search string is actually provided
            if let search = search, !search.isEmpty {
                let params: [String: Any] = ["filter[search]": search]
                return .requestParameters(Parameters: params, encoding: .inURLEncoding)
            }
            return .requestPlain
            
        case .getCouponBranches, .getCouponStores:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}





//  CouponsModels.swift
import Foundation

// MARK: - Generic Response
struct BaseDataResponse<T: Decodable>: Decodable {
    let status: Bool?
    let message: String?
    let data: T?
}

// MARK: - Coupon Model
struct CouponModel: Decodable {
    let id: Int?
    let code: String?
    let type: Int?
    let value: Double?
    let expirationDate: String?
    let isUsed: Bool?
    let isAllBranches: Int?
    let isAllStores: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, code, type, value
        case expirationDate = "expiration_date"
        case isUsed = "is_used"
        case isAllBranches = "is_all_branches"
        case isAllStores = "is_all_stores"
    }
}

// MARK: - Branch Models (Updated)
//struct BranchModel: Codable {
//    let status: Bool?
//    let message: String?
//    let data: [BranchData]?
//}
//
//struct BranchData: Codable {
//    let id: Int?
//    let name: String?
//    let lat: String?
//    let lng: String?
//    let address: String?
//    let createdAt: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case id, name, lat, lng, address
//        case createdAt = "created_at"
//    }
//}

// MARK: - Store Model
struct StoreModel: Decodable {
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
