//
//  AddProductToCartUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 27/03/2026.
//


//
//  AddProductToCartUC.swift
//  AjjiLMB
//

import Foundation

class AddProductToCartUC {
    private let repo: CartRepository
    
    init(repo: CartRepository) {
        self.repo = repo
    }
    
    func execute(branchId: String, productId: String, quantity: String, barcode: String? = nil) async throws -> CartModel {
        return try await repo.addProduct(branchId: branchId, productId: productId, quantity: quantity, barcode: barcode)
    }
}