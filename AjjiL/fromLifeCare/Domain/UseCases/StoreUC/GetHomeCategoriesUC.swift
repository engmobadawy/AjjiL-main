//
//  GetHomeCategoriesUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 02/04/2026.
//


import Foundation

class GetHomeCategoriesUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(storeId: Int) async throws -> StoreCategoryResponse {
        return try await repo.getHomeCategories(storeId: storeId)
    }
}