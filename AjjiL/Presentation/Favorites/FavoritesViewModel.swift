//
//  FavoritesViewModel.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 08/03/2026.
//
import SwiftUI
import Observation

@MainActor
@Observable
final class FavoritesViewModel {
    private let getFavoriteProductsUC: GetFavoriteProductsUC
    private let addFavoriteProductUC: AddFavoriteProductUC
    private let removeFavoriteProductUC: RemoveFavoriteProductUC
    private let addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
        
    var products: [FavoriteProductDataEntity] = []
    var isLoading = false
    var errorMessage: String?
    var toast: FancyToast?
  
    // MARK: - Initialization
    init(
        getFavoriteProductsUC: GetFavoriteProductsUC,
        addFavoriteProductUC: AddFavoriteProductUC,
        removeFavoriteProductUC: RemoveFavoriteProductUC,
        addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
    ) {
        self.getFavoriteProductsUC = getFavoriteProductsUC
        self.addFavoriteProductUC = addFavoriteProductUC
        self.removeFavoriteProductUC = removeFavoriteProductUC
        self.addProductByBarcodeToCartUC = addProductByBarcodeToCartUC
    }
    
    // MARK: - Data Fetching
    func fetchFavorites() async {
        let token = GenericUserDefault.shared.getValue(Constants.shared.token) as? String ?? ""
        
        guard !token.isEmpty else {
            products = []
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await getFavoriteProductsUC.execute()
            
            // 🔄 SYNC WITH MANAGER: Update the global SSOT with fetched data
            for product in products {
                FavoritesManager.shared.setFavorite(product.id, isFavorite: product.isFavorite)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
   
    func toggleFavorite(for product: FavoriteProductDataEntity) async {
        let index = products.firstIndex(where: { $0.id == product.id })
        let wasFavorite = index != nil ? products[index!].isFavorite : false
        
        // Optimistic UI: Toggle state or add it back to the array
        if let index = index {
            products[index].isFavorite.toggle()
        } else {
            var restoredProduct = product
            restoredProduct.isFavorite = true
            withAnimation {
                products.insert(restoredProduct, at: 0)
            }
        }
        
        // 🔄 SYNC WITH MANAGER: Optimistically toggle the global state
        FavoritesManager.shared.setFavorite(product.id, isFavorite: !wasFavorite)
        
        // Call the backend
        do {
            let branchProductIDString = String(product.id)
            let response: ToggleFavoriteModel
            
            if wasFavorite {
                response = try await removeFavoriteProductUC.execute(branchProductId: branchProductIDString)
            } else {
                response = try await addFavoriteProductUC.execute(branchProductId: branchProductIDString)
            }
            
            if response.status == false {
                // Revert on backend failure
                revertFavoriteState(for: product, wasFavorite: wasFavorite)
                errorMessage = response.message ?? "Failed to update favorite status."
            } else if wasFavorite {
                // SUCCESS: The item was un-favorited. Remove it from the grid safely.
                withAnimation {
                    products.removeAll(where: { $0.id == product.id })
                }
            }
            
        } catch {
            // Revert on network crash
            revertFavoriteState(for: product, wasFavorite: wasFavorite)
            errorMessage = error.localizedDescription
        }
    }
        
    // Helper function to cleanly handle reverting state
    private func revertFavoriteState(for product: FavoriteProductDataEntity, wasFavorite: Bool) {
        // 🔄 SYNC WITH MANAGER: Revert the global state on failure
        FavoritesManager.shared.setFavorite(product.id, isFavorite: wasFavorite)
        
        if wasFavorite {
            if let revertIndex = products.firstIndex(where: { $0.id == product.id }) {
                products[revertIndex].isFavorite = true
            } else {
                var restored = product
                restored.isFavorite = true
                products.insert(restored, at: 0)
            }
        } else {
            products.removeAll(where: { $0.id == product.id })
        }
    }
    
    func addToCart(product: HomeFeaturedProductDataEntity, branchId: Int) async {
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
            title: "Success",
            message: "added to the cart successfully"
        )
    }
}
