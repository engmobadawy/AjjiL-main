import Foundation

// MARK: - 1. Network DTOs (Raw Backend Response)
struct StoreFeaturedProductModel: Codable {
    let status: Bool?
    let message: String?
    let data: StoreFeaturedProductDataWrapper?
}

struct StoreFeaturedProductDataWrapper: Codable {
    let products: [StoreFeaturedProductData]?
    let count: Int?
}

struct StoreFeaturedProductData: Identifiable, Codable {
    var id: Int?
    var productId: Int?
    var category: String?
    var name: String?
    var brand: String?
    var brandImage : String?
    var price: Double?
    var originalPrice: Double?
    var discount: String?
    var image: String?
    var barcode: String?
    var isFavorite: Bool?
    
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
        case barcode
        case isFavorite = "is_favorite"
    }
}

// MARK: - 2. Domain Entities (Clean UI Models)
struct StoreFeaturedProductDataEntity: Identifiable, Hashable {
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
    var barcode: String
    var isFavorite: Bool
}

// MARK: - 3. Mappers (The Bridge)
extension StoreFeaturedProductModel {
    func map() -> [StoreFeaturedProductDataEntity] {
        return data?.products?.compactMap { $0.map() } ?? []
    }
}

extension StoreFeaturedProductData {
    func map() -> StoreFeaturedProductDataEntity {
        StoreFeaturedProductDataEntity(
            id: self.id ?? 0,
            productId: self.productId ?? 0,
            category: self.category ?? "General",
            name: self.name ?? "Unknown",
            brand: self.brand ?? "Unknown",
            brandImage: self.brandImage ?? "",
            price: self.price ?? 0.0,
            originalPrice: self.originalPrice ?? 0.0,
            discount: self.discount ?? "0",
            imageURL: self.image ?? "",
            barcode: self.barcode ?? "",
            isFavorite: self.isFavorite ?? false
        )
    }
}