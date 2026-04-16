//
//  FavoritesDI.swift
//  AjjiL
//

import Foundation

extension DependencyContainer {
    class FavoritesDependency {
        
        static let shared = FavoritesDependency()
        
        // MARK: - Repositories
        private(set) lazy var favoritesRepo: FavoritesRepository = FavoritesRepositoryImp(
            networkService: DependencyContainer.shared.networkService
        )
        
        // MARK: - UseCases
        private(set) lazy var getFavoriteProductsUC: GetFavoriteProductsUC = GetFavoriteProductsUC(
            repo: favoritesRepo
        )
        
        // Add the AddFavoriteProduct UseCase
        private(set) lazy var addFavoriteProductUC: AddFavoriteProductUC = AddFavoriteProductUC(
            repo: favoritesRepo
        )
        
        // NEW: Add the RemoveFavoriteProduct UseCase
        private(set) lazy var removeFavoriteProductUC: RemoveFavoriteProductUC = RemoveFavoriteProductUC(
            repo: favoritesRepo
        )
        
        lazy var getProductDetailsUC = GetProductDetailsUC(repo: StoreRepositoryImp(networkService: DependencyContainer.shared.networkService))
        
        
        // MARK: - ViewModels
        @MainActor // Ensures ViewModel is initialized on the main thread for SwiftUI
        private(set) lazy var favoritesVM: FavoritesViewModel = FavoritesViewModel(
            getFavoriteProductsUC: getFavoriteProductsUC,
            addFavoriteProductUC: addFavoriteProductUC,
            removeFavoriteProductUC: removeFavoriteProductUC 
        )
    }
}
