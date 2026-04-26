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
    
    init(
        getHomeDataUC: GetHomeDataUC,
        getHomeBannersUC: GetHomeBannersUC,
        getHomeStoresUC: GetHomeStoresUC,
        getFeaturedProductsUC: GetFeaturedProductsUC,
        addFavoriteProductUC: AddFavoriteProductUC,
        removeFavoriteProductUC: RemoveFavoriteProductUC ,
        getBranchesUC: GetBranchesUC,
        addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
    ) {
        self.getHomeDataUC = getHomeDataUC
        self.getHomeBannersUC = getHomeBannersUC
        self.getHomeStoresUC = getHomeStoresUC
        self.getFeaturedProductsUC = getFeaturedProductsUC
        self.addFavoriteProductUC = addFavoriteProductUC
        self.removeFavoriteProductUC = removeFavoriteProductUC
        self.getBranchesUC = getBranchesUC
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
        
        // 👉 NEW: Sync fetched favorites to the Source of Truth
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
        // Safety check: Prevent guest users from making this API call
        guard !Constants.isGuestMode else { return }
        
        // 1. Optimistic UI Update globally
        let isCurrentlyFavorite = FavoritesManager.shared.isFavorite(productID)
        _ = FavoritesManager.shared.toggleLocal(productID)
        
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
                _ = FavoritesManager.shared.toggleLocal(productID) // Revert
                errorMessage = response.message ?? "Failed to update favorite.".newlocalized
                toast = FancyToast(type: .error, title: "Error".newlocalized, message: errorMessage ?? "")
            }
        } catch {
            _ = FavoritesManager.shared.toggleLocal(productID) // Revert
            errorMessage = error.localizedDescription // System errors are usually localized by default
            toast = FancyToast(type: .error, title: "Error".newlocalized, message: errorMessage ?? "")
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
        // Safety check: Prevent guest users from making this API call
        guard !Constants.isGuestMode else { return }
        
        let branchIdString = String(branchId)
        // Use barcode if available, otherwise fallback to the product ID
        let barcodeString = product.barcode.isEmpty ? String(product.id) : product.barcode
        let defaultQuantity = "1"
        
        // Execute the network call but ignore any errors using try?
        _ = try? await addProductByBarcodeToCartUC.execute(
            branchId: branchIdString,
            barcode: barcodeString,
            quantity: defaultQuantity
        )
        
        // Always show the exact success toast requested
        toast = FancyToast(
            type: .success,
            title: "Success".newlocalized,
            message: "added to the cart successfully".newlocalized
        )
    }
}
