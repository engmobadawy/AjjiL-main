
import Foundation

enum HomeNetwork {
    case getHomeData(id: Int?)
    case getHomeBanners
    case getHomeStores
    case getFeaturedProducts
    case getBrands(skip: Int, take: Int)
    case notificationList(skip: Int, take: Int)
    case submitToken(deviceID: String, token: String)
    case getBranches(storeId: Int)
    case getMapBranches // 👈 New Case
}

extension HomeNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case .getHomeData(let id):
            return id != nil ? "home?branch_id=\(id!)" : "home"
        case .getHomeBanners: return "slider/home"
        case .getHomeStores: return "stores?filter[search]"
        case .getFeaturedProducts: return "products/home"
        case .getBrands(let skip, let take):
            return "brands?filter[is_top]=1&skip=\(skip)&take=\(take)"
        case .notificationList(let skip, let take):
            return "notifications?skip=\(skip)&take=\(take)"
        case .submitToken: return "notifications/submit-token"
        case .getBranches(let storeId): return "branches?store_id=\(storeId)"
        case .getMapBranches: return "map-branches" // 👈 New Path
        }
    }

    var methods: HTTPMethod {
        switch self {
        case .getHomeData, .getHomeBanners, .getHomeStores, .getBrands, .notificationList, .getFeaturedProducts, .getBranches, .getMapBranches: // 👈 Added here
            return .get
        case .submitToken:
            return .post
        }
    }

    var task: TaskRequest {
        switch self {
        case .getHomeData, .getHomeBanners, .getHomeStores, .getBrands, .notificationList, .getFeaturedProducts, .getBranches, .getMapBranches: // 👈 Added here
            return .requestPlain

        case let .submitToken(deviceID, token):
            let param: [String: String] = ["token": token, "device_id": deviceID]
            return .requestParameters(Parameters: param, encoding: .inBodyEncoding)
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}






import Foundation

// MARK: - DTO / Response Model
struct MapBranchesResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: [MapBranchDTO]?
    
    func map() -> [MapBranchEntity] {
        return data?.compactMap { $0.map() } ?? []
    }
}

struct MapBranchDTO: Decodable {
    let id: Int?
    let name: String?
    let lat: String?
    let lng: String?
    let address: String?
    let createdAt: String?
    let storeId: Int?
    let storeImage: String?
    let storeName: String?

    enum CodingKeys: String, CodingKey {
        case id, name, lat, lng, address
        case createdAt = "created_at"
        case storeId = "store_id"
        case storeImage = "store_image"
        case storeName = "store_name"
    }

    func map() -> MapBranchEntity {
        return MapBranchEntity(
            id: id ?? 0,
            name: name ?? "",
            lat: Double(lat ?? "") ?? 0.0,
            lng: Double(lng ?? "") ?? 0.0,
            address: address ?? "",
            storeId: storeId ?? 0,
            storeImage: storeImage ?? "",
            storeName: storeName ?? ""
        )
    }
}

// MARK: - Domain Entity
struct MapBranchEntity: Identifiable, Hashable {
    let id: Int
    let name: String
    let lat: Double
    let lng: Double
    let address: String
    let storeId: Int
    let storeImage: String
    let storeName: String
}
