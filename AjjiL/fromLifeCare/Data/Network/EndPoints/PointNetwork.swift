//
//  PointNetwork.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//


import Foundation

enum PointNetwork {
    case getPoints
    case redeemPoints(amount: Int)
    case calcPoints(amount: Int)
}

extension PointNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }
    
    var path: String {
        switch self {
        case .getPoints:
            return "points"
        case .redeemPoints:
            return "redeem-points"
        case .calcPoints:
            return "calc-points"
        }
    }
    
    var methods: HTTPMethod {
        // All three endpoints are explicitly GET requests
        switch self {
        case .getPoints, .redeemPoints, .calcPoints:
            return .get
        }
    }
    
    var task: TaskRequest {
        switch self {
        case .getPoints:
            return .requestPlain
            
        case .redeemPoints(let amount), .calcPoints(let amount):
            let params: [String: Any] = [
                "amount": amount
            ]
            // .inURLEncoding safely appends these as ?amount=X to the URL
            return .requestParameters(Parameters: params, encoding: .inURLEncoding)
        }
    }
    
    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}









import Foundation

// MARK: - Points Response
struct PointsResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: PointsData?
}

struct PointsData: Decodable {
    let maxPoints: Int?
    let minPoints: Int?
    let points: Int?
    let canRedeem: Bool?
    
    enum CodingKeys: String, CodingKey {
        case maxPoints = "max_points"
        case minPoints = "min_points"
        case points
        case canRedeem = "can_redeem"
    }
}

// MARK: - Redeem Points Response
struct RedeemPointsResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: RedeemPointsData?
}

struct RedeemPointsData: Decodable {
    let couponCode: String?
    let expiredAt: String?
    
    enum CodingKeys: String, CodingKey {
        case couponCode = "coupon_code"
        case expiredAt = "expired_at"
    }
}

// MARK: - Calc Points Response
struct CalcPointsResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: CalcPointsData?
}

struct CalcPointsData: Decodable {
    let discountValue: Int?
    
    enum CodingKeys: String, CodingKey {
        case discountValue = "discount_value"
    }
}
