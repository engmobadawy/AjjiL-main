import Foundation

enum CartNetwork {
    case getCart(branchId: String)
    case addProduct(branchId: String, productId: String, quantity: String, barcode: String?)
    case removeProduct(itemId: String)
    case addProductByBarcode(branchId: String, barcode: String, quantity: String)
    case changeQuantity(itemId: String, quantity: String, branchId: String)
}

extension CartNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case .getCart(let branchId):
            return "cart/\(branchId)"
        case .addProduct:
            return "cart/addProduct"
        case .removeProduct:
            return "cart/removeProduct"
        case .addProductByBarcode:
            return "cart/addProduct/barcode"
        case .changeQuantity:
            return "cart/changeQuantity"
        }
    }

    var methods: HTTPMethod {
        switch self {
        case .getCart:
            return .get
        case .addProduct, .removeProduct, .addProductByBarcode, .changeQuantity:
            return .post
        }
    }

    var task: TaskRequest {
        switch self {
        case .getCart:
            return .requestPlain
            
        case .addProduct(let branchId, let productId, let quantity, let barcode):
            var params: [String: Any] = [
                "branch_id": branchId,
                "product_id": productId,
                "quantity": quantity
            ]
            
            if let barcode = barcode, !barcode.isEmpty {
                params["barcode"] = barcode
            }
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
            
        case .removeProduct(let itemId):
            let params: [String: Any] = [
                "item_id": itemId
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
            
        case .addProductByBarcode(let branchId, let barcode, let quantity):
            let params: [String: Any] = [
                "branch_id": branchId,
                "barcode": barcode,
                "quantity": quantity
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
            
        case .changeQuantity(let itemId, let quantity, let branchId):
            let params: [String: Any] = [
                "item_id": itemId,
                "quantity": quantity,
                "branch_id": branchId
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}
