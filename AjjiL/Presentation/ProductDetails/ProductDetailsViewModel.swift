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
    
    // REMOVED the descriptionPoints array from here
    
    init(
        branchProductId: Int,
        getProductDetailsUC: GetProductDetailsUC,
        addFavoriteProductUC: AddFavoriteProductUC,
        removeFavoriteProductUC: RemoveFavoriteProductUC
    ) {
        self.branchProductId = branchProductId
        self.getProductDetailsUC = getProductDetailsUC
        self.addFavoriteProductUC = addFavoriteProductUC
        self.removeFavoriteProductUC = removeFavoriteProductUC
    }
    
    func fetchProductDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            productDetail = try await getProductDetailsUC.execute(branchProductId: branchProductId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleFavorite() async {
            guard let currentProduct = productDetail else { return }
            let isCurrentlyFavorite = currentProduct.isFavorite
            let branchProductIDString = String(currentProduct.productBranchId)
            
            // 1. Optimistic UI Update
            productDetail?.isFavorite.toggle()
            let newFavoriteState = !isCurrentlyFavorite
            
            // BROADCAST the change so HomeView and FavoritesView update instantly
            NotificationCenter.default.post(
                name: NSNotification.Name("FavoriteToggled"),
                object: nil,
                userInfo: ["id": currentProduct.productBranchId, "isFavorite": newFavoriteState]
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
                    productDetail?.isFavorite = isCurrentlyFavorite
                    
                    // Revert broadcast on failure
                    NotificationCenter.default.post(
                        name: NSNotification.Name("FavoriteToggled"),
                        object: nil,
                        userInfo: ["id": currentProduct.productBranchId, "isFavorite": isCurrentlyFavorite]
                    )
                    errorMessage = response.message ?? "Failed to update favorite."
                }
            } catch {
                productDetail?.isFavorite = isCurrentlyFavorite
                
                // Revert broadcast on failure
                NotificationCenter.default.post(
                    name: NSNotification.Name("FavoriteToggled"),
                    object: nil,
                    userInfo: ["id": currentProduct.productBranchId, "isFavorite": isCurrentlyFavorite]
                )
                errorMessage = error.localizedDescription
            }
        }
    
    func scanToBuy() {
        print("Initiating scan to buy for \(productDetail?.name ?? "Unknown")")
    }
    
    @MainActor
    func addToCart(branchId: Int) async {
        guard let product = productDetail else { return }
        // Call your cart use case or repository here using the branchId and product
    }
}
