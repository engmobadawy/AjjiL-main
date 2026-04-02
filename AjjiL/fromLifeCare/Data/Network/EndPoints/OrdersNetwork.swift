//
//  OrdersNetwork.swift
//  AjjiLMB
//

import Foundation

enum OrdersNetwork {
    case getOrderHistory(storeName: String?, date: String?)
    case getCurrentOrders(storeName: String?, date: String?)
    case getOrderDetails(id: Int)
    case reviewOrder(id: Int, rate: Int, message: String)
    case getQRCode(orderId: Int)
    case submitOrder(cartId: String, storeId: String, branchId: String, paymentMethod: String, couponCode: String?)
}

extension OrdersNetwork: TargetType {
    var baseURL: String { return APIConfig.lifeCareBaseURL }

    var path: String {
        switch self {
        case .getOrderHistory: return "order/history"
        case .getCurrentOrders: return "order/current"
        case let .getOrderDetails(id): return "order/\(id)"
        case let .reviewOrder(id, _, _): return "order/\(id)/review"
        case .getQRCode: return "order/qrcode"
        case .submitOrder: return "order/submit"
        }
    }

    var methods: HTTPMethod {
        switch self {
        case .getOrderHistory, .getCurrentOrders, .getOrderDetails, .getQRCode:
            return .get
        case .reviewOrder, .submitOrder:
            return .post
        }
    }

    var task: TaskRequest {
        switch self {
        case let .getOrderHistory(storeName, date),
             let .getCurrentOrders(storeName, date):
            
            var parameters: [String: Any] = [:]
            
            if let storeName = storeName, !storeName.isEmpty {
                parameters["filter[search]"] = storeName
            }
            if let date = date, !date.isEmpty {
                parameters["filter[date]"] = date
            }
            
            if parameters.isEmpty {
                return .requestPlain
            } else {
                return .requestParameters(Parameters: parameters, encoding: .inURLEncoding)
            }
            
        case .getOrderDetails:
            return .requestPlain
            
        case let .reviewOrder(_, rate, message):
            let parameters: [String: Any] = [
                "rate": rate,
                "message": message
            ]
            return .requestParameters(Parameters: parameters, encoding: .inBodyEncoding)
            
        case let .getQRCode(orderId):
            let parameters: [String: Any] = ["order_id": orderId]
            return .requestParameters(Parameters: parameters, encoding: .inURLEncoding)
            
        case let .submitOrder(cartId, storeId, branchId, paymentMethod, couponCode):
            var parameters: [String: Any] = [
                "cart_id": cartId,
                "store_id": storeId,
                "branch_id": branchId,
                "payment_method": paymentMethod
            ]
            if let couponCode = couponCode, !couponCode.isEmpty {
                parameters["coupon_code"] = couponCode
            }
            return .requestParameters(Parameters: parameters, encoding: .inBodyEncoding)
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}
