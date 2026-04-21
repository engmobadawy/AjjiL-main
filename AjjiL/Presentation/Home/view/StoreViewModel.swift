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
        
        // Listen for global favorite changes (e.g., from ProductDetailsView)
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("FavoriteToggled"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let id = userInfo["id"] as? Int,
                  let isFavorite = userInfo["isFavorite"] as? Bool else { return }
            
            // Instantly update the product in our local list if it exists
            if let index = self.storeProducts.firstIndex(where: { $0.id == id }) {
                self.storeProducts[index].isFavorite = isFavorite
            }
        }
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(for productID: Int) async {
        guard let index = storeProducts.firstIndex(where: { $0.id == productID }) else { return }
        
        let isCurrentlyFavorite = storeProducts[index].isFavorite
        let branchProductIDString = String(productID)
        let newFavoriteState = !isCurrentlyFavorite
        
        // 1. Optimistic UI Update locally
        storeProducts[index].isFavorite = newFavoriteState
        
        // BROADCAST the change so HomeView and FavoritesView update instantly
        NotificationCenter.default.post(
            name: NSNotification.Name("FavoriteToggled"),
            object: nil,
            userInfo: ["id": productID, "isFavorite": newFavoriteState]
        )
        
        // 2. Network Call
        do {
            let response: ToggleFavoriteModel
            if isCurrentlyFavorite {
                response = try await removeFavoriteProductUC.execute(branchProductId: branchProductIDString)
            } else {
                response = try await addFavoriteProductUC.execute(branchProductId: branchProductIDString)
            }
            
            // 3. Revert if backend says it failed
            if response.status == false {
                storeProducts[index].isFavorite = isCurrentlyFavorite
                NotificationCenter.default.post(
                    name: NSNotification.Name("FavoriteToggled"),
                    object: nil,
                    userInfo: ["id": productID, "isFavorite": isCurrentlyFavorite]
                )
            }
        } catch {
            // Revert on network crash
            storeProducts[index].isFavorite = isCurrentlyFavorite
            NotificationCenter.default.post(
                name: NSNotification.Name("FavoriteToggled"),
                object: nil,
                userInfo: ["id": productID, "isFavorite": isCurrentlyFavorite]
            )
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
