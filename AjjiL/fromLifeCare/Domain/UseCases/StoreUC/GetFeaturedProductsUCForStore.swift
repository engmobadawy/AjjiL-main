//
//  GetFeaturedProductsUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 02/04/2026.
//


import Foundation

class GetFeaturedProductsUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(storeId: Int, branchId: Int, skip: Int, take: Int) async throws -> ProductListResponse {
        return try await repo.getFeaturedProducts(storeId: storeId, branchId: branchId, skip: skip, take: take)
    }
}