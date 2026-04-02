import Foundation
// get home offers still doesnot added by the backend    and i made it with uuid for now

enum StoreNetwork {
    case getFeaturedProducts(storeId: Int, branchId: Int, skip: Int, take: Int)
    case getHomeCategories(storeId: Int)
    case getHomeOffers(storeId: Int, branchId: Int)
    case getStoreSliders(storeId: Int)
    case getProductDetails(branchProductId: Int)
    case getStoreSubcategories(storeId: Int)
    case getStoreProducts(storeId: Int, branchId: Int, search: String)
    case getProductsByCategory(storeId: Int, branchId: Int, categoryId: Int)
}

extension StoreNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case let .getFeaturedProducts(storeId, branchId, skip, take):
            return "products/store/feature?store_id=\(storeId)&branch_id=\(branchId)&skip=\(skip)&take=\(take)"
        case let .getHomeCategories(storeId):
            return "categories/store/home?store_id=\(storeId)"
        case let .getHomeOffers(storeId, branchId):
            return "offers/store/home?store_id=\(storeId)&branch_id=\(branchId)"
        case let .getStoreSliders(storeId):
            return "slider/store?store_id=\(storeId)"
        case let .getProductDetails(branchProductId):
            return "products/show-product/?branch_product_id=\(branchProductId)"
        case let .getStoreSubcategories(storeId):
            return "categories/store/subcategory?store_id=\(storeId)"
            
        // New Paths
        case let .getStoreProducts(storeId, branchId, search):
            // The API uses "0" to indicate no search filter.
            // Using addingPercentEncoding ensures spaces/special characters in search strings don't break the URL.
            let encodedSearch = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "0"
            return "products?store_id=\(storeId)&branch_id=\(branchId)&filter[search]=\(encodedSearch)"
        case let .getProductsByCategory(storeId, branchId, categoryId):
            return "products/categories?branch_id=\(branchId)&category_id=\(categoryId)&store_id=\(storeId)"
        }
    }

    var methods: HTTPMethod {
        switch self {
        case .getFeaturedProducts, .getHomeCategories, .getHomeOffers, .getStoreSliders, .getProductDetails, .getStoreSubcategories, .getStoreProducts, .getProductsByCategory:
            return .get
        }
    }

    var task: TaskRequest {
        switch self {
        case .getFeaturedProducts, .getHomeCategories, .getHomeOffers, .getStoreSliders, .getProductDetails, .getStoreSubcategories, .getStoreProducts, .getProductsByCategory:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}


import Foundation

struct StoreCategoryResponse: Codable {
    let status: Bool
    let message: String
    let data: [StoreCategory]
}

struct StoreCategory: Codable, Identifiable {
    let id: Int
    let name: String
    let secondaryName: String
    let children: Bool
    let products: Int
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case secondaryName = "secondary_name"
        case children
        case products
        case image
    }
}



import Foundation

// MARK: - Home Offers Models
struct StoreHomeOffersResponse: Codable {
    let status: Bool
    let message: String
    let data: [StoreOffer]
}

struct StoreOffer: Codable, Identifiable {
    let id = UUID() // Placeholder ID
    // TODO: Add properties here once you have a JSON response with data inside the array.
    
    enum CodingKeys: String, CodingKey {
        // Add coding keys when properties are added
        case id // Remove or adjust if the actual API returns an 'id'
    }
}

// MARK: - Store Slider Models
struct StoreSliderResponse: Codable {
    let status: Bool
    let message: String
    let data: [StoreSlider]
}

struct StoreSlider: Codable, Identifiable {
    // Using image URL as the unique ID for SwiftUI since slider_id can be null
    var id: String { image }
    
    let type: String?
    let image: String
    let branchId: Int?
    let storeId: Int?
    let sliderId: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case image
        case branchId = "branch_id"
        case storeId = "store_id"
        case sliderId = "slider_id"
    }
}

extension StoreSlider {
    var asHomeBanner: HomeBannerDataEntity {
        return HomeBannerDataEntity(
            // Use sliderId, falling back to a stable hash of the image if nil
            id: self.sliderId ?? self.image.hashValue,
            image: self.image
        )
    }
}


import Foundation

// MARK: - Product Detail Models
struct ProductDetailResponse: Codable, Identifiable {
    var id: Int { productBranchId } // Satisfies Identifiable for SwiftUI lists/views
    
    let productBranchId: Int
    let branchId: Int
    let productId: Int
    let name: String
    let categoryName: String
    let storeId: Int
    let storeName: String
    let storeImage: String
    let images: String
    let price: Double
    let finalPrice: Double
    let offerType: String?
    let offerId: Int?
    let offerDiscount: String
    let barcode: String
    let isFavorite: Bool
    let allImages: [ProductImagePath]
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case productBranchId = "product_branch_id"
        case branchId = "branch_id"
        case productId = "product_id"
        case name
        case categoryName = "category_name"
        case storeId = "store_id"
        case storeName = "store_name"
        case storeImage = "store_image"
        case images
        case price
        case finalPrice = "final_price"
        case offerType = "offer_type"
        case offerId = "offer_id"
        case offerDiscount = "offer_discount"
        case barcode
        case isFavorite = "is_favorite"
        case allImages
        case description
    }
}

struct ProductImagePath: Codable {
    let path: String
}

// MARK: - Store Subcategory Models
struct StoreSubcategoryResponse: Codable {
    let status: Bool
    let message: String
    let data: [StoreCategory] // Reusing your existing StoreCategory model!
}



import Foundation

// MARK: - Product List Models
struct ProductListResponse: Codable {
    let status: Bool?
    let message: String?
    let data: ProductListDataWrapper? // Wrap the data like you did in HomeModel
}

struct ProductListDataWrapper: Codable {
    let products: [ProductItem]?
    let count: Int?
}

struct ProductItem: Codable, Identifiable {
    var id: Int { productBranchId ?? 0 } // Safely unwrap for Identifiable
    
    // Making properties optional (?) prevents crashes if the backend sends null
    let productBranchId: Int?
    let branchId: Int?
    let productId: Int?
    let name: String?
    let categoryName: String?
    let storeId: Int?
    let storeName: String?
    let storeImage: String?
    let images: String?
    let price: Double?
    let finalPrice: Double?
    let offerType: String?
    let offerId: Int?
    let offerDiscount: String?
    let barcode: String?
    let isFavorite: Bool?
    
    enum CodingKeys: String, CodingKey {
        case productBranchId = "product_branch_id"
        case branchId = "branch_id"
        case productId = "product_id"
        case name
        case categoryName = "category_name"
        case storeId = "store_id"
        case storeName = "store_name"
        case storeImage = "store_image"
        case images
        case price
        case finalPrice = "final_price"
        case offerType = "offer_type"
        case offerId = "offer_id"
        case offerDiscount = "offer_discount"
        case barcode
        case isFavorite = "is_favorite"
    }
}

extension ProductItem {
    func asFeaturedProductEntity() -> HomeFeaturedProductDataEntity {
        return HomeFeaturedProductDataEntity(
            id: self.productBranchId ?? 0,
            productId: self.productId ?? 0,
            category: self.categoryName ?? "General",
            name: self.name ?? "Unknown",
            brand: self.storeName ?? "Unknown",
            brandImage: self.storeImage ?? "",
            price: self.finalPrice ?? 0.0,
            originalPrice: self.price ?? 0.0,
            discount: self.offerDiscount ?? "",
            imageURL: self.images ?? "",
            barcode: self.barcode ?? "",
            isFavorite: self.isFavorite ?? false
        )
    }
}
