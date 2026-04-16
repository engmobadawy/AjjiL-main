import SwiftUI

struct HomeView: View {
    @Environment(TabBarVisibility.self) private var tabVisibility
    
    @AppStorage("isStoreMode") private var isStoreMode: Bool = false
    // MARK: - State
    @State private var viewModel = DependencyContainer.HomeDependency.shared.homeVM
    @State private var searchText: String = ""
   
    @State private var showFeaturedProductsView: Bool = false
    @State private var showAllStoresView: Bool = false
    @State private var showScannerView: Bool = false
    @State private var showNotificationsView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
            HomeTopRow()

                
                // 2. Search & Shop Header (Spacing: Top 7, Bottom 12)
                searchAndToggleHeader
                
                // 3. Main Scrollable Content
                ScrollView {
                    VStack(spacing: 18) {
                        BannerCollectionView(banners: viewModel.sliderCards)
                        
                        storesSection
                        
                        featuredProductsHeader
                        
                        featuredProductsGrid
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 18)
                }
                .scrollIndicators(.hidden)
            }
           
            .background(.white)
            .navigationBarBackButtonHidden(true)
            // Locate this block in HomeView.swift and replace it
                        .navigationDestination(for: HomeFeaturedProductDataEntity.self) { product in
                            ProductDetailsView(
                                viewModel: ProductDetailsViewModel(
                                    branchProductId: product.id,
                                    getProductDetailsUC: DependencyContainer.FavoritesDependency.shared.getProductDetailsUC,
                                    addFavoriteProductUC: DependencyContainer.FavoritesDependency.shared.addFavoriteProductUC,
                                    removeFavoriteProductUC: DependencyContainer.FavoritesDependency.shared.removeFavoriteProductUC
                                )
                            )
                        }
            // Type-safe navigation mapping the store entity to the StoreView
            .navigationDestination(for: HomeStoresDataEntity.self) { store in
                StoreView(storeName: store.name, storeId: store.id,)
            }
            .navigationDestination(isPresented: $showAllStoresView) {
                AllStoresView()
            }

            .navigationDestination(isPresented: $showNotificationsView) {
                HomeView()
            }
            .navigationDestination(isPresented: $showScannerView) {
                ScannerMainView()
            }
          

            // Type-safe navigation mapping the store entity to the StoreView
            .navigationDestination(for: HomeStoresDataEntity.self) { store in
                // Pass both the ID and the name
                StoreView(storeName: store.name , storeId: store.id )
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: - Extracted Header
    
    private var searchAndToggleHeader: some View {
        VStack(spacing: 7) {
            ShopThroughBanner(isStoreMode: $isStoreMode)
            
            SearchBarButton(text: $searchText) {
                print("Searching for: \(searchText)")
            }
            .padding(.horizontal, 18)
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
                        isFavorite: viewModel.favoriteProductIDs.contains(product.id),
                        onToggleFavorite: {
                            Task { await viewModel.toggleFavorite(for: product.id) }
                        },
                        onAddToCart: { print("Added \(product.name) to cart") },
                        onScanToBuy: { print("Scanning \(product.name)")
                            showScannerView = true
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
                        // Pass the specific store entity down the navigation stack
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
            Text("Stores")
                .font(.title3.bold())
            Spacer()
            Button("View All") { showAllStoresView = true }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.green)
                .underline()
        }
    }
    
    private var featuredProductsHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Featured Products")
                .font(.title3.bold())
            Spacer()
            Button("View All") { showFeaturedProductsView = true}
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.green)
                .underline()
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
                Text("Shop through")
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("Store")
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
