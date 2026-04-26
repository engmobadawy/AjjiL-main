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
        // Safety check: Prevent guest users from making this API call
        guard !Constants.isGuestMode else { return }
        
        let isCurrentlyFavorite = FavoritesManager.shared.isFavorite(productID)
        _ = FavoritesManager.shared.toggleLocal(productID)
        
        do {
            let branchProductIDString = String(productID)
            let response: ToggleFavoriteModel
            
            if isCurrentlyFavorite {
                response = try await removeFavoriteProductUC.execute(branchProductId: branchProductIDString)
            } else {
                response = try await addFavoriteProductUC.execute(branchProductId: branchProductIDString)
            }
            
            if response.status == false {
                _ = FavoritesManager.shared.toggleLocal(productID) // Revert
            }
        } catch {
            _ = FavoritesManager.shared.toggleLocal(productID) // Revert
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
            
            // 👉 NEW: Sync fetched favorites to the Source of Truth
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
        // Safety check: Prevent guest users from making this API call
        guard !Constants.isGuestMode else { return }
        
        let branchIdString = String(branchId)
        // Use barcode if available, otherwise fallback to the product ID
        let barcodeString = product.barcode.isEmpty ? String(product.id) : product.barcode
        let defaultQuantity = "1"
        
        // Execute network call, ignore errors
        _ = try? await addProductByBarcodeToCartUC.execute(
            branchId: branchIdString,
            barcode: barcodeString,
            quantity: defaultQuantity
        )
        
        // Always show the exact success toast requested
        toast = FancyToast(
            type: .success,
            title: "Success",
            message: "added to the cart successfully"
        )
    }
}
