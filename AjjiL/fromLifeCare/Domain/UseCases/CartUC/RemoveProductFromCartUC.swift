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
    
    func execute(itemId: String) async throws -> CartModel {
        return try await repo.removeProduct(itemId: itemId)
    }
}