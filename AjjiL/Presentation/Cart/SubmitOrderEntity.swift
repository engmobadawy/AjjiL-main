import Foundation

struct SubmitOrderEntity: Codable {
    let status: Bool
    let message: String
    let data: SubmitOrderData?
}

struct SubmitOrderData: Codable {
    let orderId: Int
    let paymentLink: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case paymentLink = "payment_link"
    }
}

// Model for type-safe sheet presentation
struct PaymentDestination: Identifiable {
    let id = UUID()
    let url: URL
}