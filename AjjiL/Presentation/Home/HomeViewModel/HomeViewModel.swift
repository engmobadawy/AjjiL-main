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
    
    var favoriteProductIDs: Set<Int> = [] // Track individual favorites by ID
    var branches: [BranchDataEntity] = []
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var toast: FancyToast?
    
    private let getHomeDataUC: GetHomeDataUC
    private let getHomeBannersUC: GetHomeBannersUC
    private let getHomeStoresUC: GetHomeStoresUC
    private let getFeaturedProductsUC: GetFeaturedProductsUC
    private let addFavoriteProductUC: AddFavoriteProductUC
    private let removeFavoriteProductUC: RemoveFavoriteProductUC // NEW
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
        
        // Use try? to safely capture successes and nil out failures
        async let bannersResult = try? getHomeBannersUC.execute()
        async let storesResult = try? getHomeStoresUC.execute()
        async let productsResult = try? getFeaturedProductsUC.execute()
        
        // Await the results without a throwing try
        let (banners, stores, products) = await (bannersResult, storesResult, productsResult)
        
        sliderCards = banners ?? []
        homeStores = stores ?? []
        featuredProducts = products ?? []
        
        // Load the initial favorites from the backend response
        if let products = products {
            favoriteProductIDs = Set(products.filter { $0.isFavorite }.map { $0.id })
        }
        
        if banners == nil && stores == nil && products == nil {
            errorMessage = "Failed to load home data."
            toast = FancyToast(type: .error, title: "Error", message: errorMessage ?? "")
        }
        
        isLoading = false
    }
    
    // MARK: - ASYNC TOGGLE
    func toggleFavorite(for productID: Int) async {
        let isCurrentlyFavorite = favoriteProductIDs.contains(productID)
        
        // 1. Optimistic UI Update: Toggle it locally first
        if isCurrentlyFavorite {
            favoriteProductIDs.remove(productID)
        } else {
            favoriteProductIDs.insert(productID)
        }
        
        // 2. Call backend
        do {
            let branchProductIDString = String(productID)
            let response: ToggleFavoriteModel
            
            // NEW: Branch the network call based on current state
            if isCurrentlyFavorite {
                response = try await removeFavoriteProductUC.execute(branchProductId: branchProductIDString)
            } else {
                response = try await addFavoriteProductUC.execute(branchProductId: branchProductIDString)
            }
            
            // 3. Revert if backend says it failed
            if response.status == false {
                revertFavoriteState(for: productID, wasFavorite: isCurrentlyFavorite)
                errorMessage = response.message ?? "Failed to update favorite."
                toast = FancyToast(type: .error, title: "Error", message: errorMessage ?? "")
            }
        } catch {
            // Revert on network crash
            revertFavoriteState(for: productID, wasFavorite: isCurrentlyFavorite)
            errorMessage = error.localizedDescription
            toast = FancyToast(type: .error, title: "Error", message: errorMessage ?? "")
        }
    }
    
    private func revertFavoriteState(for productID: Int, wasFavorite: Bool) {
        if wasFavorite {
            favoriteProductIDs.insert(productID)
        } else {
            favoriteProductIDs.remove(productID)
        }
    }
    
    func fetchBranches(storeId: Int) async {
            isLoading = true
            errorMessage = nil
            
            do {
                branches = try await getBranchesUC.execute(storeId: storeId)
            } catch {
                errorMessage = error.localizedDescription
                toast = FancyToast(type: .error, title: "Error", message: errorMessage ?? "")
            }
            
            isLoading = false
        }
    
    
    
    // 3. Add the Cart execution function
        func addToCart(product: HomeFeaturedProductDataEntity, branchId: Int) async {
            let branchIdString = String(branchId)
            // Use barcode if available, otherwise fallback to the product ID
            let barcodeString = product.barcode.isEmpty ? String(product.id) : product.barcode
            let defaultQuantity = "1"
            
            do {
                _ = try await addProductByBarcodeToCartUC.execute(
                    branchId: branchIdString,
                    barcode: barcodeString,
                    quantity: defaultQuantity
                )
                // Show Success Toast
                toast = FancyToast(type: .success, title: "Success", message: "\(product.name) added to cart")
            } catch {
                // Show Error Toast
                errorMessage = error.localizedDescription
                toast = FancyToast(type: .error, title: "Error", message: errorMessage ?? "Failed to add to cart")
            }
        }
    
    
}
