import SwiftUI
import Kingfisher
import Shimmer



struct CartRoutingDestination: Hashable {
    let storeId: Int
    let storeName: String
    let branchId: Int
}

struct ProductDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Navigation states
    @State private var scannerDestination: ScannerDestination?
    @State private var storeDestination: StoreRoutingDestination?
    @State private var cartDestination: CartRoutingDestination? // 🛠️ NEW: Added Cart routing state
    @State private var showGuestLoginSheet: Bool = false
    
    @AppStorage("isStoreMode") private var isStoreMode: Bool = false
    @AppStorage("savedBranchID") private var savedBranchID: Int = 0
    
    let viewModel: ProductDetailsViewModel

    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "Details".newlocalized,
                showBackButton: true,
                kindOfTopRow: .justNotification,
                onBack: { dismiss() }
            )
            
            if viewModel.isLoading && viewModel.productDetail == nil {
                ScrollView {
                    ProductDetailsSkeletonView()
                        .shimmering()
                }
                .scrollIndicators(.hidden)
                .disabled(true)
                
            } else if let product = viewModel.productDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ProductDetailsImageHeader(
                            imageURL: product.images,
                            discount: product.offerDiscount,
                            isFavorite: FavoritesManager.shared.isFavorite(product.productBranchId),
                            onToggleFavorite: {
                                if Constants.isGuestMode {
                                    showGuestLoginSheet = true
                                } else {
                                    Task { await viewModel.toggleFavorite() }
                                }
                            }
                        )
                        
                        ProductDetailsInfoSection(product: product)
                        
                        ProductDetailsDescriptionSection(
                            descriptionText: product.description
                        )
                        
                        ProductDetailsBarcodeSection(barcode: product.barcode)
                        
                        Button {
                            if Constants.isGuestMode {
                                showGuestLoginSheet = true
                            } else if isStoreMode {
                                let homeProduct = product.asHomeProduct
                                scannerDestination = ScannerDestination(
                                    product: homeProduct,
                                    storeId: homeProduct.storeId,
                                    storeName: homeProduct.brand, // Brand represents the storeName in your model
                                    branchId: homeProduct.branchId
                                )
                            } else {
                                let branchId = savedBranchID == 0 ? 1 : savedBranchID
                                Task {
                                    await viewModel.addToCart(branchId: branchId)
                                }
                            }
                        } label: {
                            HStack(spacing: !isStoreMode ? 8 : 0) {
                                Image(systemName: "cart.badge.plus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(width: !isStoreMode ? nil : 0)
                                    .opacity(!isStoreMode ? 1 : 0)
                                    .clipped()
                                
                                Text(isStoreMode ? "Scan to buy".newlocalized : "Add to cart".newlocalized)
                                    .font(.custom("Poppins-SemiBold", size: 16))
                                    .contentTransition(.opacity)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .foregroundStyle(isStoreMode ? Color(red: 0, green: 0.59, blue: 0.51) : .white)
                            .background(
                                isStoreMode ? Color(red: 0.79, green: 0.93, blue: 0.85) : Color(red: 0, green: 0.59, blue: 0.51),
                                in: .rect(cornerRadius: 12)
                            )
                        }
                        .buttonStyle(.borderless)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isStoreMode)
                        .padding(.horizontal, 18)
                        
                    }
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
        }
        
        // MARK: - Navigation Routing
        
        // 1. Scanner Route
        .navigationDestination(item: $scannerDestination) { destination in
            ScannerMainView(
                product: destination.product,
                onAddToCart: { _ in
                    let branchId = savedBranchID == 0 ? 1 : savedBranchID
                    await viewModel.addToCart(branchId: branchId)
                },
                onGoToCart: {
                    // 🛠️ FIX: Same logic as onGoToStore, but triggers the cart destination instead
                    if let sId = destination.storeId,
                       let sName = destination.storeName,
                       let bId = destination.branchId {
                        
                        savedBranchID = bId // Pre-select the branch globally
                        
                        // Delay execution to let the scanner completely dismiss and prevent the empty view crash
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
                    if let sId = destination.storeId,
                       let sName = destination.storeName,
                       let bId = destination.branchId {
                        
                        savedBranchID = bId
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            storeDestination = StoreRoutingDestination(
                                storeId: sId,
                                storeName: sName,
                                skipBranchSelection: true
                            )
                        }
                    } else {
                        dismiss()
                    }
                }
            )
        }
        
        // 2. Store Route
        .navigationDestination(item: $storeDestination) { destination in
            StoreView(
                storeName: destination.storeName,
                storeId: destination.storeId,
                showBranchSelection: !destination.skipBranchSelection
            )
        }
        
        // 3. Cart Route (Triggered from Scanner's "Go To Cart")
        .navigationDestination(item: $cartDestination) { destination in
            // 🛠️ FIX: Initialize the CartViewModel and inject it exactly as StoreView does
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
        .navigationBarBackButtonHidden(true)
        .background(.white)
        .task {
            if viewModel.productDetail == nil {
                await viewModel.fetchProductDetails()
            }
        }
        .toastView(toast: Bindable(viewModel).toast)
    }
}


// MARK: - Skeleton View
struct ProductDetailsSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 16) {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 250)
                
                HStack {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 56, height: 56)
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(.bottom, 8)
            }
            .frame(height: 321)

            VStack(alignment: .leading, spacing: 10) {
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 80, height: 16).clipShape(.rect(cornerRadius: 4))
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 220, height: 28).clipShape(.rect(cornerRadius: 6))
                
                HStack(spacing: 10) {
                    Circle().fill(.gray.opacity(0.3)).frame(width: 28, height: 28)
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 100, height: 16).clipShape(.rect(cornerRadius: 4))
                }
                .padding(.bottom, 6)
                
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 120, height: 32).clipShape(.rect(cornerRadius: 6))
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 60, height: 20).clipShape(.rect(cornerRadius: 4))
                }
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 14) {
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 120, height: 20).clipShape(.rect(cornerRadius: 4))
                
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle().fill(.gray.opacity(0.3)).frame(height: 14).clipShape(.rect(cornerRadius: 4))
                    Rectangle().fill(.gray.opacity(0.3)).frame(height: 14).clipShape(.rect(cornerRadius: 4))
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 250, height: 14).clipShape(.rect(cornerRadius: 4))
                }
            }
            .padding(.horizontal, 20)
            
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 117)
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 55)
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal, 18)
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Subviews
private struct ProductDetailsImageHeader: View {
    let imageURL: String
    let discount: String
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .top) {
                KFImage(URL(string: imageURL))
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                HStack(alignment: .top) {
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Color(red: 0.9, green: 0.3, blue: 0.3))
                            .padding(20)
                    }
                    
                    Spacer()
                    
                    if !discount.isEmpty && discount != "0" {
                        ProductDetailRibbon(text: "\(discount)% OFF")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
            
            HStack {
                ThumbnailView(imageURL: imageURL, isSelected: true)
                    .padding(.leading, 8)
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .frame(height: 321)
    }
}

private struct ThumbnailView: View {
    let imageURL: String
    let isSelected: Bool
    
    var body: some View {
        KFImage(URL(string: imageURL))
            .placeholder { Color.gray.opacity(0.1) }
            .resizable()
            .scaledToFit()
            .frame(width: 56, height: 56)
            .padding(6)
            .background(.white)
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(red: 0.1, green: 0.6, blue: 0.5) : .gray.opacity(0.2),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
    }
}

private struct ProductDetailsInfoSection: View {
    let product: ProductDetailResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(product.categoryName)
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundStyle(Color(red: 0.1, green: 0.7, blue: 0.5))
            
            Text(product.name)
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundStyle(.black)
            
            HStack(spacing: 10) {
                KFImage(URL(string: product.storeImage))
                    .placeholder { Circle().fill(.gray.opacity(0.1)) }
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .clipShape(.circle)
                
                Text(product.storeName)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundStyle(.gray)
            }
            .padding(.bottom, 6)
            
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                CurrencyAmount(
                    amount: product.finalPrice,
                    amountFont: .custom("Poppins-Bold", size: 28),
                    amountColor: .orange,
                    currencyAssetName: "OrangeVector",
                    isStrikethrough: false
                )
                
                if product.price > product.finalPrice {
                    CurrencyAmount(
                        amount: product.price,
                        amountFont: .custom("Poppins-Regular", size: 16),
                        amountColor: .gray,
                        currencyAssetName: "GrayVector",
                        isStrikethrough: true
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct ProductDetailsDescriptionSection: View {
    let descriptionText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Description".newlocalized)
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundStyle(.black)
            
            if descriptionText.isEmpty {
                Text("No description available.".newlocalized)
                    .font(.custom("Poppins-Regular", size: 15))
                    .foregroundStyle(.gray)
            } else {
                Text(descriptionText)
                    .font(.custom("Poppins-Regular", size: 15))
                    .foregroundStyle(.gray)
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct ProductDetailsBarcodeSection: View {
    let barcode: String
    
    var body: some View {
        VStack(spacing: 4) {
            if let uiImage = BarcodeGenerator.generate(from: barcode) {
                Image(uiImage: uiImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "barcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundStyle(.gray.opacity(0.5))
                    .frame(maxHeight: .infinity)
            }
            
            Text(barcode.isEmpty ? "No Barcode".newlocalized : barcode)
                .font(.custom("Courier", size: 16))
                .tracking(4)
                .foregroundStyle(.gray)
        }
        .frame(width: 138, height: 81)
        .frame(maxWidth: .infinity)
        .frame(height: 117)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - Helpers
private struct CurrencyAmount: View {
    let amount: Double
    let amountFont: Font
    let amountColor: Color
    let currencyAssetName: String
    let isStrikethrough: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(amount.formatted(.number.precision(.fractionLength(1))))
                .font(amountFont)
                .foregroundStyle(amountColor)

            Image(currencyAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .baselineOffset(-2)
        }
        .overlay(alignment: .center) {
            if isStrikethrough {
                Rectangle()
                    .fill(amountColor.opacity(0.8))
                    .frame(height: 1)
            }
        }
    }
}

private struct ProductDetailRibbon: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 40)
            .background(Color(red: 0.9, green: 0.3, blue: 0.3))
            .rotationEffect(.degrees(45))
            .offset(x: 38, y: 12)
    }
}
