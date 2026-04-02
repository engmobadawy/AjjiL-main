//
//  AddFavoriteProductUC.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 11/03/2026.
//

import Foundation

class AddFavoriteProductUC {
    private let repo: FavoritesRepository
    
    init(repo: FavoritesRepository) {
        self.repo = repo
    }
    
    func execute(branchProductId: String) async throws -> ToggleFavoriteModel {
        return try await repo.addFavoriteProduct(branchProductId: branchProductId)
    }
}
