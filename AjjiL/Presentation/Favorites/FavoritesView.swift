//
//  FavoritesView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 18/02/2026.
//

import SwiftUI
import Shimmer // 1. Import Shimmer

struct FavoritesView: View {
    // 👈 1. Add branch ID AppStorage to know where to add the cart item
        @AppStorage("savedBranchID") private var savedBranchID: Int = 0
    
    // Automatically injected from your Dependency Container
    @State private var viewModel: FavoritesViewModel = DependencyContainer.FavoritesDependency.shared.favoritesVM
    
    @State private var showScannerView: Bool = false
    
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
                        // 2. Replace ProgressView with the Shimmering Skeleton
                        FavoritesGridSkeleton()
                            .shimmering()
                            .padding(.top, 16)
                            
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
                                        isFavorite: FavoritesManager.shared.isFavorite(product.id),
                                        onToggleFavorite: {
                                            Task {
                                                await viewModel.toggleFavorite(for: product)
                                            }
                                        },
                                        onAddToCart: {
                                            // 👈 2. Call addToCart using asHomeProduct
                                            let branchId = savedBranchID == 0 ? 1 : savedBranchID
                                            Task {
                                                await viewModel.addToCart(product: product.asHomeProduct, branchId: branchId)
                                            }
                                        },
                                        onScanToBuy: { showScannerView = true }
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
                        viewModel: ProductDetailsViewModel(
                            branchProductId: product.id,
                            getProductDetailsUC: DependencyContainer.FavoritesDependency.shared.getProductDetailsUC,
                            addFavoriteProductUC: DependencyContainer.FavoritesDependency.shared.addFavoriteProductUC,
                            removeFavoriteProductUC: DependencyContainer.FavoritesDependency.shared.removeFavoriteProductUC,
                            addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC(
                                                    repo: CartRepositoryImp(networkService: DependencyContainer.shared.networkService)
                                                )
                        )
                    )
                }
                .navigationDestination(isPresented: $showScannerView) {
                                    ScannerMainView()
                                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.fetchFavorites()
        }
        .toastView(toast: $viewModel.toast)
    }
}

// MARK: - Skeleton View

/// 3. Dedicated Skeleton mimicking your 2-column Product Grid
struct FavoritesGridSkeleton: View {
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<6, id: \.self) { _ in
                // A simple placeholder block representing the height of HomeProductCard
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 220)
                    .clipShape(.rect(cornerRadius: 16))
            }
        }
    }
}
