//
//  GetFavoriteProductsUC.swift
//  AjjiL
//

import Foundation

class GetFavoriteProductsUC {
    private let repo: FavoritesRepository
    
    init(repo: FavoritesRepository) {
        self.repo = repo
    }
    
    func execute() async throws -> [FavoriteProductDataEntity] {
        return try await repo.getFavoriteProducts()
    }
}