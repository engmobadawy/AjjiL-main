//
//  FavoritesView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 18/02/2026.
//

import SwiftUI
import Shimmer

// MARK: - Routing Destinations
struct ScannerDestination: Hashable {
    let product: HomeFeaturedProductDataEntity
    var storeId: Int? = nil
    var storeName: String? = nil
    var branchId: Int? = nil
}

struct StoreRoutingDestination: Hashable {
    let storeId: Int
    let storeName: String
    var skipBranchSelection: Bool = false
}

// 🛠️ NEW: Added CartRoutingDestination
//struct CartRoutingDestination: Hashable {
//    let storeId: Int
//    let storeName: String
//    let branchId: Int
//}

// MARK: - Main View
struct FavoritesView: View {
    @AppStorage("savedBranchID") private var savedBranchID: Int = 0
    
    @Bindable private var viewModel: FavoritesViewModel = DependencyContainer.FavoritesDependency.shared.favoritesVM
    
    // Routing states
    @State private var scannerDestination: ScannerDestination?
    @State private var storeDestination: StoreRoutingDestination?
    @State private var cartDestination: CartRoutingDestination? // 🛠️ NEW: State for Cart routing
    
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
                                            scannerDestination = ScannerDestination(
                                                product: product.asHomeProduct,
                                                storeId: product.storeId,
                                                storeName: product.brand,
                                                branchId: product.branchId
                                            )
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
                
                // MARK: Navigation Routing
                
                // 1. Details Route
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
                
                // 2. Scanner Route
                .navigationDestination(item: $scannerDestination) { destination in
                    ScannerMainView(
                        product: destination.product,
                        onAddToCart: { scannedProduct in
                            let branchId = savedBranchID == 0 ? 1 : savedBranchID
                            await viewModel.addToCart(product: scannedProduct, branchId: branchId)
                        },
                        onGoToCart: {
                            // 🛠️ NEW: Unwrap data, delay, and route to Cart
                            if let sId = destination.storeId,
                               let sName = destination.storeName,
                               let bId = destination.branchId {
                                
                                savedBranchID = bId // Pre-select the branch globally
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    cartDestination = CartRoutingDestination(
                                        storeId: sId,
                                        storeName: sName,
                                        branchId: bId
                                    )
                                }
                            }
                        },
                        onGoToStore: {
                            if let sId = destination.storeId,
                               let sName = destination.storeName,
                               let bId = destination.branchId {
                                
                                savedBranchID = bId // Pre-select the branch
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    storeDestination = StoreRoutingDestination(
                                        storeId: sId,
                                        storeName: sName,
                                        skipBranchSelection: true
                                    )
                                }
                            }
                        }
                    )
                }
                
                // 3. Store Route (Triggered from Scanner)
                .navigationDestination(item: $storeDestination) { destination in
                    StoreView(
                        storeName: destination.storeName,
                        storeId: destination.storeId,
                        showBranchSelection: !destination.skipBranchSelection
                    )
                }
                
                // 4. Cart Route (Triggered from Scanner)
                .navigationDestination(item: $cartDestination) { destination in
                    // 🛠️ NEW: Initialize and inject the CartViewModel
                    let cartRepo = CartRepositoryImp(networkService: DependencyContainer.shared.networkService)
                    let ordersRepo = OrdersRepositoryImp(networkService: DependencyContainer.shared.networkService)
                    
                    let cartViewModel = CartViewModel(
                        getCartUC: GetCartUC(repo: cartRepo),
                        changeCartItemQuantityUC: ChangeCartItemQuantityUC(repo: cartRepo),
                        removeProductFromCartUC: RemoveProductFromCartUC(repo: cartRepo),
                        verifyPromoCodeUC: VerifyPromoCodeUseCase(networkService: DependencyContainer.shared.networkService),
                        submitOrderUC: SubmitOrderUC(repo: ordersRepo)
                    )
                    
                    CartView(
                        viewModel: cartViewModel,
                        branchId: String(destination.branchId),
                        storeName: destination.storeName,
                        storeId: String(destination.storeId)
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
