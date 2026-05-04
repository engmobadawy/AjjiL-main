import SwiftUI
import Shimmer
import Observation

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var historyManager = SearchHistoryManager()
    @State private var viewModel: SearchViewModel
    @AppStorage("savedBranchID") private var savedBranchID: Int = 0
    
    // ✅ Navigation States
    @State private var scannerDestination: ScannerDestination?
    @State private var cartDestination: CartRoutingDestination?
    
    @State private var showGuestLoginSheet: Bool = false
    
    init(viewModel: SearchViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    private enum ViewState {
        case history, loading, empty, results
    }
    
    private var currentState: ViewState {
        if viewModel.isLoading { return .loading }
        if viewModel.hasSearched && viewModel.products.isEmpty { return .empty }
        if viewModel.hasSearched && !viewModel.products.isEmpty { return .results }
        return .history
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "Search".newlocalized,
                showBackButton: true,
                kindOfTopRow: .justNotification,
                onBack: { dismiss() }
            )
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    SearchBarButton(
                        text: $searchText,
                        // 🛠️ FIX: Added .newlocalized
                        placeholder: "Search beverages or foods".newlocalized,
                        onSubmit: { performSearch(searchText) }
                    )
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                
                ScrollView {
                    switch currentState {
                    case .history:
                        SearchHistoryList(historyManager: historyManager) { keyword in
                            searchText = keyword
                            performSearch(keyword)
                        }
                    case .loading:
                        FavoritesGridSkeleton().shimmering().padding(.horizontal, 18)
                    case .empty:
                        SearchEmptyState { dismiss() }.padding(.top, 100)
                    case .results:
                        SearchResultsGrid(
                            products: viewModel.products,
                            savedBranchID: savedBranchID,
                            onToggleFavorite: { product in
                                if Constants.isGuestMode { showGuestLoginSheet = true } else {
                                    Task { await viewModel.toggleFavorite(for: product) }
                                }
                            },
                            onAddToCart: { product, branchId in
                                if Constants.isGuestMode { showGuestLoginSheet = true } else {
                                    Task { await viewModel.addToCart(product: product, branchId: branchId) }
                                }
                            },
                            onScanToBuy: { destination in
                                if Constants.isGuestMode { showGuestLoginSheet = true } else {
                                    self.scannerDestination = destination
                                }
                            }
                        )
                        .padding(.top, 16)
                        .padding(.horizontal, 18)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(.white)
        .sheet(isPresented: $showGuestLoginSheet) {
            GuestLoginSheetView()
                .presentationDetents([.fraction(0.5), .medium])
                .presentationDragIndicator(.visible)
                .background(.white)
        }
        .toastView(toast: $viewModel.toast)
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty { viewModel.clearSearch() }
        }
        
        // MARK: - Scanner Navigation
        .navigationDestination(item: $scannerDestination) { destination in
            ScannerMainView(
                product: destination.product,
                onAddToCart: { scannedProduct in
                    let branchId = savedBranchID == 0 ? 1 : savedBranchID
                    await viewModel.addToCart(product: scannedProduct, branchId: branchId)
                },
                onGoToCart: {
                    // ✅ Navigate to Cart (safely unwrap properties)
                    if let sId = destination.storeId,
                       let sName = destination.storeName,
                       let bId = destination.branchId {
                        
                        savedBranchID = bId // Pre-select the branch globally
                        
                        // Delay execution to let the scanner dismiss smoothly
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            cartDestination = CartRoutingDestination(
                                storeId: sId,
                                storeName: sName,
                                branchId: bId
                            )
                        }
                    } else {
                        dismiss()
                    }
                },
                onGoToStore: {
                    if let bId = destination.branchId {
                        savedBranchID = bId
                    }
                    // ✅ Calling dismiss() here dismisses the SearchView
                    // and drops the user right back to the StoreView!
                    dismiss()
                }
            )
        }
        
        // MARK: - Cart Navigation
        .navigationDestination(item: $cartDestination) { destination in
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
    
    private func performSearch(_ query: String) {
        guard !query.isEmpty else { return }
        historyManager.addSearch(query)
        Task { await viewModel.search(query: query) }
    }
}

// MARK: - Search Results Grid

struct SearchResultsGrid: View {
    let products: [HomeFeaturedProductDataEntity]
    let savedBranchID: Int
    let onToggleFavorite: (HomeFeaturedProductDataEntity) -> Void
    let onAddToCart: (HomeFeaturedProductDataEntity, Int) -> Void
    let onScanToBuy: (ScannerDestination) -> Void
    
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(products) { product in
                NavigationLink(value: product) {
                    HomeProductCard(
                        product: product,
                        isFavorite: FavoritesManager.shared.isFavorite(product.id),
                        onToggleFavorite: { onToggleFavorite(product) },
                        onAddToCart: {
                            let branchId = savedBranchID == 0 ? 1 : savedBranchID
                            onAddToCart(product, branchId)
                        },
                        onScanToBuy: {
                            onScanToBuy(ScannerDestination(product: product, storeId: product.storeId,
                                                           storeName: product.brand, branchId: product.branchId))
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Search History Row

struct SearchHistoryRow: View {
    let keyword: String
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(keyword)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(12)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .contentShape(.rect)
        .onTapGesture(perform: onSelect)
    }
}

// MARK: - SearchViewModel

@Observable
@MainActor
class SearchViewModel {
    var products: [HomeFeaturedProductDataEntity] = []
    var isLoading: Bool = false
    var hasSearched: Bool = false
    var toast: FancyToast?
    
    private let storeId: Int
    private let branchId: Int
    
    private let getStoreProductsUC: GetStoreProductsUC
    private let addFavoriteProductUC: AddFavoriteProductUC
    private let removeFavoriteProductUC: RemoveFavoriteProductUC
    private let addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
    
    init(
        storeId: Int,
        branchId: Int,
        getStoreProductsUC: GetStoreProductsUC,
        addFavoriteProductUC: AddFavoriteProductUC,
        removeFavoriteProductUC: RemoveFavoriteProductUC,
        addProductByBarcodeToCartUC: AddProductByBarcodeToCartUC
    ) {
        self.storeId = storeId
        self.branchId = branchId
        self.getStoreProductsUC = getStoreProductsUC
        self.addFavoriteProductUC = addFavoriteProductUC
        self.removeFavoriteProductUC = removeFavoriteProductUC
        self.addProductByBarcodeToCartUC = addProductByBarcodeToCartUC
    }
    
    func search(query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { clearSearch(); return }
        
        isLoading = true
        hasSearched = true
        products = []
        
        do {
            let response = try await getStoreProductsUC.execute(
                storeId: storeId,
                branchId: branchId,
                search: trimmedQuery
            )
            self.products = response.data?.map { $0.asFeaturedProductEntity() } ?? []
            for product in self.products {
                FavoritesManager.shared.setFavorite(product.id, isFavorite: product.isFavorite)
            }
        } catch {
            print("Search failed: \(error)")
            self.products = []
        }
        
        isLoading = false
    }
    
    func clearSearch() {
        products = []
        hasSearched = false
        isLoading = false
    }
    
    func toggleFavorite(for product: HomeFeaturedProductDataEntity) async {
        guard !Constants.isGuestMode else { return }
        
        let wasFavorite = FavoritesManager.shared.isFavorite(product.id)
        FavoritesManager.shared.setFavorite(product.id, isFavorite: !wasFavorite)
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].isFavorite = !wasFavorite
        }
        do {
            let response: ToggleFavoriteModel
            if wasFavorite {
                response = try await removeFavoriteProductUC.execute(branchProductId: String(product.id))
            } else {
                response = try await addFavoriteProductUC.execute(branchProductId: String(product.id))
            }
            if response.status == false {
                revertFavoriteState(for: product, wasFavorite: wasFavorite)
                toast = FancyToast(type: .error, title: "Error".newlocalized, message: response.message ?? "")
            }
        } catch {
            revertFavoriteState(for: product, wasFavorite: wasFavorite)
            toast = FancyToast(type: .error, title: "Error".newlocalized, message: error.localizedDescription)
        }
    }
    
    private func revertFavoriteState(for product: HomeFeaturedProductDataEntity, wasFavorite: Bool) {
        FavoritesManager.shared.setFavorite(product.id, isFavorite: wasFavorite)
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].isFavorite = wasFavorite
        }
    }
    
    func addToCart(product: HomeFeaturedProductDataEntity, branchId: Int) async {
        guard !Constants.isGuestMode else { return }
        
        let branchIdString = String(branchId)
        let barcodeString = product.barcode.isEmpty ? String(product.id) : product.barcode
        let defaultQuantity = "1"
        
        _ = try? await addProductByBarcodeToCartUC.execute(
            branchId: branchIdString,
            barcode: barcodeString,
            quantity: defaultQuantity
        )
        
        toast = FancyToast(
            type: .success,
            title: "Success".newlocalized,
            message: "added to the cart successfully".newlocalized
        )
    }
}

// MARK: - Search Empty State

struct SearchEmptyState: View {
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Image("NoResult")
                .resizable()
                .scaledToFit()
                .frame(width: 230, height: 230)
            
            Text("NO Result For Now".newlocalized)
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
            
            GreenButton(title: "Back To Store".newlocalized, action: action)
                .padding(.horizontal, 48)
        }
    }
}

// MARK: - History List View

struct SearchHistoryList: View {
    var historyManager: SearchHistoryManager
    let onSelect: (String) -> Void
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(historyManager.history, id: \.self) { keyword in
                SearchHistoryRow(
                    keyword: keyword,
                    onSelect: { onSelect(keyword) },
                    onDelete: {
                        withAnimation(.snappy) {
                            historyManager.removeSearch(keyword)
                        }
                    }
                )
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Search History Manager

@Observable
@MainActor
class SearchHistoryManager {
    var history: [String] = []
    private let defaultsKey = "savedSearchHistory"
    
    init() { loadHistory() }
    
    private func loadHistory() {
        if let saved = UserDefaults.standard.stringArray(forKey: defaultsKey) {
            history = saved
        }
    }
    
    func addSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        history.removeAll { $0 == trimmed }
        history.insert(trimmed, at: 0)
        if history.count > 20 { history.removeLast() }
        saveHistory()
    }
    
    func removeSearch(_ query: String) {
        history.removeAll { $0 == query }
        saveHistory()
    }
    
    private func saveHistory() {
        UserDefaults.standard.set(history, forKey: defaultsKey)
    }
}
