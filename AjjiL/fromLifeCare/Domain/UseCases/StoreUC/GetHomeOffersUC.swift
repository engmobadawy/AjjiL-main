//
//  GetHomeOffersUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 02/04/2026.
//


import Foundation

class GetHomeOffersUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(storeId: Int, branchId: Int) async throws -> StoreHomeOffersResponse {
        return try await repo.getHomeOffers(storeId: storeId, branchId: branchId)
    }
}