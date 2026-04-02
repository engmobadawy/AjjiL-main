import SwiftUI
import Kingfisher
struct StoreView: View {
    let storeName: String
    let storeId: Int
    
    @Environment(\.dismiss) private var dismiss
    
    // Global HomeViewModel for shared state like favorites and branches
    var homeViewModel = DependencyContainer.HomeDependency.shared.homeVM
    
    // Local StoreViewModel managing the store's specific state
    @State private var storeViewModel = StoreViewModel(
        getStoreSlidersUC: GetStoreSlidersUC(repo: StoreRepositoryImp(networkService: NetworkService())),
        getFeaturedProductsUCForStore: GetFeaturedProductsUCForStore(repo: StoreRepositoryImp(networkService: NetworkService())),
        getHomeCategoriesUC: GetHomeCategoriesUC(repo: StoreRepositoryImp(networkService: NetworkService()))
    )
    
    @State private var selectedTab: StoreTab = .store
    @State private var selectedCategoryID: UUID?
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
    
    let categories = [
        Category(name: "All"),
        Category(name: "Sneakers"),
        Category(name: "Apparel"),
        Category(name: "Accessories")
    ]
    
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
                                viewModel: homeViewModel,
                                storeSliders: storeViewModel.storeSliders,
                                storeProducts: storeViewModel.storeProducts,
                                storeCategories: storeViewModel.storeCategories,
                                search: $search,
                                currentMode: currentMode
                            )
                        case .products, .offers:
                            ProductCatalogView(
                                viewModel: homeViewModel,
                                storeProducts: storeViewModel.storeProducts,
                                categories: categories,
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
            .navigationDestination(isPresented: $showCartView) {
                CartView() // Make sure this view exists in your project
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
            // Determine branch ID (fallback to 1 if savedBranchID is 0 to avoid errors)
            let branchIdToFetch = savedBranchID == 0 ? 1 : savedBranchID
            
            // Execute tasks concurrently for better performance
            async let fetchBranches: () = homeViewModel.fetchBranches(storeId: storeId)
            async let fetchSliders: () = storeViewModel.fetchStoreSliders(storeId: storeId)
            async let fetchProducts: () = storeViewModel.fetchStoreProducts(storeId: storeId, branchId: branchIdToFetch)
            async let fetchCategories: () = storeViewModel.fetchStoreCategories(storeId: storeId)
            
            _ = await (fetchBranches, fetchSliders, fetchProducts, fetchCategories)
        }
    }
}

// MARK: - Extracted Subviews

struct StoreContentView: View {
    var viewModel: HomeViewModel
    let storeSliders: [StoreSlider]
    let storeProducts: [HomeFeaturedProductDataEntity]
    let storeCategories: [StoreCategory]
    @Binding var search: String
    let currentMode: ShopMode
    
    private var isStoreEmpty: Bool {
        storeSliders.isEmpty && storeProducts.isEmpty && storeCategories.isEmpty
    }
    
    var body: some View {
        if isStoreEmpty {
            EmptyStoreStateView()
        } else {
            VStack(spacing: 0) {
                ShopActionCard(mode: currentMode)
                
                SearchBarButton(text: $search) {
                    print("Searching for: \(search)")
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                
                if !storeSliders.isEmpty {
                    BannerCollectionView(banners: storeSliders.map { $0.asHomeBanner })
                        .padding(.horizontal, 18)
                        .padding(.bottom, 24)
                }
                
                PromotionalCarousel()
                    .padding(.bottom, 24)
                
                if !storeCategories.isEmpty {
                    CategoryGridSection(categories: storeCategories)
                        .padding(.bottom, 24)
                }
                
                if !storeProducts.isEmpty {
                    FeaturedProductsSection(viewModel: viewModel, products: storeProducts)
                }
            }
            .padding(.bottom, 16)
        }
    }
}

struct EmptyStoreStateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("stillUpdated") // Ensure this image is in your Assets
                .resizable()
                .scaledToFit()
                .frame(width: 153, height: 171)
                .padding(.top, 135)
            
            Text("Store is currently being updated.")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.top, 16)
        }
    }
}

struct PromotionalCarousel: View {
    // Assuming mockPromoImages is defined elsewhere in your project
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // If you don't have mockPromoImages, replace with actual data
                ForEach(0..<3, id: \.self) { _ in
                    Color.gray.opacity(0.2) // Placeholder
                        .frame(width: 130, height: 148)
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 18)
        }
    }
}

// MARK: - Updated Category Views

struct CategoryGridSection: View {
    let categories: [StoreCategory]
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Categories", actionTitle: "View All") { }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(categories) { category in
                    // Assuming you will route this to a specific category view later
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
        // 1. Establish the strict layout footprint FIRST
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 168)
            
            // 2. Put the image in the background so its size is ignored by the grid layout
            .background {
                KFImage(URL(string: category.image))
                    .placeholder {
                        ZStack {
                            Color.gray.opacity(0.1)
                            ProgressView()
                        }
                    }
                    .resizable()
                    .scaledToFill()
            }
            
            // 3. Layer the gradient and text over the fixed footprint
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
            
            // 4. Clip the final structured view
            .clipShape(.rect(cornerRadius: 28))
            .contentShape(.rect(cornerRadius: 28))
    }
}

struct FeaturedProductsSection: View {
    var viewModel: HomeViewModel
    let products: [HomeFeaturedProductDataEntity]
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Featured Products", actionTitle: "View All") { }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(products) { product in
                    NavigationLink(value: product) {
                        HomeProductCard(
                            product: product,
                            isFavorite: viewModel.favoriteProductIDs.contains(product.id),
                            onToggleFavorite: {
                                Task { await viewModel.toggleFavorite(for: product.id) }
                            },
                            onAddToCart: { },
                            onScanToBuy: { }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
    }
}

struct ProductCatalogView: View {
    var viewModel: HomeViewModel
    let storeProducts: [HomeFeaturedProductDataEntity]
    let categories: [Category] // This might be your local Category model, adjust if needed
    @Binding var selectedCategoryID: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(storeProducts) { product in
                    NavigationLink(value: product) {
                        HomeProductCard(
                            product: product,
                            isFavorite: viewModel.favoriteProductIDs.contains(product.id),
                            onToggleFavorite: {
                                Task { await viewModel.toggleFavorite(for: product.id) }
                            },
                            onAddToCart: { },
                            onScanToBuy: { }
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
                    .font(.custom("Poppins-SemiBold", size: 14)) // Ensure font is added to Info.plist
                    .fontWeight(.semibold)
                    .foregroundStyle(tealGreen)
                
                Spacer()
                
                Image("homeIcon") // Ensure this is in Assets
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
                
                Image("homeCare") // Ensure this is in Assets
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
