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
    private let addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
    
    init(
        branchProductId: Int,
        getProductDetailsUC: GetProductDetailsUC,
        addFavoriteProductUC: AddFavoriteProductUC,
        removeFavoriteProductUC: RemoveFavoriteProductUC,
        addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
    ) {
        self.branchProductId = branchProductId
        self.getProductDetailsUC = getProductDetailsUC
        self.addFavoriteProductUC = addFavoriteProductUC
        self.removeFavoriteProductUC = removeFavoriteProductUC
        self.addProductByBarcodeToCartUC = addProductByBarcodeToCartUC
    }
    
    func fetchProductDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            productDetail = try await getProductDetailsUC.execute(branchProductId: branchProductId)
            
            // Sync fetched status to the Source of Truth
            if let p = productDetail {
                FavoritesManager.shared.setFavorite(p.productBranchId, isFavorite: p.isFavorite)
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
        
    func toggleFavorite() async {
        guard !Constants.isGuestMode else { return }
        guard let currentProduct = productDetail else { return }
        
        let productID = currentProduct.productBranchId
        let isCurrentlyFavorite = FavoritesManager.shared.isFavorite(productID)
        let branchProductIDString = String(productID)
        
        // 1. Optimistic UI Update globally AND locally
        _ = FavoritesManager.shared.toggleLocal(productID)
        productDetail?.isFavorite = !isCurrentlyFavorite // 🛠️ FIX: Keep local object in sync
        
        // 2. Network Call
        do {
            let response: ToggleFavoriteModel
            if isCurrentlyFavorite {
                response = try await removeFavoriteProductUC.execute(branchProductId: branchProductIDString)
            } else {
                response = try await addFavoriteProductUC.execute(branchProductId: branchProductIDString)
            }
            
            // 3. Revert if backend says it failed
            // 3. Revert if backend says it failed
                        if response.status == false {
                            revertFavoriteState(for: productID, wasFavorite: isCurrentlyFavorite)
                            // 🛠️ FIX: Added .newlocalized
                            errorMessage = response.message ?? "Failed to update favorite.".newlocalized
                        }
        } catch {
            revertFavoriteState(for: productID, wasFavorite: isCurrentlyFavorite)
            errorMessage = error.localizedDescription
        }
    }
    
    // 🛠️ FIX: Clean helper for reverting both states
    private func revertFavoriteState(for productID: Int, wasFavorite: Bool) {
        _ = FavoritesManager.shared.toggleLocal(productID)
        productDetail?.isFavorite = wasFavorite
    }
    
    func addToCart(branchId: Int) async {
        guard !Constants.isGuestMode else { return }
        guard let product = productDetail else { return }
        
        let branchIdString = String(branchId)
        let barcodeString = product.barcode.isEmpty ? String(product.productBranchId) : product.barcode
        let defaultQuantity = "1"
        
        _ = try? await addProductByBarcodeToCartUC.execute(
            branchId: branchIdString,
            barcode: barcodeString,
            quantity: defaultQuantity
        )
        
        // 🛠️ FIX: Added .newlocalized to the toast titles and messages
                toast = FancyToast(
                    type: .success,
                    title: "Success".newlocalized,
                    message: "added to the cart successfully".newlocalized
                )
    }
}
