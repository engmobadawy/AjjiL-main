//
//  AddProductByBarcodeToCartUC.swift
//  AjjiLMB
//

import Foundation

class AddProductByBarcodeToCartUC {
    private let repo: CartRepository
    
    init(repo: CartRepository) {
        self.repo = repo
    }
    
    func execute(branchId: String, barcode: String, quantity: String) async throws -> CartModel {
        return try await repo.addProductByBarcode(branchId: branchId, barcode: barcode, quantity: quantity)
    }
}