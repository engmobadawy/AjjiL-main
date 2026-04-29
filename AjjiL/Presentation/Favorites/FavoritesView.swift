//
//  FavoritesView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 18/02/2026.
//

import SwiftUI
import Shimmer

struct FavoritesView: View {
    @AppStorage("savedBranchID") private var savedBranchID: Int = 0
    
    // 🛠️ FIX: Use @Bindable for an injected @Observable dependency that needs bindings
    @Bindable private var viewModel: FavoritesViewModel = DependencyContainer.FavoritesDependency.shared.favoritesVM
    
    // NEW: Replaced boolean with our item-based routing state
    @State private var scannerDestination: ScannerDestination?
    
    private enum ViewState {
        case loading
        case empty
        case notEmpty
    }
    
    private var currentState: ViewState {
        if viewModel.isLoading && viewModel.products.isEmpty {
            return .loading
        } else if viewModel.products.isEmpty {
            return .empty
        } else {
            return .notEmpty
        }
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationStack {
                TopRowNotForHome(
                    title: "Favorites".newlocalized,
                    showBackButton: false,
                    kindOfTopRow: .justNotification
                )
            
                ScrollView {
                    switch currentState {
                    case .loading:
                        FavoritesGridSkeleton()
                            .shimmering()
                            .padding(.top, 16)
                            
                    case .empty:
                        VStack(alignment: .center, spacing: 28) {
                            Image("NoFavorites")
                                .resizable()
                                .frame(width: 168, height: 168)
                            
                            Text("No Favorites yet".newlocalized)
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
                                            let branchId = savedBranchID == 0 ? 1 : savedBranchID
                                            Task {
                                                await viewModel.addToCart(product: product.asHomeProduct, branchId: branchId)
                                            }
                                        },
                                        onScanToBuy: {
                                            // NEW: Trigger the scanner route with the specific product
                                            scannerDestination = ScannerDestination(product: product.asHomeProduct)
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
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
                // NEW: Model-based navigation to Scanner
                .navigationDestination(item: $scannerDestination) { destination in
                    ScannerMainView(
                        product: destination.product,
                        onAddToCart: { scannedProduct in
                            let branchId = savedBranchID == 0 ? 1 : savedBranchID
                            await viewModel.addToCart(product: scannedProduct, branchId: branchId)
                        },
                        onGoToCart: {
                            // Adjust based on your TabBar structure to switch to the Cart tab
                            print("Navigating to cart from Favorites...")
                        },
                        onGoToStore: {
                            // Dismiss happens automatically in ScannerMainView
                            print("Returning to Favorites...")
                        }
                    )
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
struct FavoritesGridSkeleton: View {
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<6, id: \.self) { _ in
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 220)
                    .clipShape(.rect(cornerRadius: 16))
            }
        }
    }
}
