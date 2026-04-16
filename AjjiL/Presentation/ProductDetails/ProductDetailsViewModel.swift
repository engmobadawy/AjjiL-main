//
//  ProductDetailsViewModel.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/03/2026.
//


import SwiftUI
import Observation

@Observable
@MainActor
final class ProductDetailsViewModel {
    // MARK: - Properties
    let product: HomeFeaturedProductDataEntity
    var isFavorite: Bool
    private let onToggleFavoriteCallback: () -> Void
    
    let descriptionPoints = [
        "1. Hit the orange button down below to Create an order.",
        "2. Select your preferred delivery method and time.",
        "3. Confirm your payment details to proceed."
    ]
    
    // MARK: - Initialization
    init(product: HomeFeaturedProductDataEntity, isFavorite: Bool, onToggleFavorite: @escaping () -> Void) {
        self.product = product
        self.isFavorite = isFavorite
        self.onToggleFavoriteCallback = onToggleFavorite
    }
    
    // MARK: - Actions
    func toggleFavorite() {
        isFavorite.toggle()
        onToggleFavoriteCallback()
    }
    
    func scanToBuy() {
        // Add specific business logic for initiating the purchase here
        print("Initiating scan to buy for \(product.name)")
    }
}
