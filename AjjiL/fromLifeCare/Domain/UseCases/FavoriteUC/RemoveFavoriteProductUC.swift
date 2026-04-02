//
//  RemoveFavoriteProductUC.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 11/03/2026.
//


//
//  RemoveFavoriteProductUC.swift
//  AjjiL
//

import Foundation

class RemoveFavoriteProductUC {
    private let repo: FavoritesRepository
    
    init(repo: FavoritesRepository) {
        self.repo = repo
    }
    
    func execute(branchProductId: String) async throws -> ToggleFavoriteModel {
        return try await repo.removeFavoriteProduct(branchProductId: branchProductId)
    }
}