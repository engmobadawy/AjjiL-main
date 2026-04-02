//
//  ChangeCartItemQuantityUC.swift
//  AjjiLMB
//

import Foundation

class ChangeCartItemQuantityUC {
    private let repo: CartRepository
    
    init(repo: CartRepository) {
        self.repo = repo
    }
    
    func execute(itemId: String, quantity: String, branchId: String) async throws -> CartModel {
        return try await repo.changeQuantity(itemId: itemId, quantity: quantity, branchId: branchId)
    }
}