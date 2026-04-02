//
//  GetProductDetailsUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 02/04/2026.
//


import Foundation

class GetProductDetailsUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(branchProductId: Int) async throws -> ProductDetailResponse {
        return try await repo.getProductDetails(branchProductId: branchProductId)
    }
}