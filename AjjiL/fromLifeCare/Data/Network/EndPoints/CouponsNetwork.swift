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