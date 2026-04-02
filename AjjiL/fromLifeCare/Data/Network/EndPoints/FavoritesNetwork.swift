import Foundation

enum FavoritesNetwork {
    case getFavoriteProducts
    case addFavoriteProduct(branchProductId: String)
    case removeFavoriteProduct(branchProductId: String)
}

extension FavoritesNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case .getFavoriteProducts, .addFavoriteProduct:
            return "wishlist"
        case .removeFavoriteProduct(let branchProductId):
            return "wishlist/\(branchProductId)"
        }
    }

    var methods: HTTPMethod {
        switch self {
        case .getFavoriteProducts:
            return .get
        case .addFavoriteProduct:
            return .post
        case .removeFavoriteProduct:
            return .delete
        }
    }

    var task: TaskRequest {
        switch self {
        case .getFavoriteProducts, .removeFavoriteProduct:
            return .requestPlain 
            
        case .addFavoriteProduct(let branchProductId):
            let params: [String: Any] = ["branch_product_id": branchProductId]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}
