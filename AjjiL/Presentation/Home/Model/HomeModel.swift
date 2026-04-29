//
//  HomeModel.swift
//  AjjiL
//

import Foundation

// MARK: - HomeBannerModel
struct HomeBannerModel: Codable {
    let status: Bool?
    let message: String?
    let data: [HomeBannerData]?
}

struct HomeStoresModel: Codable {
    let status: Bool?
    let message: String?
    let data: [HomeStoresData]?
}

struct HomeBannerData: Identifiable, Codable {
    var id: Int?
    var image: String?
}

struct HomeStoresData: Identifiable, Codable {
    var id: Int?
    var image: String?
    var name: String
}

struct HomeBannerEntity {
    var data: [HomeBannerDataEntity]
}

struct HomeStoresEntity {
    var data: [HomeStoresDataEntity]
}

struct HomeBannerDataEntity: Identifiable, Hashable {
    var id: Int
    var image: String
}

struct HomeStoresDataEntity: Identifiable, Hashable {
    var id: Int
    var image: String
    var name: String
}

extension HomeBannerModel {
    func map() -> [HomeBannerDataEntity] {
        return data?.compactMap { $0.map() } ?? []
    }
}

extension HomeStoresModel {
    func map() -> [HomeStoresDataEntity] {
        return data?.compactMap { $0.map() } ?? []
    }
}

extension HomeBannerData {
    func map() -> HomeBannerDataEntity {
        HomeBannerDataEntity(id: self.id ?? 0, image: self.image ?? "")
    }
}

extension HomeStoresData {
    func map() -> HomeStoresDataEntity {
        HomeStoresDataEntity(id: self.id ?? 0, image: self.image ?? "", name: self.name)
    }
}

// MARK: - Product API Models

// MARK: - 1. Network DTOs (Raw Backend Response)
struct HomeFeaturedProductModel: Codable {
    let status: Bool?
    let message: String?
    let data: HomeFeaturedProductDataWrapper?
}

struct HomeFeaturedProductDataWrapper: Codable {
    let products: [HomeFeaturedProductData]?
    let count: Int?
}

struct HomeFeaturedProductData: Identifiable, Codable {
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

// MARK: - 2. Domain Entities (Clean UI Models)
struct HomeFeaturedProductDataEntity: Identifiable, Hashable {
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
extension HomeFeaturedProductModel {
    func map() -> [HomeFeaturedProductDataEntity] {
        return data?.products?.compactMap { $0.map() } ?? []
    }
}

extension HomeFeaturedProductData {
    func map() -> HomeFeaturedProductDataEntity {
        HomeFeaturedProductDataEntity(
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
            isFavorite: self.isFavorite ?? false
        )
    }
}
