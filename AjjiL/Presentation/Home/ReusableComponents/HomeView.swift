import SwiftUI
import Shimmer


//// MARK: - Routing Destinations
//struct ScannerDestination: Hashable {
//    let product: HomeFeaturedProductDataEntity
//    var storeId: Int? = nil
//    var storeName: String? = nil
//    var branchId: Int? = nil
//}
//
//struct StoreRoutingDestination: Hashable {
//    let storeId: Int
//    let storeName: String
//    var skipBranchSelection: Bool = false
//}
//
//// 🛠️ NEW: Added CartRoutingDestination
//struct CartRoutingDestination: Hashable {
//    let storeId: Int
//    let storeName: String
//    let branchId: Int
//}

// MARK: - Main View
struct HomeView: View {
    @Environment(TabBarVisibility.self) private var tabVisibility
    
    @AppStorage("isStoreMode") private var isStoreMode: Bool = false
    @AppStorage("savedBranchID") private var savedBranchID: Int = 0
    
    @Bindable private var viewModel = DependencyContainer.HomeDependency.shared.homeVM
//    @State private var searchText: String = ""
   
    @State private var showNotificationsView: Bool = false
    @State private var showGuestLoginSheet: Bool = false
    
    // Routing Destinations
    @State private var scannerDestination: ScannerDestination?
    @State private var storeDestination: StoreRoutingDestination?
    @State private var cartDestination: CartRoutingDestination? // 🛠️ NEW: State for Cart routing
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HomeTopRow()
                
                searchAndToggleHeader
                
                ScrollView {
                    if viewModel.isLoading {
                        skeletonLayout
                            .shimmering()
                    } else {
                        VStack(spacing: 18) {
                            BannerCollectionView(banners: viewModel.sliderCards)
                            
                            storesSection
                            
                            featuredProductsHeader
                            
                            featuredProductsGrid
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 18)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .background(.white)
            .navigationBarBackButtonHidden(true)
            
            // 1. Standard Product Details Route
            .navigationDestination(for: HomeFeaturedProductDataEntity.self) { product in
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
            
            // 2. Standard Store Route (From Store List -> SHOWS Popup)
            .navigationDestination(for: HomeStoresDataEntity.self) { store in
                StoreView(storeName: store.name, storeId: store.id)
            }
            
            .navigationDestination(isPresented: $showNotificationsView) {
                HomeView()
            }
            
            // 3. Scanner Route
            .navigationDestination(item: $scannerDestination) { destination in
                ScannerMainView(
                    product: destination.product,
                    onAddToCart: { scannedProduct in
                        let branchId = savedBranchID == 0 ? 1 : savedBranchID
                        await viewModel.addToCart(product: scannedProduct, branchId: branchId)
                    },
                    onGoToCart: {
                        // 🛠️ NEW: Safely unwrap and route to cart!
                        if let sId = destination.storeId,
                           let sName = destination.storeName,
                           let bId = destination.branchId {
                            
                            savedBranchID = bId // Pre-select the branch globally
                            
                            // Delay execution to let the scanner completely dismiss
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
                        // Safely unwrap.
                        if let sId = destination.storeId,
                           let sName = destination.storeName,
                           let bId = destination.branchId {
                            
                            savedBranchID = bId // Pre-select the branch in AppStorage
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                storeDestination = StoreRoutingDestination(
                                    storeId: sId,
                                    storeName: sName,
                                    skipBranchSelection: true // Skips the branch popup
                                )
                            }
                        }
                    }
                )
            }
            
            // 4. Scanner-To-Store Route (SKIPS Popup)
            .navigationDestination(item: $storeDestination) { destination in
                StoreView(
                    storeName: destination.storeName,
                    storeId: destination.storeId,
                    showBranchSelection: !destination.skipBranchSelection
                )
            }
            
            // 5. Cart Route (Triggered from Scanner's "Go To Cart")
            .navigationDestination(item: $cartDestination) { destination in
                // Initialize the CartViewModel exactly as StoreView does
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
            
            .sheet(isPresented: $showGuestLoginSheet) {
                GuestLoginSheetView()
                    .presentationDetents([.fraction(0.5), .medium])
                    .presentationDragIndicator(.visible)
                    .background(.white)
            }
        }
        .task {
            await viewModel.fetchData()
        }
        .toastView(toast: $viewModel.toast)
    }

    // MARK: - Skeleton Loading Layout
    private var skeletonLayout: some View {
        VStack(spacing: 18) {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .clipShape(.rect(cornerRadius: 12))
                .frame(height: 160)
            
            VStack(alignment: .leading, spacing: 12) {
                storesHeader
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { _ in
                            Circle()
                                .fill(.gray.opacity(0.3))
                                .frame(width: 80, height: 80)
                        }
                    }
                }
                .disabled(true)
            }
            
            featuredProductsHeader
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(0..<4, id: \.self) { _ in
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .clipShape(.rect(cornerRadius: 16))
                        .frame(height: 220)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
    }

    // MARK: - Extracted Header
    private var searchAndToggleHeader: some View {
        VStack(spacing: 7) {
            ShopThroughBanner(isStoreMode: $isStoreMode)
            
//            SearchBarButton(text: $searchText) {
//                print("Searching for: \(searchText)")
//            }
//            .padding(.horizontal, 18)
        }
        .padding(.bottom, 12)
    }

    // MARK: - Product Grid
    private var featuredProductsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(viewModel.featuredProducts) { product in
                NavigationLink(value: product) {
                    HomeProductCard(
                        product: product,
                        isFavorite: FavoritesManager.shared.isFavorite(product.id),
                        onToggleFavorite: {
                            if Constants.isGuestMode {
                                showGuestLoginSheet = true
                            } else {
                                Task { await viewModel.toggleFavorite(for: product.id) }
                            }
                        },
                        onAddToCart: {
                            if Constants.isGuestMode {
                                showGuestLoginSheet = true
                            } else {
                                let branchId = savedBranchID == 0 ? 1 : savedBranchID
                                Task {
                                    await viewModel.addToCart(product: product, branchId: branchId)
                                }
                            }
                        },
                        onScanToBuy: {
                            if Constants.isGuestMode {
                                showGuestLoginSheet = true
                            } else {
                                scannerDestination = ScannerDestination(
                                    product: product,
                                    storeId: product.storeId,
                                    storeName: product.brand, // Maps to the brand field
                                    branchId: product.branchId
                                )
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Stores Section
    private var storesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            storesHeader
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.homeStores) { store in
                        NavigationLink(value: store) {
                            StorescardVeiw(imageURL: store.image)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollClipDisabled()
            .contentMargins(.horizontal, 0, for: .scrollContent)
        }
    }

    private var storesHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Stores".newlocalized)
                .font(.title3.bold())
            Spacer()
        }
    }
    
    private var featuredProductsHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Featured Products".newlocalized)
                .font(.title3.bold())
            Spacer()
        }
        .padding(.top, 16)
    }
}

// MARK: - Custom Components

struct ShopThroughBanner: View {
    @Binding var isStoreMode: Bool
    
    private let brandGreen = Color(red: 0.21, green: 0.60, blue: 0.51)
    private let brandLightGreen = Color(red: 0.88, green: 0.98, blue: 0.95)

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: "storefront.fill")
                    .font(.system(size: 18))
                Text("Shop through".newlocalized)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("Store".newlocalized)
                    .font(.subheadline.weight(.medium))
                
                Toggle("", isOn: $isStoreMode)
                    .labelsHidden()
                    .scaleEffect(0.8)
                    .tint(brandGreen)
            }
        }
        .foregroundStyle(brandGreen)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(brandLightGreen)
    }
}

// MARK: - Guest Login Sheet

struct GuestLoginSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Image("loginFirst")
                .resizable()
                .scaledToFit()
                .frame(width: 252, height: 168)
            
            Text("Login First, To Complete\nYour Order".newlocalized)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(red: 0.28, green: 0.63, blue: 0.44))
                .multilineTextAlignment(.center)
            
            GreenButton(title: "Sign In".newlocalized) {
                dismiss()
                
                UserDefaults.standard.set(false, forKey: "pressSkip")
                Constants.isGuestMode = false
                
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.reset()
                }
            }
            .padding(.top, 8)
        }
        .padding(32)
    }
}
