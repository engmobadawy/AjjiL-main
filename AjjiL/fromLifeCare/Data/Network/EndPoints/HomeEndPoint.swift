//  LifeCare
//
//HomeEndPoint.swift

//Created by M.Magdy on 12/15/24
//Copyright (c) 2025 M Magdy

import Foundation

enum HomeNetwork {
    case getHomeData(id: Int?)
    case getHomeBanners
    case getHomeStores
    case getFeaturedProducts
    case getBrands(skip: Int, take: Int)
    case notificationList(skip: Int, take: Int)
    case submitToken(deviceID:String,token:String)
    case getBranches(storeId: Int)
}

extension HomeNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case .getHomeData(let id):
            if let id {
                return "home?branch_id=\(id)"
            } else {
                return "home"
            }
        case .getHomeBanners: return "slider/home"
        case .getHomeStores: return "stores?filter[search]"
        case .getFeaturedProducts: return "products/home"
        case .getBrands(let skip, let take):
          return "brands?filter[is_top]=1&skip=\(skip)&take=\(take)"
        case .notificationList(let skip, let take):
          return "notifications?skip=\(skip)&take=\(take)"
        case .submitToken:
            return "notifications/submit-token"
        case .getBranches(let storeId):
                    return "branches?store_id=\(storeId)"
        }
    }

    var methods: HTTPMethod {
        switch self {
        case .getHomeData, .getHomeBanners, .getHomeStores, .getBrands, .notificationList, .getFeaturedProducts, .getBranches:
                    return .get
        case .submitToken:
            return .post
        
        }
    }

    var task: TaskRequest {
        switch self {
        case .getHomeData, .getHomeBanners, .getHomeStores, .getBrands, .notificationList, .getFeaturedProducts, .getBranches:
                    return .requestPlain

        case let .submitToken(deviceID, token):
            
            let param : [String: String] = ["token":token,
                                            "device_id": deviceID]
            return .requestParameters(Parameters: param, encoding: .inBodyEncoding)
        
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}
