//
//  HomeDI.swift
//  lifeCare
//

import Foundation

extension DependencyContainer {
    class HomeDependency {
        
        static let shared = HomeDependency()
        
        // Repositories
        private(set) lazy var homeRepo: HomeRepository = HomeRepositoryImp(networkService: DependencyContainer.shared.networkService)
        
        // Home UseCases
        private(set) lazy var getHomeDataUC: GetHomeDataUC = GetHomeDataUC(repo: homeRepo)
        private(set) lazy var getHomeBannersUC: GetHomeBannersUC = GetHomeBannersUC(repo: homeRepo)
        private(set) lazy var getHomeStoresUC: GetHomeStoresUC = GetHomeStoresUC(repo: homeRepo)
        private(set) lazy var getFeaturedProductsUC: GetFeaturedProductsUC = GetFeaturedProductsUC(repo: homeRepo)
        
        // NEW: Instantiate the GetBranches UseCase
        private(set) lazy var getBranchesUC: GetBranchesUC = GetBranchesUC(repo: homeRepo)
        
        // HomeViewModel
        @MainActor
        private(set) lazy var homeVM: HomeViewModel = HomeViewModel(
            getHomeDataUC: getHomeDataUC,
            getHomeBannersUC: getHomeBannersUC,
            getHomeStoresUC: getHomeStoresUC,
            getFeaturedProductsUC: getFeaturedProductsUC,
            addFavoriteProductUC: DependencyContainer.FavoritesDependency.shared.addFavoriteProductUC,
            removeFavoriteProductUC: DependencyContainer.FavoritesDependency.shared.removeFavoriteProductUC,
            
            // NEW: Pass the UseCase into the ViewModel
            getBranchesUC: getBranchesUC
        )
    }
}
