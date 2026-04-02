//
//  GetStoreFeaturedProductsUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 29/03/2026.
//


import Foundation

final class GetStoreFeaturedProductsUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(storeId: Int, branchId: Int, skip: Int = 0, take: Int = 10) async throws -> [StoreFeaturedProductDataEntity] {
        return try await repo.getFeaturedProducts(storeId: storeId, branchId: branchId, skip: skip, take: take)
    }
}