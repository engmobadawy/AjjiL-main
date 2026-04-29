import Foundation

// MARK: - 1. Network DTOs (Raw Backend Response)
struct FavoriteProductModel: Codable {
    let status: Bool?
    let message: String?
    let data: [FavoriteProductData]?
}

struct FavoriteProductData: Identifiable, Codable {
    var id: Int?
    var branchId: Int?
    var productId: Int?
    var name: String?
    var category: String?
    var storeId: Int?
    var brand: String?
    var brandImage: String?
    var image: String?
    var price: Double?
    var originalPrice: Double?
    var offerType: String?
    var offerId: Int?
    var discount: String?
    var barcode: String?
    var isFavorite: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "product_branch_id"
        case branchId = "branch_id"
        case productId = "product_id"
        case name
        case category = "category_name"
        case storeId = "store_id"
        case brand = "store_name"
        case brandImage = "store_image"
        case image = "images"
        case price = "final_price"
        case originalPrice = "price"
        case offerType = "offer_type"
        case offerId = "offer_id"
        case discount = "offer_discount"
        case barcode
        case isFavorite = "is_favorite"
    }
}

struct ToggleFavoriteModel: Codable {
    let status: Bool?
    let message: String?
}

// MARK: - 2. Domain Entities (Clean UI Models)
struct FavoriteProductDataEntity: Identifiable, Hashable {
    let id: Int
    let branchId: Int
    let productId: Int
    let name: String
    let category: String
    let storeId: Int
    let brand: String
    let brandImage: String
    let imageURL: String
    let price: Double
    let originalPrice: Double
    let offerType: String?
    let offerId: Int?
    let discount: String
    let barcode: String
    var isFavorite: Bool
}

// MARK: - 3. Mappers (The Bridge)
extension FavoriteProductModel {
    func map() -> [FavoriteProductDataEntity] {
        return data?.compactMap { $0.map() } ?? []
    }
}

extension FavoriteProductData {
    func map() -> FavoriteProductDataEntity {
        FavoriteProductDataEntity(
            id: self.id ?? 0,
            branchId: self.branchId ?? 0,
            productId: self.productId ?? 0,
            name: self.name ?? "Unknown",
            category: self.category ?? "General",
            storeId: self.storeId ?? 0,
            brand: self.brand ?? "Unknown",
            brandImage: self.brandImage ?? "",
            imageURL: self.image ?? "",
            price: self.price ?? 0.0,
            originalPrice: self.originalPrice ?? 0.0,
            offerType: self.offerType,
            offerId: self.offerId,
            discount: self.discount ?? "0",
            barcode: self.barcode ?? "",
            isFavorite: self.isFavorite ?? true
        )
    }
}
