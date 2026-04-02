//
//  CartModel.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 27/03/2026.
//


import Foundation

// MARK: - Network DTOs
struct CartModel: Codable {
    let status: Bool?
    let message: String?
    let data: CartData?
}

struct CartData: Codable {
    var cartId: Int?
    var items: [CartItem]?
    var totals: CartTotals?

    enum CodingKeys: String, CodingKey {
        case cartId = "cart_id"
        case items
        case totals
    }
}

struct CartItem: Identifiable, Codable {
    var id: Int?
    var itemId: Int?
    var cartId: Int?
    var name: String?
    var category: String?
    var quantity: Int?
    var image: String?
    var totalPrice: Double?
    var sum: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case itemId = "item_id"
        case cartId = "cart_id"
        case name
        case category
        case quantity
        case image
        case totalPrice = "total_price"
        case sum
    }
}

struct CartTotals: Codable {
    var totalExc: Double?
    var totalTax: Double?
    var totalInc: Double?
    var discount: Double?
    var total: Double?

    enum CodingKeys: String, CodingKey {
        case totalExc = "total_exc"
        case totalTax = "total_tax"
        case totalInc = "total_inc"
        case discount
        case total
    }
}

// MARK: - Domain Entities
struct CartEntity: Hashable {
    var cartId: Int
    var items: [CartItemEntity]
    var totals: CartTotalsEntity
}

struct CartItemEntity: Identifiable, Hashable {
    var id: Int
    var itemId: Int
    var cartId: Int
    var name: String
    var category: String
    var quantity: Int
    var imageURL: String
    var totalPrice: Double
    var sum: Double
}

struct CartTotalsEntity: Hashable {
    var totalExc: Double
    var totalTax: Double
    var totalInc: Double
    var discount: Double
    var total: Double
}

// MARK: - Mappers
extension CartModel {
    func map() -> CartEntity? {
        return data?.map()
    }
}

extension CartData {
    func map() -> CartEntity {
        return CartEntity(
            cartId: self.cartId ?? 0,
            items: self.items?.compactMap { $0.map() } ?? [],
            totals: self.totals?.map() ?? CartTotalsEntity(totalExc: 0.0, totalTax: 0.0, totalInc: 0.0, discount: 0.0, total: 0.0)
        )
    }
}

extension CartItem {
    func map() -> CartItemEntity {
        return CartItemEntity(
            id: self.id ?? 0,
            itemId: self.itemId ?? 0,
            cartId: self.cartId ?? 0,
            name: self.name ?? "Unknown",
            category: self.category ?? "General",
            quantity: self.quantity ?? 1,
            imageURL: self.image ?? "",
            totalPrice: self.totalPrice ?? 0.0,
            sum: self.sum ?? 0.0
        )
    }
}

extension CartTotals {
    func map() -> CartTotalsEntity {
        return CartTotalsEntity(
            totalExc: self.totalExc ?? 0.0,
            totalTax: self.totalTax ?? 0.0,
            totalInc: self.totalInc ?? 0.0,
            discount: self.discount ?? 0.0,
            total: self.total ?? 0.0
        )
    }
}