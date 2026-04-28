//
//  CartView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/03/2026.
//

import SwiftUI
import Foundation
import Shimmer

@MainActor
@Observable
final class CartViewModel {
    private let getCartUC: GetCartUC
    private let changeCartItemQuantityUC: ChangeCartItemQuantityUC
    private let removeProductFromCartUC: RemoveProductFromCartUC
    private let verifyPromoCodeUC: VerifyPromoCodeUseCase
    private let submitOrderUC: SubmitOrderUC // NEW
   
    private(set) var isLoading = false
    private(set) var cart: CartEntity? = nil
    private(set) var errorMessage: String? = nil
    
    // MARK: - Promo State
    private(set) var promoData: PromoCodeData? = nil
    private(set) var promoError: String? = nil
    private(set) var isApplyingPromo = false
    private(set) var appliedCouponCode: String? = nil // Tracks the successfully applied code
    
    // MARK: - Checkout State
    var paymentDestination: PaymentDestination? = nil // NEW
    
    // Debounce storage
    private var debounceTasks: [String: Task<Void, Never>] = [:]
    
    init(
        getCartUC: GetCartUC,
        changeCartItemQuantityUC: ChangeCartItemQuantityUC,
        removeProductFromCartUC: RemoveProductFromCartUC,
        verifyPromoCodeUC: VerifyPromoCodeUseCase,
        submitOrderUC: SubmitOrderUC // NEW
    ) {
        self.getCartUC = getCartUC
        self.changeCartItemQuantityUC = changeCartItemQuantityUC
        self.removeProductFromCartUC = removeProductFromCartUC
        self.verifyPromoCodeUC = verifyPromoCodeUC
        self.submitOrderUC = submitOrderUC
    }
    
    // MARK: - Fetch
    func fetchCart(branchId: String) async {
        isLoading = true
        errorMessage = nil
        // Reset promo when fetching a fresh cart
        promoData = nil
        promoError = nil
        
        do {
            cart = try await getCartUC.execute(branchId: branchId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Apply Promo Code
        func applyPromo(cartId: String, code: String) async {
            guard !code.isEmpty else { return }
            isApplyingPromo = true
            promoError = nil
            
            do {
                let response = try await verifyPromoCodeUC.execute(cartId: cartId, couponCode: code)
                
                if response.status == true, let data = response.data {
                    self.promoData = data
                } else {
                    // 🛠️ FIX: Added .newlocalized
                    self.promoError = response.message ?? "Not valid code".newlocalized
                }
            } catch {
                // 🛠️ FIX: Added .newlocalized
                self.promoError = "Not valid code".newlocalized
            }
            
            isApplyingPromo = false
        }
    
    
    
    // MARK: - Checkout / Confirm Payment
        func confirmPayment(cartId: String, storeId: String, branchId: String, paymentMethod: String) async {
            print("\n🚀 [CartViewModel] Starting confirmPayment...")
            print("📦 Parameters -> cartId: \(cartId), storeId: \(storeId), branchId: \(branchId), paymentMethod: \(paymentMethod), coupon: \(appliedCouponCode ?? "None")")
            
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await submitOrderUC.execute(
                    cartId: cartId,
                    storeId: storeId,
                    branchId: branchId,
                    paymentMethod: paymentMethod,
                    couponCode: appliedCouponCode
                )
                
                print("✅ [CartViewModel] confirmPayment API Response Status: \(response.status)")
                
                // Assuming response contains paymentLink property directly mapped to domain entity
                if response.status, let url = URL(string: response.paymentLink), !response.paymentLink.isEmpty {
                    print("🔗 [CartViewModel] Payment Link received! Opening WebView for: \(url)")
                    self.paymentDestination = PaymentDestination(url: url)
                } else {
                    let msg = response.message
                    print("⚠️ [CartViewModel] confirmPayment Failed or Missing URL: \(msg)")
                    self.errorMessage = msg
                }
            } catch {
                print("❌ [CartViewModel] confirmPayment Network/Decoding Error: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    
    
    
    
    // MARK: - Remove Promo Code
    func removePromo() {
        promoData = nil
        promoError = nil
    }
    
    // MARK: - Debounced Quantity Changes
    
    func incrementQuantity(for item: CartItemEntity, branchId: String) async {
        await scheduleQuantityChange(itemId: "\(item.itemId)", delta: +1, branchId: branchId)
    }
    
    func decrementQuantity(for item: CartItemEntity, branchId: String) async {
        await scheduleQuantityChange(itemId: "\(item.itemId)", delta: -1, branchId: branchId)
    }
    
    private func scheduleQuantityChange(itemId: String, delta: Int, branchId: String) async {
        // Cancel any pending task for this item
        debounceTasks[itemId]?.cancel()
        
        // Create a new debounced task
        let task = Task { [weak self] in
            // Wait 1 second – if another tap comes before that, this task is cancelled
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            // Check cancellation again after sleep
            guard !Task.isCancelled else { return }
            
            // Perform the actual network request
            await self?.performQuantityChange(itemId: itemId, delta: delta, branchId: branchId)
            
            // Clean up
            self?.debounceTasks[itemId] = nil
        }
        
        debounceTasks[itemId] = task
    }
    
    private func performQuantityChange(itemId: String, delta: Int, branchId: String) async {
        // 1. Find current quantity from the latest cart state
        guard let currentCart = cart,
              let item = currentCart.items.first(where: { "\($0.itemId)" == itemId }) else {
            return
        }
        
        let newQuantity = item.quantity + delta
        guard newQuantity >= 1 else { return }  // prevent zero or negative
        
        // 2. Start loading and execute the API call
        isLoading = true
        do {
            _ = try await changeCartItemQuantityUC.execute(
                itemId: itemId,
                quantity: "\(newQuantity)",
                branchId: branchId
            )
            // 3. Refresh the whole cart to get updated totals
            await fetchCart(branchId: branchId)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Delete Item
    func deleteItem(_ item: CartItemEntity, branchId: String) async {
        isLoading = true
        do {
            _ = try await removeProductFromCartUC.execute(itemId: "\(item.itemId)")
            await fetchCart(branchId: branchId)
        } catch {
            print("Delete error: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}


// MARK: - View
struct CartView: View {
    @FocusState private var isKeyboardOpen: Bool
    @Environment(TabBarVisibility.self) private var tabVisibility
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: CartViewModel
    
    // NEW: State for checkout flow
    @State private var isCheckoutPhase: Bool = false
    @State private var selectedPaymentMethod: PaymentMethod? = nil
    
    let branchId: String
    let storeName: String
    let storeId: String
    
    init(viewModel: CartViewModel, branchId: String, storeName: String, storeId: String) {
            self._viewModel = State(initialValue: viewModel)
            self.branchId = branchId
            self.storeName = storeName
            self.storeId = storeId
        }
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "\(storeName) - Cart".newlocalized,
                showBackButton: true,
                kindOfTopRow: .justNotification,
                onBack: {
                    // Intercept back button if in payment phase
                    if isCheckoutPhase {
                        withAnimation(.snappy) {
                            isCheckoutPhase = false
                        }
                    } else {
                        dismiss()
                    }
                }
            )
            
            contentState
        }
        .navigationBarBackButtonHidden(true)
        .onTapGesture {
            isKeyboardOpen = false
        }
        .onAppear {
            tabVisibility.isHidden = true
        }
        .onDisappear {
            tabVisibility.isHidden = false
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task(id: branchId) {
            await viewModel.fetchCart(branchId: branchId)
        }
        .sheet(item: $viewModel.paymentDestination) { destination in
                    PaymentGatewaySheet(destination: destination)
                }
    }
    
    // MARK: - View States
    
    @ViewBuilder
    private var contentState: some View {
        if let cart = viewModel.cart {
            if cart.items.isEmpty {
                emptyCartView
            } else {
                populatedCartView(cart: cart)
            }
        } else if let error = viewModel.errorMessage {
            Text(error)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding()
                .containerRelativeFrame([.horizontal, .vertical])
        } else {
            CartSkeletonView()
        }
    }
    
    @ViewBuilder
    private var emptyCartView: some View {
        VStack {
            Spacer()
            Image("NoOrders")
                .resizable()
                .scaledToFit()
                .frame(width: 189, height: 176)
            Spacer()
        }
        .padding(.bottom, 100)
    }
    
    @ViewBuilder
        private func populatedCartView(cart: CartEntity) -> some View {
            // 1. Wrap everything in a VStack so the ScrollView and Footer don't overlap
            VStack(spacing: 0) {
                ScrollView {
                    // Swap between Products and Payment Method
                    if !isCheckoutPhase {
                        LazyVStack(spacing: 16) {
                            ForEach(cart.items) { item in
                                CartItemCardView(
                                    item: item,
                                    onIncrement: { Task { await viewModel.incrementQuantity(for: item, branchId: branchId) } },
                                    onDecrement: { Task { await viewModel.decrementQuantity(for: item, branchId: branchId) } },
                                    onDelete: { Task { await viewModel.deleteItem(item, branchId: branchId) } }
                                )
                            }
                        }
                        .padding()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        
                    } else {
                        // Payment Selection Component
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Checkout Now".newlocalized)
                                .font(.custom("Poppins-Bold", size: 20))
                                .foregroundStyle(Color.titleDark)
                            
                            Text("Select The Suitable Payment Method For You".newlocalized)
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundStyle(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                                        PaymentMethodCell(
                                            method: method,
                                            isSelected: selectedPaymentMethod == method,
                                            action: {
                                                withAnimation(.snappy) {
                                                    selectedPaymentMethod = method
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 2)
                            }
                        }
                        .padding()
                        .scrollClipDisabled()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .animation(.snappy, value: isCheckoutPhase)
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(.rect(cornerRadius: 8))
                    }
                }
                
                // 2. The footer is now a sibling to the ScrollView, guaranteed to stay below it
                VStack(spacing: 0) {
                    CartSummaryFooter2(
                        totals: cart.totals,
                        promoData: viewModel.promoData,
                        promoError: viewModel.promoError,
                        isApplyingPromo: viewModel.isApplyingPromo,
                        isKeyboardOpen: $isKeyboardOpen,
                        onApplyCoupon: { code in
                            Task { await viewModel.applyPromo(cartId: "\(cart.cartId)", code: code) }
                        },
                        onRemoveCoupon: { viewModel.removePromo() }
                    )
                    
                    if !isKeyboardOpen {
                        GreenButton(title: isCheckoutPhase ? "Confirm Payment".newlocalized : "Checkout".newlocalized) {
                            if isCheckoutPhase {
                                guard let selectedMethod = selectedPaymentMethod else { return }
                                print("🟢 [CartView] Confirm Payment button tapped! Selected Method: \(selectedMethod.rawValue)")
                                
                                Task {
                                    await viewModel.confirmPayment(
                                        cartId: "\(cart.cartId)",
                                        storeId: storeId,
                                        branchId: branchId,
                                        paymentMethod: selectedMethod.apiId // Pass mapped ID
                                    )
                                }
                            } else {
                                withAnimation(.snappy) {
                                    isCheckoutPhase = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .disabled(isCheckoutPhase && selectedPaymentMethod == nil)
                        .opacity((isCheckoutPhase && selectedPaymentMethod == nil) ? 0.5 : 1.0)
                    }
                }
                // Optional solid background to prevent parent view colors bleeding through
//                .background(Color(uiColor: .systemBackground))
                .background(Color.brandGreen.opacity(0.1).ignoresSafeArea(edges: .bottom))
                .animation(.snappy, value: isKeyboardOpen)
            }
        }
}

// MARK: - Skeleton Loading Views
struct CartSkeletonView: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { _ in
                        CartItemSkeletonCell()
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .disabled(true)
            
            CartFooterSkeleton()
        }
        .shimmering()
    }
}

struct CartItemSkeletonCell: View {
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(width: 106, height: 86)
                .clipShape(.rect(cornerRadius: 8))
                .padding(16)
                .frame(width: 138, height: 118)
                .overlay(alignment: .trailing) {
                    Rectangle().frame(width: 1).foregroundStyle(Color.cardBorder)
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 60, height: 12).clipShape(.rect(cornerRadius: 4))
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 120, height: 16).clipShape(.rect(cornerRadius: 4))
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 80, height: 14).clipShape(.rect(cornerRadius: 4))
                
                Spacer(minLength: 0)
                
                HStack {
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 100, height: 36).clipShape(.rect(cornerRadius: 8))
                    Spacer()
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 24, height: 24).clipShape(.rect(cornerRadius: 4))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .frame(height: 118)
        .background(Color(uiColor: .systemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cardBorder, lineWidth: 1)
        }
    }
}

struct CartFooterSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 50)
                .clipShape(.rect(cornerRadius: 12))
            
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    HStack {
                        Rectangle().fill(.gray.opacity(0.3)).frame(width: 120, height: 14).clipShape(.rect(cornerRadius: 4))
                        Spacer()
                        Rectangle().fill(.gray.opacity(0.3)).frame(width: 60, height: 14).clipShape(.rect(cornerRadius: 4))
                    }
                }
            }
            
            Divider().padding(.vertical, 4)
            
            HStack {
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 100, height: 20).clipShape(.rect(cornerRadius: 4))
                Spacer()
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 80, height: 20).clipShape(.rect(cornerRadius: 4))
            }
            
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 50)
                .clipShape(.rect(cornerRadius: 12))
                .padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(Color.brandGreen.opacity(0.1).ignoresSafeArea(edges: .bottom))
    }
}

// MARK: - Main Card View
struct CartItemCardView: View {
    let item: CartItemEntity
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            CartItemImageView(imageURLString: item.imageURL)
            
            CartItemDetailsView(
                item: item,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onDelete: onDelete
            )
        }
        .frame(height: 118)
        .background(Color(uiColor: .systemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cardBorder, lineWidth: 1)
        }
    }
}

// MARK: - Subviews
private struct CartItemImageView: View {
    let imageURLString: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageURLString)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "photo")
                    .foregroundStyle(.gray)
            @unknown default:
                EmptyView()
            }
        }
        .padding(16)
        .frame(width: 138, height: 118)
        .overlay(alignment: .trailing) {
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(Color.cardBorder)
        }
    }
}

private struct CartItemDetailsView: View {
    let item: CartItemEntity
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.category)
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundStyle(Color.categoryRed)
            
            Text(item.name)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundStyle(Color.titleDark)
            
            HStack(spacing: 4) {
                Text(item.totalPrice, format: .number.precision(.fractionLength(1)))
                    .font(.system(size: 14))
                    .foregroundStyle(Color.priceOrange)
                
                Image("OrangeVector")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 11, height: 11)
            }
            
            Spacer(minLength: 0)
            
            CartItemControlsView(
                quantity: item.quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onDelete: onDelete
            )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

private struct CartItemControlsView: View {
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 16) {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 39.6, height: 36)
                        .background(Color.buttonGreen)
                        .clipShape(.rect(cornerRadius: 8))
                }
                
                Text(quantity, format: .number)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.buttonGreen)
                
                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 39.6, height: 36)
                        .background(Color.buttonGreen)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image("redTrash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
    }
}

// MARK: - Cart Summary Footer
struct CartSummaryFooter: View {
    let totals: CartTotalsEntity
    
    var body: some View {
        VStack(spacing: 12) {
            summaryRow(title: "Subtotal (Excl. VAT)".newlocalized, value: "\(totals.totalExc)")
            summaryRow(title: "Subtotal (Incl. VAT)".newlocalized, value: "\(totals.totalInc)")
            summaryRow(title: "Vat Value".newlocalized, value: "\(totals.totalTax)")
            summaryRow(title: "Discount".newlocalized, value: "\(totals.discount)", valueColor: .red, isDiscount: true)
            
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                Text("Total Price".newlocalized)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                PriceView(value: "\(totals.total)", font: .title3, weight: .bold)
            }
        }
        .padding()
        .background(Color.brandGreen.opacity(0.1))
    }
    
    private func summaryRow(title: String, value: String, valueColor: Color = .primary, isDiscount: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            PriceView(value: value, font: .subheadline, weight: .semibold, color: valueColor, isDiscount: isDiscount)
        }
    }
}

extension Color {
    static let cardBorder = Color(red: 232/255, green: 239/255, blue: 243/255)
    static let categoryRed = Color(red: 255/255, green: 100/255, blue: 100/255)
    static let titleDark = Color(red: 48/255, green: 55/255, blue: 51/255)
    static let priceOrange = Color(red: 255/255, green: 119/255, blue: 1/255)
    static let buttonGreen = Color(red: 2/255, green: 115/255, blue: 53/255)
}

struct CartSummaryFooter2: View {
    let totals: CartTotalsEntity
    let promoData: PromoCodeData?
    let promoError: String?
    let isApplyingPromo: Bool
    
    var isKeyboardOpen: FocusState<Bool>.Binding
    
    let onApplyCoupon: (String) -> Void
    let onRemoveCoupon: () -> Void
    
    @State private var couponCode: String = ""
    
    private var isButtonActive: Bool {
        promoData != nil || !couponCode.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    TextField("coupons".newlocalized, text: $couponCode)
                                            .focused(isKeyboardOpen)
                                            .padding(.horizontal, 16)
                                            .foregroundStyle(Color.titleDark)
                                            .disabled(promoData != nil || isApplyingPromo)
                                        
                                        // 🛠️ FIX: Added .newlocalized
                        Button(promoData != nil ? "Applied".newlocalized : "Apply".newlocalized) {
                        withAnimation(.snappy) {
                            if promoData != nil {
                                onRemoveCoupon()
                                couponCode = ""
                            } else {
                                onApplyCoupon(couponCode)
                            }
                        }
                    }
                    .disabled((couponCode.isEmpty && promoData == nil) || isApplyingPromo)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isButtonActive ? .white : .gray)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(isButtonActive ? Color.priceOrange : Color(uiColor: .systemGray5))
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(4)
                }
                .background(Color(uiColor: .systemBackground))
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(promoError != nil ? .red : .clear, lineWidth: 1)
                }
                
                if let error = promoError {
                    Text(error.lowercased())
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 4)
            
            // MARK: - price list
            VStack(spacing: 12) {
                summaryRow(title: "subtotal (no vat)".newlocalized, value: "\(totals.totalExc)")
                                summaryRow(title: "subtotal (with vat)".newlocalized, value: "\(totals.totalInc)")
                                summaryRow(title: "vat".newlocalized, value: "\(totals.totalTax)")
                                
                                let displayDiscount = promoData != nil ? "\(promoData!.couponValue ?? 0)" : "\(totals.discount)"
                                summaryRow(title: "discount".newlocalized, value: displayDiscount, valueColor: .red, isDiscount: true)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // MARK: - final total
            HStack {
                Text("total price".newlocalized)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.titleDark)
                
                Spacer()
                
                let displayTotal = promoData != nil ? "\(promoData!.priceAfter ?? 0)" : "\(totals.total)"
                PriceView(value: displayTotal, font: .title3, weight: .bold, color: Color.priceOrange)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - row helper
    private func summaryRow(title: String, value: String, valueColor: Color = .primary, isDiscount: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.titleDark.opacity(0.8))
            
            Spacer()
            
            PriceView(value: value, font: .subheadline, weight: .bold, color: valueColor, isDiscount: isDiscount)
        }
    }
}

// MARK: - Payment Method Models & Views

enum PaymentMethod: String, CaseIterable {
    case visa = "visaImage"
    case mada = "madaImage"
    case applePay = "applePayImage"
    
    // Maps the visual selection to the backend API required ID.
    // Replace "1", "2", "3" with your actual backend payment method IDs.
    var apiId: String {
        switch self {
        case .visa: return "2"
        case .mada: return "3"
        case .applePay: return "1"
        }
    }
}

struct PaymentMethodCell: View {
    let method: PaymentMethod
    let isSelected: Bool
    let action: () -> Void
    
    // Brand color for selected border: rgba(3, 184, 158, 1)
    private let primaryBrand = Color(red: 3/255, green: 184/255, blue: 158/255)
    
    // Background color when selected: rgba(222, 255, 252, 1)
    private let selectedBackground = Color(red: 222/255, green: 255/255, blue: 252/255)
    
    // Border color when not selected: rgba(119, 119, 119, 0.25)
    private let unselectedBorder = Color(red: 119/255, green: 119/255, blue: 119/255, opacity: 0.25)
    
    var body: some View {
        Button(action: action) {
            Image(method.rawValue)
                .resizable()
                .scaledToFit()
                .padding(16)
                // Consider replacing hard-coded constants with relative layout constraints if this cell needs to scale across devices
                .frame(width: 127, height: 79)
                .background(isSelected ? selectedBackground : .clear)
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? primaryBrand : unselectedBorder, lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}







import WebKit

// Navigation trigger model
//struct PaymentDestination: Identifiable {
//    let id = UUID()
//    let url: URL
//}

// Reusable WKWebView Wrapper
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

// The Sheet presented over the Cart
struct PaymentGatewaySheet: View {
    @Environment(\.dismiss) private var dismiss
    let destination: PaymentDestination
    
    var body: some View {
        NavigationStack {
            WebView(url: destination.url)
                // 🛠️ FIX: Added .newlocalized
                .navigationTitle("Secure Payment".newlocalized)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        // 🛠️ FIX: Added .newlocalized
                        Button("back".newlocalized) {
                            dismiss()
                        }
                    }
                }
        }
    }
}
