import Foundation

// MARK: - Network DTOs
struct FavoriteProductModel: Codable {
    let status: Bool?
    let message: String?
    let data: [FavoriteProductData]?
}

struct FavoriteProductData: Identifiable, Codable {
    var id: Int?
    var productId: Int?
    var category: String?
    var name: String?
    var brand: String?
    var brandImage: String?
    var price: Double?
    var originalPrice: Double?
    var discount: String?
    var image: String?
    var isFavorite: Bool?
    var barcode: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "product_branch_id" 
        case productId = "product_id"
        case category = "category_name"
        case name
        case brand = "store_name"
        case brandImage = "store_image"
        case price = "final_price"
        case originalPrice = "price"
        case discount = "offer_discount"
        case image = "images"
        case isFavorite = "is_favorite"
        case barcode
    }
}

// MARK: - Domain Entities
struct FavoriteProductDataEntity: Identifiable, Hashable {
    var id: Int
    var productId: Int
    var category: String
    var name: String
    var brand: String
    var brandImage: String
    var price: Double
    var originalPrice: Double
    var discount: String
    var imageURL: String
    var isFavorite: Bool
    var barcode: String
}

// MARK: - Mappers
extension FavoriteProductModel {
    func map() -> [FavoriteProductDataEntity] {
        return data?.compactMap { $0.map() } ?? []
    }
}

extension FavoriteProductData {
    func map() -> FavoriteProductDataEntity {
        FavoriteProductDataEntity(
            id: self.id ?? 0,
            productId: self.productId ?? 0,
            category: self.category ?? "General",
            name: self.name ?? "Unknown",
            brand: self.brand ?? "Unknown",
            brandImage: self.brandImage ?? "",
            price: self.price ?? 0.0,
            originalPrice: self.originalPrice ?? 0.0,
            discount: self.discount ?? "",
            imageURL: self.image ?? "",
            isFavorite: self.isFavorite ?? true, barcode: self.barcode ?? ""
        )
    }
}




// MARK: - Network DTOs
struct ToggleFavoriteModel: Codable {
    let status: Bool?
    let message: String?
}


