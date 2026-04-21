import SwiftUI
import Kingfisher
import Shimmer

struct StoreView: View {
    let storeName: String
    let storeId: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var showAllCategories: Bool = false
    @State private var showScannerView: Bool = false
    
    // Global HomeViewModel for shared state like favorites and branches
    var homeViewModel = DependencyContainer.HomeDependency.shared.homeVM
    
    // Local StoreViewModel managing the store's specific state
    @State private var storeViewModel = StoreViewModel(
        getStoreSlidersUC: GetStoreSlidersUC(repo: StoreRepositoryImp(networkService: DependencyContainer.shared.networkService)),
        getFeaturedProductsUCForStore: GetFeaturedProductsUCForStore(repo: StoreRepositoryImp(networkService: DependencyContainer.shared.networkService)),
        getHomeCategoriesUC: GetHomeCategoriesUC(repo: StoreRepositoryImp(networkService: DependencyContainer.shared.networkService)),
        getStoreSubcategoriesUC: GetStoreSubcategoriesUC(repo: StoreRepositoryImp(networkService: DependencyContainer.shared.networkService)),
        getProductsByCategoryUC: GetProductsByCategoryUC(repo: StoreRepositoryImp(networkService: DependencyContainer.shared.networkService)),
        addFavoriteProductUC: DependencyContainer.FavoritesDependency.shared.addFavoriteProductUC,
        removeFavoriteProductUC: DependencyContainer.FavoritesDependency.shared.removeFavoriteProductUC,
        addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC(repo: CartRepositoryImp(networkService: DependencyContainer.shared.networkService))
    )
    
    @AppStorage("selectedTab") private var selectedTab: StoreTab = .store
    @State private var selectedCategoryID: Int?
    @State private var search = ""
    
    // MARK: - AppStorage State
    @AppStorage("isStoreMode") private var isStoreMode: Bool = false
    @AppStorage("savedBranchID") private var savedBranchID: Int = 0
    
    private var currentMode: ShopMode {
        isStoreMode ? .inStore : .online
    }
    
    @State private var showNotificationsView: Bool = false
    @State private var showCartView: Bool = false
    @State private var showBranchSelection: Bool = true
    
    var body: some View {
        ZStack {
            // MARK: - Main Content
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    TopRowNotForHome(
                        title: storeName,
                        showBackButton: true,
                        kindOfTopRow: .withCartAndNotification,
                        onBack: { dismiss() },
                        onCart: { showCartView = true },
                        onNotification: { showNotificationsView = true }
                    )
                    
                    StoreTabBar(selectedTab: $selectedTab)
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        switch selectedTab {
                        case .store:
                            StoreContentView(
                                storeViewModel: storeViewModel,
                                search: $search,
                                currentMode: currentMode,
                                onViewAllCategories: {
                                    showAllCategories = true
                                }
                                ,
                                onScanToBuy: {                  // 👈 Add this
                                            showScannerView = true
                                        }
                            )
                        case .products:
                            ProductCatalogView(
                                storeViewModel: storeViewModel,
                                selectedCategoryID: $selectedCategoryID,
                                onScanToBuy: {                  // 👈 Add this
                                            showScannerView = true
                                        }
                            )
                        case .offers:
                            OffersContentView(
                                storeViewModel: storeViewModel,
                                selectedCategoryID: $selectedCategoryID
                            )
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarBackButtonHidden(true)
            .background(Color(white: 0.98).ignoresSafeArea())
            .navigationDestination(isPresented: $showNotificationsView) {
                HomeView()
            }
            .navigationDestination(isPresented: $showScannerView) {
                ScannerMainView()
            }
            .navigationDestination(isPresented: $showCartView) {
                let branchIdToFetch = savedBranchID == 0 ? 1 : savedBranchID
                
                // 1. Initialize the required repositories
                let cartRepo = CartRepositoryImp(networkService: DependencyContainer.shared.networkService)
                let ordersRepo = OrdersRepositoryImp(networkService: DependencyContainer.shared.networkService) // Added OrdersRepo
                
                // 2. Inject all Use Cases into the ViewModel
                let cartViewModel = CartViewModel(
                    getCartUC: GetCartUC(repo: cartRepo),
                    changeCartItemQuantityUC: ChangeCartItemQuantityUC(repo: cartRepo),
                    removeProductFromCartUC: RemoveProductFromCartUC(repo: cartRepo),
                    verifyPromoCodeUC: VerifyPromoCodeUseCase(networkService: DependencyContainer.shared.networkService),
                    submitOrderUC: SubmitOrderUC(repo: ordersRepo) // <--- Added missing argument
                )
                
                // 3. Pass the newly required storeId parameter
                CartView(
                    viewModel: cartViewModel,
                    branchId: String(branchIdToFetch),
                    storeName: storeName,
                    storeId: String(storeId) // <--- Added missing argument
                )
            }                
            
            
            .navigationDestination(isPresented: $showAllCategories) {
                CategoriesView(
                    storeId: storeId,
                    viewModel: CategoriesViewModel(
                        getHomeCategoriesUC: GetHomeCategoriesUC(repo: StoreRepositoryImp(networkService: DependencyContainer.shared.networkService)),
                        getStoreSubcategoriesUC: GetStoreSubcategoriesUC(repo: StoreRepositoryImp(networkService: DependencyContainer.shared.networkService))
                    )
                )
            }
            
            // MARK: - Branch Popup Overlay
            if showBranchSelection {
                BranchSelectionView(
                    branches: homeViewModel.branches,
                    storeName: storeName,
                    onDisplayProducts: { branch in
                        savedBranchID = branch.id
                        showBranchSelection = false
                    },
                    onDismiss: {
                        showBranchSelection = false
                        dismiss()
                    }
                )
                .zIndex(2)
            }
        }
        .task(id: storeId) {
            if storeViewModel.storeCategories.isEmpty {
                storeViewModel.isLoading = true // 1. Set Initial Loading
                let branchIdToFetch = savedBranchID == 0 ? 1 : savedBranchID
                
                async let fetchBranches: () = homeViewModel.fetchBranches(storeId: storeId)
                async let fetchSliders: () = storeViewModel.fetchStoreSliders(storeId: storeId)
                async let fetchProducts: () = storeViewModel.fetchProducts(storeId: storeId, branchId: branchIdToFetch, categoryId: selectedCategoryID)
                async let fetchCategories: () = storeViewModel.fetchStoreCategories(storeId: storeId)
                async let fetchSubcategories: () = storeViewModel.fetchStoreSubcategories(storeId: storeId)
                
                _ = await (fetchBranches, fetchSliders, fetchProducts, fetchCategories, fetchSubcategories)
                storeViewModel.isLoading = false // 2. Stop Loading
            }
        }
        .onChange(of: selectedCategoryID) { oldValue, newValue in
            let branchIdToFetch = savedBranchID == 0 ? 1 : savedBranchID
            Task {
                storeViewModel.isFetchingProducts = true // 3. Set Filter Loading
                await storeViewModel.fetchProducts(storeId: storeId, branchId: branchIdToFetch, categoryId: newValue)
                storeViewModel.isFetchingProducts = false // 4. Stop Filter Loading
            }
        }
        .toastView(toast: $storeViewModel.toast)
    }
}

// MARK: - Extracted Subviews

struct StoreContentView: View {
    var storeViewModel: StoreViewModel
    @Binding var search: String
    let currentMode: ShopMode
    var onViewAllCategories: () -> Void
    var onScanToBuy: () -> Void
    
    private var isStoreEmpty: Bool {
        storeViewModel.storeSliders.isEmpty && storeViewModel.storeProducts.isEmpty && storeViewModel.storeCategories.isEmpty
    }
    
    var body: some View {
        // Toggle Shimmer layout
        if storeViewModel.isLoading {
            StoreContentSkeleton()
                .shimmering()
        } else if isStoreEmpty {
            EmptyStoreStateView()
        } else {
            VStack(spacing: 0) {
                ShopActionCard(mode: currentMode)
                
                SearchBarButton(text: $search) {
                    print("Searching for: \(search)")
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                
                if !storeViewModel.storeSliders.isEmpty {
                    BannerCollectionView(banners: storeViewModel.storeSliders.map { $0.asHomeBanner })
                        .padding(.horizontal, 18)
                        .padding(.bottom, 24)
                }
                
                PromotionalCarousel()
                    .padding(.bottom, 24)
                
                if !storeViewModel.storeCategories.isEmpty {
                    CategoryGridSection(categories: storeViewModel.storeCategories, onViewAll: onViewAllCategories)
                        .padding(.bottom, 24)
                }
                
                if !storeViewModel.storeProducts.isEmpty {
                    FeaturedProductsSection(storeViewModel: storeViewModel, products: storeViewModel.storeProducts,onScanToBuy: onScanToBuy)
                }
            }
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Product Catalog & Filters

struct ProductCatalogView: View {
    var storeViewModel: StoreViewModel
    @Binding var selectedCategoryID: Int?
    var onScanToBuy: () -> Void
    @AppStorage("savedBranchID") private var savedBranchID: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Reusable Filter Carousel
            FilterCarouselView(
                categories: storeViewModel.storeSubcategories,
                selectedCategoryID: $selectedCategoryID
            )
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Toggle Shimmer Layout
            if storeViewModel.isLoading || storeViewModel.isFetchingProducts {
                ProductGridSkeleton()
                    .shimmering()
            } else if storeViewModel.storeProducts.isEmpty {
                EmptyProductsStateView()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(storeViewModel.storeProducts) { product in
                        NavigationLink(value: product) {
                            HomeProductCard(
                                product: product,
                                isFavorite: product.isFavorite, // Directly reads local property
                                onToggleFavorite: {
                                    Task { await storeViewModel.toggleFavorite(for: product.id) }
                                },
                                onAddToCart: {
                                    let branchId = savedBranchID == 0 ? 1 : savedBranchID
                                                                        Task { await storeViewModel.addToCart(product: product, branchId: branchId) }
                                    
                                },
                                onScanToBuy: onScanToBuy
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
        }
    }
}

// MARK: - Skeleton Loading Views

struct StoreContentSkeleton: View {
    var body: some View {
        VStack(spacing: 0) {
            // Action Card
            Rectangle().fill(.gray.opacity(0.3)).frame(height: 55)
            
            // Search Bar
            Rectangle().fill(.gray.opacity(0.3)).frame(height: 44).clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal, 18).padding(.vertical, 14)
            
            // Banners
            Rectangle().fill(.gray.opacity(0.3)).frame(height: 160).clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal, 18).padding(.bottom, 24)
            
            // Promotional Carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle().fill(.gray.opacity(0.3)).frame(width: 130, height: 148).clipShape(.rect(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 18)
            }
            .padding(.bottom, 24)
            .disabled(true)
            
            // Categories List
            VStack(spacing: 16) {
                HStack {
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 120, height: 24)
                    Spacer()
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 60, height: 20)
                }
                .padding(.horizontal, 18)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle().fill(.gray.opacity(0.3)).frame(height: 168).clipShape(.rect(cornerRadius: 28))
                    }
                }
                .padding(.horizontal, 18)
            }
        }
        .padding(.bottom, 16)
    }
}

struct ProductGridSkeleton: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(0..<6, id: \.self) { _ in
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .clipShape(.rect(cornerRadius: 16))
                    .frame(height: 220)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }
}


// MARK: - Additional States & Carousels

struct EmptyStoreStateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("stillUpdated")
                .resizable()
                .scaledToFit()
                .frame(width: 153, height: 171)
                .padding(.top, 135)
        }
    }
}

struct PromotionalCarousel: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    
                    Color.gray.opacity(0.2)
                        .frame(width: 130, height: 148)
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 18)
        }
    }
}

struct CategoryGridSection: View {
    let categories: [StoreCategory]
    var onViewAll: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Categories", actionTitle: "View All", action: onViewAll)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(categories) { category in
                    NavigationLink(value: category.id) {
                        CategoryCardView(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
    }
}

struct CategoryCardView: View {
    let category: StoreCategory
    
    private let gradientColors: [Color] = [
        .clear,
        Color(red: 0.05, green: 0.35, blue: 0.25).opacity(0.85) // Dark teal
    ]
    
    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 168)
            .background {
                KFImage(URL(string: category.image))
                    .placeholder {
                        ZStack {
                            Color.gray.opacity(0.1)
                            Image("loadingAjjil")
                        }
                    }
                    .resizable()
                    .scaledToFill()
            }
            .overlay(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    
                    Text(category.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 16)
                }
            }
            .clipShape(.rect(cornerRadius: 28))
            .contentShape(.rect(cornerRadius: 28))
    }
}

struct FeaturedProductsSection: View {
    var storeViewModel: StoreViewModel
    let products: [HomeFeaturedProductDataEntity]
    var onScanToBuy: () -> Void
    @AppStorage("selectedTab") private var selectedTab: StoreTab = .store
    @AppStorage("savedBranchID") private var savedBranchID: Int = 0
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Featured Products", actionTitle: "View All") {selectedTab = .products}
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(products) { product in
                    NavigationLink(value: product) {
                        HomeProductCard(
                            product: product,
                            isFavorite: product.isFavorite, // Directly reads local property
                            onToggleFavorite: {
                                Task { await storeViewModel.toggleFavorite(for: product.id) }
                            },
                            onAddToCart: {
                                let branchId = savedBranchID == 0 ? 1 : savedBranchID
                                                                Task { await storeViewModel.addToCart(product: product, branchId: branchId) }
                                
                            },
                            onScanToBuy: onScanToBuy
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
    }
}

// MARK: - Reusable Filter Carousel Components

struct FilterCarouselView: View {
    let categories: [StoreCategory]
    @Binding var selectedCategoryID: Int?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                // Fixed "All" Button
                FilterChipView(
                    title: "All",
                    isSelected: selectedCategoryID == nil,
                    fixedWidth: 81
                ) {
                    withAnimation(.snappy) {
                        selectedCategoryID = nil
                    }
                }
                
                // Dynamic Categories
                ForEach(categories) { category in
                    FilterChipView(
                        title: category.name,
                        isSelected: selectedCategoryID == category.id,
                        fixedWidth: nil
                    ) {
                        withAnimation(.snappy) {
                            selectedCategoryID = category.id
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
        }
        .frame(height: 44)
    }
}

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    var fixedWidth: CGFloat? = nil
    let action: () -> Void
    
    private let activeBg = Color(red: 0.95, green: 0.51, blue: 0.20)
    private let inactiveBg = Color(red: 0.93, green: 0.95, blue: 0.96)
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? .white : .gray)
                .frame(width: fixedWidth)
                .padding(.horizontal, fixedWidth == nil ? 19 : 0)
                .frame(height: 44)
                .background(isSelected ? activeBg : inactiveBg)
                .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Miscellaneous Components

struct SectionHeader: View {
    let title: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.bold())
            Spacer()
            Button(actionTitle, action: action)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.green)
                .underline()
        }
        .padding(.horizontal, 18)
    }
}

struct ShopActionCard: View {
    let mode: ShopMode
    
    private let tealGreen = Color(red: 0.25, green: 0.62, blue: 0.54)
    private let aquaBackground = Color(red: 0.88, green: 0.97, blue: 0.95)
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(tealGreen)
            
            if mode == .inStore {
                Text("Shop in Store")
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .fontWeight(.semibold)
                    .foregroundStyle(tealGreen)
                
                Spacer()
                
                Image("homeIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .foregroundStyle(tealGreen)
                
            } else {
                HStack(spacing: 4) {
                    Text("Shop Online")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .fontWeight(.semibold)
                        .foregroundStyle(tealGreen)
                    
                    Text("Delivery To Home")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.3))
                }
                
                Spacer()
                
                Image("homeCare")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
                    .foregroundStyle(tealGreen)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(aquaBackground)
    }
}

// MARK: - Models

enum StoreTab: String, Hashable, CaseIterable {
    case store = "Store"
    case products = "Products"
    case offers = "Offers"
}

enum ShopMode {
    case inStore
    case online
}

// MARK: - StoreTabBar Component

struct StoreTabBar: View {
    @Binding var selectedTab: StoreTab
    
    private let tealGreen = Color(red: 0.25, green: 0.62, blue: 0.54)
    private let vibrantOrange = Color(red: 0.95, green: 0.55, blue: 0.24)
    private let topBgColor = Color(red: 0.94, green: 0.95, blue: 0.96)
    
    var body: some View {
        HStack(spacing: 35) {
            ForEach(StoreTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .bold : .semibold)
                            .foregroundStyle(selectedTab == tab ? tealGreen : .secondary)
                            .padding(.bottom, 8)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? vibrantOrange : Color.clear)
                            .frame(height: 3)
                            .clipShape(.rect(cornerRadius: 1.5))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(topBgColor)
    }
}

struct OffersContentView: View {
    var storeViewModel: StoreViewModel
    @Binding var selectedCategoryID: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            FilterCarouselView(
                categories: storeViewModel.storeSubcategories,
                selectedCategoryID: $selectedCategoryID
            )
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            EmptyOffersStateView()
        }
    }
}

struct EmptyOffersStateView: View {
    var body: some View {
        VStack(spacing: 0) {
            
            Image("noOffersYet")
                .resizable()
                .scaledToFit()
                .frame(width: 153, height: 171)
                .padding(.top, 200)
            
            
        }
        .frame(maxWidth: .infinity)
    }
}

struct EmptyProductsStateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("NoProductsYet")
                .resizable()
                .scaledToFit()
                .frame(width: 153, height: 171)
                .padding(.top, 200)
        }
        .frame(maxWidth: .infinity)
    }
}
