import SwiftUI

struct StoreView: View {
    let storeName: String
    let storeId: Int
    
    @Environment(\.dismiss) private var dismiss
    
    var viewModel = DependencyContainer.HomeDependency.shared.homeVM
    
    @State private var selectedTab: StoreTab = .store
    @State private var selectedCategoryID: UUID?
    @State private var search = ""
    
    // MARK: - AppStorage State
    @AppStorage("isStoreMode") private var isStoreMode: Bool = false
    
    private var currentMode: ShopMode {
        isStoreMode ? .inStore : .online
    }
    
    @State private var showNotificationsView: Bool = false
    @State private var showCartView: Bool = false
    
    // MARK: - Branch Selection State
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
                        title: storeName, // Displays the passed property
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
                                viewModel: viewModel,
                                search: $search,
                                currentMode: currentMode
                            )
                        case .products, .offers:
                            ProductCatalogView(
                                viewModel: viewModel,
                                categories: categories,
                                selectedCategoryID: $selectedCategoryID
                            )
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .background(Color(white: 0.98).ignoresSafeArea())
            .navigationDestination(isPresented: $showNotificationsView) {
                HomeView()
            }
            .navigationDestination(isPresented: $showCartView) {
                CartView()
            }
            
            // MARK: - Branch Popup Overlay
            if showBranchSelection {
                            BranchSelectionView(
                                branches: viewModel.branches, // NEW: Pass the live branches array here
                                onDisplayProducts: { branch in
                                    // TODO: Handle setting active branch and fetching branch products
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
                    // NEW: Automatically cancel and restart async work if storeId changes
                    .task(id: storeId) {
                        await viewModel.fetchBranches(storeId: storeId)
                    }
    }
}

// MARK: - Extracted Subviews

struct StoreContentView: View {
    var viewModel: HomeViewModel
    @Binding var search: String
    let currentMode: ShopMode
    
    private var isStoreEmpty: Bool {
        viewModel.sliderCards.isEmpty && viewModel.featuredProducts.isEmpty
    }
    
    var body: some View {
        if isStoreEmpty {
            EmptyStoreStateView()
        } else {
            VStack(spacing: 0) {
                ShopActionCard(mode: currentMode)
                
                SearchBarButton(text: $search)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                
                if !viewModel.sliderCards.isEmpty {
                    BannerCollectionView(banners: viewModel.sliderCards)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 24)
                }
                
                PromotionalCarousel()
                    .padding(.bottom, 24)
                
                CategoryGridSection()
                    .padding(.bottom, 24)
                
                if !viewModel.featuredProducts.isEmpty {
                    FeaturedProductsSection(viewModel: viewModel)
                }
            }
            .padding(.bottom, 16)
        }
    }
}

struct EmptyStoreStateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("stillUpdated")
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
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(mockPromoImages) { promo in
                    Image(promo.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 148)
                        .clipShape(.rect(cornerRadius: 12)) // Modern API usage
                }
            }
            .padding(.horizontal, 18)
        }
    }
}

struct CategoryGridSection: View {
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Categories", actionTitle: "View All") { }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(mockCategoryImages) { category in
                    NavigationLink(value: category.id) {
                        Image(category.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 168)
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
    }
}

struct FeaturedProductsSection: View {
    var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Featured Products", actionTitle: "View All") { }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.featuredProducts) { product in
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
    let categories: [Category]
    @Binding var selectedCategoryID: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
//            CategoryFilterRow(
//                categories: categories,
//                selectedCategoryID: $selectedCategoryID
//            )
//            .padding(.vertical, 14)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.featuredProducts) { product in
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

// MARK: - Subviews

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
