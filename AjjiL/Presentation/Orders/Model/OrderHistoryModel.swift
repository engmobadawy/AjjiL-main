//
//  OrderModels.swift
//  AjjiLMB
//

import Foundation

// MARK: - ==========================================
// MARK: - 1. NETWORK DTOs (Raw Backend Responses)
// MARK: - ==========================================

struct OrderHistoryModel: Codable {
    let status: Bool?
    let message: String?
    let data: [OrderHistoryData]?
}

struct OrderHistoryData: Identifiable, Codable {
    var id: Int?
    var referenceNo: String?
    var store: String?
    var storeImage: String?
    var branch: String?
    var statusId: Int?
    var statusName: String?
    var createdAt: String?
    var grandTotal: String?
    var isReturnable: Bool?
    var isRated: Int?
    var rate: Int?
    
    var priceExcludeVate: String?
    var totalTax: String?
    var discount: String?
    var priceIncludeVate: String?
    var refundTax: String?
    var refundPrice: String?
    var refundPoints: String?
    var returnReason: String?
    var rejectReason: String?

    enum CodingKeys: String, CodingKey {
        case id
        case referenceNo = "reference_no"
        case store
        case storeImage = "store_image"
        case branch
        case statusId = "status_id"
        case statusName = "status"
        case createdAt = "created_at"
        case grandTotal = "grand_total"
        case isReturnable = "is_returnable"
        case isRated = "is_rated"
        case rate
        case priceExcludeVate = "price_exclude_vate"
        case totalTax = "total_tax"
        case discount
        case priceIncludeVate = "price_include_vate"
        case refundTax = "refund_tax"
        case refundPrice = "refund_price"
        case refundPoints = "refund_points"
        case returnReason = "return_reason"
        case rejectReason = "reject_reason"
    }
}

struct OrderDetailModel: Codable {
    let status: Bool?
    let message: String?
    let data: OrderDetailData?
}

struct OrderDetailData: Codable {
    let id: Int?
    let referenceNo: String?
    let store: String?
    let storeImage: String?
    let branch: String?
    let statusId: Int?
    let status: String?
    let createdAt: String?
    let grandTotal: String?
    let isReturnable: Bool?
    let isRated: Int?
    let rate: Int?
    let priceExcludeVate: String?
    let totalTax: String?
    let discount: String?
    let priceIncludeVate: String?
    let refundTax: String?
    let refundPrice: String?
    let refundPoints: String?
    let returnReason: String?
    let rejectReason: String?
    let items: [OrderItemData]?
    
    enum CodingKeys: String, CodingKey {
        case id, store, branch, status, rate, discount, items
        case referenceNo = "reference_no"
        case storeImage = "store_image"
        case statusId = "status_id"
        case createdAt = "created_at"
        case grandTotal = "grand_total"
        case isReturnable = "is_returnable"
        case isRated = "is_rated"
        case priceExcludeVate = "price_exclude_vate"
        case totalTax = "total_tax"
        case priceIncludeVate = "price_include_vate"
        case refundTax = "refund_tax"
        case refundPrice = "refund_price"
        case refundPoints = "refund_points"
        case returnReason = "return_reason"
        case rejectReason = "reject_reason"
    }
}

struct OrderItemData: Codable {
    let id: Int?
    let productId: Int?
    let productName: String?
    let category: String?
    let image: String?
    let quantity: Int?
    let unitPrice: Double?
    let total: Double?

    enum CodingKeys: String, CodingKey {
        case id, category, image, total
        case productId = "product_id"
        case productName = "product_name"
        case quantity = "qauntity"
        case unitPrice = "unit_price"
    }
}

struct SimpleActionModel: Codable {
    let status: Bool?
    let message: String?
}

// MARK: QR Code
struct QRCodeDataModel: Decodable {
    let status: Bool?
    let message: String?
    let data: QRCodePayloadModel?
}

struct QRCodePayloadModel: Decodable {
    let points: Int?
    let qrcode: String?
}

// MARK: - ==========================================
// MARK: - 2. DOMAIN ENTITIES (Clean UI Models)
// MARK: - ==========================================

struct OrderHistoryEntity: Identifiable, Hashable {
    var id: Int
    var referenceNo: String
    var store: String
    var storeImage: String
    var branch: String
    var statusId: Int
    var statusName: String
    var createdAt: String
    var grandTotal: String
    var isReturnable: Bool
    var isRated: Bool
    var rate: Int?
    
    var priceExcludeVate: String?
    var totalTax: String?
    var discount: String?
    var priceIncludeVate: String?
    var refundTax: String?
    var refundPrice: String?
    var refundPoints: String?
    var returnReason: String?
    var rejectReason: String?
}

struct OrderDetailEntity: Identifiable, Hashable {
    var id: Int
    var referenceNo: String
    var store: String
    var storeImage: String
    var branch: String
    var statusId: Int
    var status: String
    var createdAt: String
    var grandTotal: String
    var isReturnable: Bool
    var isRated: Bool
    var rate: String
    var priceExcludeVate: String
    var totalTax: String
    var discount: String
    var priceIncludeVate: String
    var items: [OrderItemEntity]
}

struct OrderItemEntity: Identifiable, Hashable {
    var id: Int
    var productId: Int
    var productName: String
    var category: String
    var image: String
    var quantity: Int
    var unitPrice: Double
    var total: Double
}

struct SimpleActionEntity: Hashable {
    var status: Bool
    var message: String
}

struct QRCodeEntity: Equatable {
    let points: Int
    let qrcode: String
}

// MARK: - ==========================================
// MARK: - 3. MAPPERS (The Bridge)
// MARK: - ==========================================

extension OrderHistoryModel {
    func map() -> [OrderHistoryEntity] {
        return data?.compactMap { $0.map() } ?? []
    }
}

extension OrderHistoryData {
    func map() -> OrderHistoryEntity {
        OrderHistoryEntity(
            id: self.id ?? 0,
            referenceNo: self.referenceNo ?? "Unknown",
            store: self.store ?? "Unknown Store",
            storeImage: self.storeImage ?? "",
            branch: self.branch ?? "",
            statusId: self.statusId ?? 0,
            statusName: self.statusName ?? "Unknown Status",
            createdAt: self.createdAt ?? "",
            grandTotal: self.grandTotal ?? "0.00",
            isReturnable: self.isReturnable ?? false,
            isRated: (self.isRated ?? 0) == 1,
            rate: self.rate,
            priceExcludeVate: self.priceExcludeVate,
            totalTax: self.totalTax,
            discount: self.discount,
            priceIncludeVate: self.priceIncludeVate,
            refundTax: self.refundTax,
            refundPrice: self.refundPrice,
            refundPoints: self.refundPoints,
            returnReason: self.returnReason,
            rejectReason: self.rejectReason
        )
    }
}

extension OrderDetailModel {
    func map() -> OrderDetailEntity {
        return data?.map() ?? OrderDetailEntity.empty()
    }
}

extension OrderDetailData {
    func map() -> OrderDetailEntity {
        return OrderDetailEntity(
            id: self.id ?? 0,
            referenceNo: self.referenceNo ?? "",
            store: self.store ?? "",
            storeImage: self.storeImage ?? "",
            branch: self.branch ?? "",
            statusId: self.statusId ?? 0,
            status: self.status ?? "Unknown",
            createdAt: self.createdAt ?? "",
            grandTotal: self.grandTotal ?? "0.00",
            isReturnable: self.isReturnable ?? false,
            isRated: (self.isRated ?? 0) == 1,
            rate: self.rate != nil ? "\(self.rate!)" : "0",
            priceExcludeVate: self.priceExcludeVate ?? "0.00",
            totalTax: self.totalTax ?? "0.00",
            discount: self.discount ?? "0.00",
            priceIncludeVate: self.priceIncludeVate ?? "0.00",
            items: self.items?.compactMap { $0.map() } ?? []
        )
    }
}

extension OrderItemData {
    func map() -> OrderItemEntity {
        return OrderItemEntity(
            id: self.id ?? 0,
            productId: self.productId ?? 0,
            productName: self.productName ?? "Unknown Product",
            category: self.category ?? "",
            image: self.image ?? "",
            quantity: self.quantity ?? 1,
            unitPrice: self.unitPrice ?? 0.0,
            total: self.total ?? 0.0
        )
    }
}

extension OrderDetailEntity {
    static func empty() -> OrderDetailEntity {
        return OrderDetailEntity(id: 0, referenceNo: "", store: "", storeImage: "", branch: "", statusId: 0, status: "", createdAt: "", grandTotal: "0", isReturnable: false, isRated: false, rate: "", priceExcludeVate: "0", totalTax: "0", discount: "0", priceIncludeVate: "0", items: [])
    }
}

extension SimpleActionModel {
    func map() -> SimpleActionEntity {
        return SimpleActionEntity(
            status: self.status ?? false,
            message: self.message ?? "Unknown error occurred"
        )
    }
}

extension QRCodeDataModel {
    func map() -> QRCodeEntity {
        return QRCodeEntity(
            points: data?.points ?? 0,
            qrcode: data?.qrcode ?? ""
        )
    }
}
