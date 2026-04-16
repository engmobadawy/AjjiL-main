//
//  RemoveProductFromCartUC.swift
//  AjjiLMB
//

import Foundation

class RemoveProductFromCartUC {
    private let repo: CartRepository
    
    init(repo: CartRepository) {
        self.repo = repo
    }
    
    // Changed return type from CartModel to SimpleActionModel
    func execute(itemId: String) async throws -> SimpleActionModel {
        return try await repo.removeProduct(itemId: itemId)
    }
}
