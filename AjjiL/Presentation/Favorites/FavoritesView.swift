//
//  FavoritesView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 18/02/2026.
//

import SwiftUI

struct FavoritesView: View {
    
    // Automatically injected from your Dependency Container
    @State private var viewModel: FavoritesViewModel = DependencyContainer.FavoritesDependency.shared.favoritesVM
    
    private enum ViewState {
        case loading
        case empty
        case notEmpty
    }
    
    // Computed property ensures the UI always matches the exact data state
    private var currentState: ViewState {
        if viewModel.isLoading && viewModel.products.isEmpty {
            return .loading
        } else if viewModel.products.isEmpty {
            return .empty
        } else {
            return .notEmpty
        }
    }
    
    // Grid configuration: Two flexible columns with 16pt spacing
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationStack {
                TopRowNotForHome(
                    title: "Favorites",
                    showBackButton: false,
                    kindOfTopRow: .justNotification
                )
            
                ScrollView {
                    switch currentState {
                    case .loading:
                        ProgressView()
                            .padding(.top, 198)
                            
                    case .empty:
                        VStack(alignment: .center, spacing: 28) {
                            Image("NoFavorites")
                                .resizable()
                                .frame(width: 168, height: 168)
                            
                            Text("No Favorites yet")
                                .font(.custom("Poppins-SemiBold", size: 28))
                        }
                        .padding(.top, 198)
                        
                    case .notEmpty:
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.products) { product in
                                NavigationLink(value: product) {
                                    HomeProductCard(
                                        product: product.asHomeProduct,
                                        isFavorite: product.isFavorite,
                                        onToggleFavorite: {
                                            Task {
                                                await viewModel.toggleFavorite(for: product)
                                            }
                                        },
                                        onAddToCart: { viewModel.addToCart(product: product) },
                                        onScanToBuy: { viewModel.scanToBuy(product: product) }
                                    )
                                }
                                .buttonStyle(.plain) // Prevents the whole card from styling as a default button
                            }
                        }
                        .padding(.top, 16)
                    }
                }
                .padding(.horizontal, 18)
                .navigationDestination(for: FavoriteProductDataEntity.self) { product in
                    ProductDetailsView(
                        product: product.asHomeProduct,
                        isFavorite: viewModel.products.first(where: { $0.id == product.id })?.isFavorite ?? product.isFavorite,
                        onToggleFavorite: {
                            Task {
                                await viewModel.toggleFavorite(for: product)
                            }
                        }
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.fetchFavorites()
        }
    }
}
