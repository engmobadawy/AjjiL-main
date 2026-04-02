//
//  SubmitOrderUC.swift
//  AjjiLMB
//

import Foundation

class SubmitOrderUC {
    private let repo: OrdersRepository
    
    init(repo: OrdersRepository) {
        self.repo = repo
    }
    
    func execute(cartId: String, storeId: String, branchId: String, paymentMethod: String, couponCode: String? = nil) async throws -> SubmitOrderEntity {
        return try await repo.submitOrder(cartId: cartId, storeId: storeId, branchId: branchId, paymentMethod: paymentMethod, couponCode: couponCode)
    }
}