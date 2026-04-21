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
    private let addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC // 👈 1. Add UseCase
        
    var products: [FavoriteProductDataEntity] = []
    var isLoading = false
    var errorMessage: String?
    var toast: FancyToast? // 👈 2. Add Toast state
  
    // MARK: - Initialization
    init(
        getFavoriteProductsUC: GetFavoriteProductsUC,
        addFavoriteProductUC: AddFavoriteProductUC,
        removeFavoriteProductUC: RemoveFavoriteProductUC,
        addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC // 👈 3. Add to init
    ) {
        self.getFavoriteProductsUC = getFavoriteProductsUC
        self.addFavoriteProductUC = addFavoriteProductUC
        self.removeFavoriteProductUC = removeFavoriteProductUC
        self.addProductByBarcodeToCartUC = addProductByBarcodeToCartUC
    }
    
    // MARK: - Data Fetching
    func fetchFavorites() async {
        // 1. Check if the user is logged in (has a token)
        let token = GenericUserDefault.shared.getValue(Constants.shared.token) as? String ?? ""
        
        // 2. If no token, immediately return so the UI shows the "empty" state
        guard !token.isEmpty else {
            products = []
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await getFavoriteProductsUC.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
   
    func toggleFavorite(for product: FavoriteProductDataEntity) async {
        // (No changes needed here. If the grid is empty, the user can't tap a product anyway)
        
        // 1. Find if the product is currently in the array
        let index = products.firstIndex(where: { $0.id == product.id })
        let wasFavorite = index != nil ? products[index!].isFavorite : false
        
        // Optimistic UI: Toggle state or add it back to the array
        if let index = index {
            products[index].isFavorite.toggle()
        } else {
            // The user is re-favoriting an item from the Details screen!
            var restoredProduct = product
            restoredProduct.isFavorite = true
            withAnimation {
                products.insert(restoredProduct, at: 0) // Put it back at the top of the grid
            }
        }
        
        // 2. Call the backend
        do {
            let branchProductIDString = String(product.id)
            let response: ToggleFavoriteModel
            
            if wasFavorite {
                response = try await removeFavoriteProductUC.execute(branchProductId: branchProductIDString)
            } else {
                response = try await addFavoriteProductUC.execute(branchProductId: branchProductIDString)
            }
            
            // 3. Handle backend response
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
        if wasFavorite {
            // It was favorited, we tried to remove it, and failed. Ensure it's in the array as true.
            if let revertIndex = products.firstIndex(where: { $0.id == product.id }) {
                products[revertIndex].isFavorite = true
            } else {
                var restored = product
                restored.isFavorite = true
                products.insert(restored, at: 0)
            }
        } else {
            // It wasn't favorited, we tried to add it, and failed. Remove it.
            products.removeAll(where: { $0.id == product.id })
        }
    }
    
    func addToCart(product: HomeFeaturedProductDataEntity, branchId: Int) async {
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
                title: "Success",
                message: "added to the cart successfully"
            )
        }
    
}
