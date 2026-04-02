//
//  HomeModel.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 04/03/2026.
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

// MARK: - Datum
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
    var name: String // Added to support dynamic store names
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
        HomeStoresDataEntity(id: self.id ?? 0, image: self.image ?? "", name: self.name )
    }
}



// MARK: - Product API Models


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
    var isFavorite: Bool? // NEW
    
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
        case isFavorite = "is_favorite" // NEW
    }
}

// MARK: - 2. Domain Entities (Clean UI Models)
struct HomeFeaturedProductDataEntity: Identifiable, Hashable {
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
    var isFavorite: Bool // NEW
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
            productId: self.productId ?? 0,
            category: self.category ?? "General",
            name: self.name ?? "Unknown",
            brand: self.brand ?? "Unknown",
            brandImage: self.brandImage ?? "",
            price: self.price ?? 0.0,
            originalPrice: self.originalPrice ?? 0.0,
            discount: self.discount ?? "",
            imageURL: self.image ?? "",
            barcode: self.barcode ?? "",
            isFavorite: self.isFavorite ?? false // NEW (defaults to false if null)
        )
    }
}
