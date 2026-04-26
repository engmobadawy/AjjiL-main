import SwiftUI
import Observation

@Observable
@MainActor
final class ProductDetailsViewModel {
    let branchProductId: Int
    
    var productDetail: ProductDetailResponse?
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var toast: FancyToast?
    
    // UseCases
    private let getProductDetailsUC: GetProductDetailsUC
    private let addFavoriteProductUC: AddFavoriteProductUC
    private let removeFavoriteProductUC: RemoveFavoriteProductUC
    private let addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC // 争 Add this
    
    init(
        branchProductId: Int,
        getProductDetailsUC: GetProductDetailsUC,
        addFavoriteProductUC: AddFavoriteProductUC,
        removeFavoriteProductUC: RemoveFavoriteProductUC,
        addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC // 争 Add this
    ) {
        self.branchProductId = branchProductId
        self.getProductDetailsUC = getProductDetailsUC
        self.addFavoriteProductUC = addFavoriteProductUC
        self.removeFavoriteProductUC = removeFavoriteProductUC
        self.addProductByBarcodeToCartUC = addProductByBarcodeToCartUC // 争 Initialize it
    }
    
    func fetchProductDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            productDetail = try await getProductDetailsUC.execute(branchProductId: branchProductId)
            
            // 痩 NEW: Sync fetched status to the Source of Truth
            if let p = productDetail {
                FavoritesManager.shared.setFavorite(p.productBranchId, isFavorite: p.isFavorite)
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
        
    func toggleFavorite() async {
        // Safety check: Prevent guest users from making this API call
        guard !Constants.isGuestMode else { return }
        
        guard let currentProduct = productDetail else { return }
        let productID = currentProduct.productBranchId
        
        let isCurrentlyFavorite = FavoritesManager.shared.isFavorite(productID)
        let branchProductIDString = String(productID)
        
        // 1. Optimistic UI Update locally
        _ = FavoritesManager.shared.toggleLocal(productID)
        
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
                _ = FavoritesManager.shared.toggleLocal(productID) // Revert
                errorMessage = response.message ?? "Failed to update favorite."
            }
        } catch {
            _ = FavoritesManager.shared.toggleLocal(productID) // Revert
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func addToCart(branchId: Int) async {
        // Safety check: Prevent guest users from making this API call
        guard !Constants.isGuestMode else { return }
        
        guard let product = productDetail else { return }
        
        let branchIdString = String(branchId)
        // Use barcode if available, fallback to productBranchId
        let barcodeString = product.barcode.isEmpty ? String(product.productBranchId) : product.barcode
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
