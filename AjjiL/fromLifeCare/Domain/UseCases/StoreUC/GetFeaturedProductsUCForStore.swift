//
//  GetFeaturedProductsUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 02/04/2026.
//


import Foundation

class GetFeaturedProductsUCForStore {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    // CHANGE: Set a default 'take' value greater than 0 (e.g., 20)
    func execute(storeId: Int, branchId: Int, skip: Int? = 0, take: Int? = 20) async throws -> ProductListResponse {
        return try await repo.GetFeaturedProductsUCForStore(storeId: storeId, branchId: branchId, skip: skip ?? 0, take: take ?? 20)
    }
}
