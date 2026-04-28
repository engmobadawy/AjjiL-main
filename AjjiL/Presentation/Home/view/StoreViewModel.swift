import Foundation
import SwiftUI
import Observation

@Observable
@MainActor
class StoreViewModel {
    // MARK: - Loading States
    var isLoading: Bool = false
    var isFetchingProducts: Bool = false
    var toast: FancyToast?
    
    var storeSliders: [StoreSlider] = []
    var storeProducts: [HomeFeaturedProductDataEntity] = []
    var storeCategories: [StoreCategory] = []
    var storeSubcategories: [StoreCategory] = []
    
    private let getStoreSlidersUC: GetStoreSlidersUC
    private let getFeaturedProductsUCForStore: GetFeaturedProductsUCForStore
    private let getHomeCategoriesUC: GetHomeCategoriesUC
    private let getStoreSubcategoriesUC: GetStoreSubcategoriesUC
    private let getProductsByCategoryUC: GetProductsByCategoryUC
    
    private let addFavoriteProductUC: AddFavoriteProductUC
    private let removeFavoriteProductUC: RemoveFavoriteProductUC
    
    private let addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
    
    init(
        getStoreSlidersUC: GetStoreSlidersUC,
        getFeaturedProductsUCForStore: GetFeaturedProductsUCForStore,
        getHomeCategoriesUC: GetHomeCategoriesUC,
        getStoreSubcategoriesUC: GetStoreSubcategoriesUC,
        getProductsByCategoryUC: GetProductsByCategoryUC,
        addFavoriteProductUC: AddFavoriteProductUC,
        removeFavoriteProductUC: RemoveFavoriteProductUC,
        addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
    ) {
        self.getStoreSlidersUC = getStoreSlidersUC
        self.getFeaturedProductsUCForStore = getFeaturedProductsUCForStore
        self.getHomeCategoriesUC = getHomeCategoriesUC
        self.getStoreSubcategoriesUC = getStoreSubcategoriesUC
        self.getProductsByCategoryUC = getProductsByCategoryUC
        self.addFavoriteProductUC = addFavoriteProductUC
        self.removeFavoriteProductUC = removeFavoriteProductUC
        self.addProductByBarcodeToCartUC = addProductByBarcodeToCartUC
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(for productID: Int) async {
        guard !Constants.isGuestMode else { return }
        
        let isCurrentlyFavorite = FavoritesManager.shared.isFavorite(productID)
        
        // 1. Optimistic UI Update globally
        _ = FavoritesManager.shared.toggleLocal(productID)
        
        // 🛠️ FIX: Update the local array so NavigationLink passes fresh data
        if let index = storeProducts.firstIndex(where: { $0.id == productID }) {
            storeProducts[index].isFavorite = !isCurrentlyFavorite
        }
        
        // 2. Call Backend
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
            }
        } catch {
            // Revert on network error
            revertFavoriteState(for: productID, wasFavorite: isCurrentlyFavorite)
        }
    }
    
    // 🛠️ FIX: Clean helper function to revert both global manager and local array
    private func revertFavoriteState(for productID: Int, wasFavorite: Bool) {
        _ = FavoritesManager.shared.toggleLocal(productID) // Revert global manager
        if let index = storeProducts.firstIndex(where: { $0.id == productID }) {
            storeProducts[index].isFavorite = wasFavorite // Revert local array
        }
    }
    
    // MARK: - Data Fetching
    func fetchProducts(storeId: Int, branchId: Int, categoryId: Int?) async {
        do {
            if let categoryId = categoryId {
                let response = try await getProductsByCategoryUC.execute(storeId: storeId, branchId: branchId, categoryId: categoryId)
                self.storeProducts = response.data?.map { $0.asFeaturedProductEntity() } ?? []
            } else {
                let response = try await getFeaturedProductsUCForStore.execute(storeId: storeId, branchId: branchId, skip: 0, take: 20)
                self.storeProducts = response.data?.products?.map { $0.asFeaturedProductEntity() } ?? []
            }
            
            // Sync fetched favorites to the Source of Truth
            for product in self.storeProducts {
                FavoritesManager.shared.setFavorite(product.id, isFavorite: product.isFavorite)
            }
            
        } catch {
            print("❌ Failed to fetch products: \(error)")
            self.storeProducts = []
        }
    }
    
    func fetchStoreSliders(storeId: Int) async {
        do {
            let response = try await getStoreSlidersUC.execute(storeId: storeId)
            self.storeSliders = response.data
        } catch { }
    }
    
    func fetchStoreCategories(storeId: Int) async {
        do {
            let response = try await getHomeCategoriesUC.execute(storeId: storeId)
            self.storeCategories = response.data
        } catch { }
    }
    
    func fetchStoreSubcategories(storeId: Int) async {
        do {
            let response = try await getStoreSubcategoriesUC.execute(storeId: storeId)
            self.storeSubcategories = response.data
        } catch { }
    }
    
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
        
        // 🛠️ FIX: Localized Toast
        toast = FancyToast(
            type: .success,
            title: "Success".newlocalized,
            message: "added to the cart successfully".newlocalized
        )
    }
}
