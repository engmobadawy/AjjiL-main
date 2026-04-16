//
//  VerifyPromoCodeUseCase.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 16/04/2026.
//


import Foundation
import Combine

class VerifyPromoCodeUseCase {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func execute(cartId: String, couponCode: String) async throws -> VerifyPromoCodeResponse {
        let publisher = networkService.fetchData(
            target: CartNetwork.verifyPromoCode(cartId: cartId, couponCode: couponCode),
            responseClass: VerifyPromoCodeResponse.self
        )
        
        // Await the first value from the Combine publisher
        for try await responseModel in publisher.values {
            return responseModel
        }
        
        throw URLError(.badServerResponse)
    }
}




import Foundation

struct VerifyPromoCodeResponse: Codable {
    let status: Bool?
    let message: String?
    let data: PromoCodeData?
}

struct PromoCodeData: Codable {
    let id: Int?
    let code: String?
    let couponValue: Double?
    let priceBefore: Double?
    let priceAfter: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case couponValue = "coupon_value"
        case priceBefore = "price_before"
        case priceAfter = "price_after"
    }
}
