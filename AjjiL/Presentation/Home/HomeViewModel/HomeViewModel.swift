//
//  HomeViewModel.swift
//  AjjiL
//

import Foundation

@Observable
@MainActor
class HomeViewModel {
    var sliderCards: [HomeBannerDataEntity] = []
    var homeStores: [HomeStoresDataEntity] = []
    var featuredProducts: [HomeFeaturedProductDataEntity] = []
    
    var branches: [BranchDataEntity] = []
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var toast: FancyToast?
    
    private let getHomeDataUC: GetHomeDataUC
    private let getHomeBannersUC: GetHomeBannersUC
    private let getHomeStoresUC: GetHomeStoresUC
    private let getFeaturedProductsUC: GetFeaturedProductsUC
    private let addFavoriteProductUC: AddFavoriteProductUC
    private let removeFavoriteProductUC: RemoveFavoriteProductUC
    private let getBranchesUC: GetBranchesUC
    private let addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
    private let getMapBranchesUC: GetMapBranchesUC
    
    init(
        getHomeDataUC: GetHomeDataUC,
        getHomeBannersUC: GetHomeBannersUC,
        getHomeStoresUC: GetHomeStoresUC,
        getFeaturedProductsUC: GetFeaturedProductsUC,
        addFavoriteProductUC: AddFavoriteProductUC,
        removeFavoriteProductUC: RemoveFavoriteProductUC ,
        getBranchesUC: GetBranchesUC,
        getMapBranchesUC: GetMapBranchesUC,
        addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
    ) {
        self.getHomeDataUC = getHomeDataUC
        self.getHomeBannersUC = getHomeBannersUC
        self.getHomeStoresUC = getHomeStoresUC
        self.getFeaturedProductsUC = getFeaturedProductsUC
        self.addFavoriteProductUC = addFavoriteProductUC
        self.removeFavoriteProductUC = removeFavoriteProductUC
        self.getBranchesUC = getBranchesUC
        self.getMapBranchesUC = getMapBranchesUC
        self.addProductByBarcodeToCartUC = addProductByBarcodeToCartUC
    }
    
    func fetchData(branchId: Int? = 1) async {
        isLoading = true
        errorMessage = nil
        
        async let bannersResult = try? getHomeBannersUC.execute()
        async let storesResult = try? getHomeStoresUC.execute()
        async let productsResult = try? getFeaturedProductsUC.execute()
        
        let (banners, stores, products) = await (bannersResult, storesResult, productsResult)
        
        sliderCards = banners ?? []
        homeStores = stores ?? []
        featuredProducts = products ?? []
        
        // Sync fetched favorites to the Source of Truth
        if let products = products {
            for product in products {
                FavoritesManager.shared.setFavorite(product.id, isFavorite: product.isFavorite)
            }
        }
        
        if banners == nil && stores == nil && products == nil {
            errorMessage = "Failed to load home data.".newlocalized
            toast = FancyToast(type: .error, title: "Error".newlocalized, message: errorMessage ?? "")
        }
        isLoading = false
    }
    
    // MARK: - ASYNC TOGGLE
    func toggleFavorite(for productID: Int) async {
        guard !Constants.isGuestMode else { return }
        
        let isCurrentlyFavorite = FavoritesManager.shared.isFavorite(productID)
        
        // 1. Optimistic UI Update globally
        _ = FavoritesManager.shared.toggleLocal(productID)
        
        // 🛠️ FIX: Update local array so NavigationLink passes fresh data to ProductDetailsView
        if let index = featuredProducts.firstIndex(where: { $0.id == productID }) {
            featuredProducts[index].isFavorite = !isCurrentlyFavorite
        }
        
        // 2. Call backend
        do {
            let branchProductIDString = String(productID)
            let response: ToggleFavoriteModel
            
            if isCurrentlyFavorite {
                response = try await removeFavoriteProductUC.execute(branchProductId: branchProductIDString)
            } else {
                response = try await addFavoriteProductUC.execute(branchProductId: branchProductIDString)
            }
            
            // 3. Revert if backend says it failed
            if response.status == false {
                revertFavoriteState(for: productID, wasFavorite: isCurrentlyFavorite)
                errorMessage = response.message ?? "Failed to update favorite.".newlocalized
                toast = FancyToast(type: .error, title: "Error".newlocalized, message: errorMessage ?? "")
            }
        } catch {
            revertFavoriteState(for: productID, wasFavorite: isCurrentlyFavorite)
            errorMessage = error.localizedDescription
            toast = FancyToast(type: .error, title: "Error".newlocalized, message: errorMessage ?? "")
        }
    }
    
    // 🛠️ FIX: Helper to cleanly revert both global manager and local array
    private func revertFavoriteState(for productID: Int, wasFavorite: Bool) {
        _ = FavoritesManager.shared.toggleLocal(productID) // Revert global manager
        if let index = featuredProducts.firstIndex(where: { $0.id == productID }) {
            featuredProducts[index].isFavorite = wasFavorite // Revert local array
        }
    }
    
    func fetchBranches(storeId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            branches = try await getBranchesUC.execute(storeId: storeId)
        } catch {
            errorMessage = error.localizedDescription
            toast = FancyToast(type: .error, title: "Error".newlocalized, message: errorMessage ?? "")
        }
        
        isLoading = false
    }
    
    // MARK: - Add to Cart
    func addToCart(product: HomeFeaturedProductDataEntity, branchId: Int) async {
        guard !Constants.isGuestMode else { return }
        
        let branchIdString = String(branchId)
        let barcodeString = product.barcode.isEmpty ? String(product.id) : product.barcode
        let defaultQuantity = "1"
        
        _ = try? await addProductByBarcodeToCartUC.execute(
            branchId: branchIdString,
            barcode: barcodeString,
            quantity: defaultQuantity
        )
        
        toast = FancyToast(
            type: .success,
            title: "Success".newlocalized,
            message: "added to the cart successfully".newlocalized
        )
    }
}
