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
    private let verifyPromoCodeUC: VerifyPromoCodeUseCase // NEW
   
    private(set) var isLoading = false
    private(set) var cart: CartEntity? = nil
    private(set) var errorMessage: String? = nil
    
    // MARK: - Promo State
    private(set) var promoData: PromoCodeData? = nil
    private(set) var promoError: String? = nil
    private(set) var isApplyingPromo = false
    
    // Debounce storage
    private var debounceTasks: [String: Task<Void, Never>] = [:]
    
    init(
        getCartUC: GetCartUC,
        changeCartItemQuantityUC: ChangeCartItemQuantityUC,
        removeProductFromCartUC: RemoveProductFromCartUC,
        verifyPromoCodeUC: VerifyPromoCodeUseCase // NEW
    ) {
        self.getCartUC = getCartUC
        self.changeCartItemQuantityUC = changeCartItemQuantityUC
        self.removeProductFromCartUC = removeProductFromCartUC
        self.verifyPromoCodeUC = verifyPromoCodeUC
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
                // If backend returns a false status but doesn't throw a network error
                self.promoError = response.message ?? "Not valid code"
            }
        } catch {
            // If the network call throws an error
            self.promoError = "Not valid code"
        }
        
        isApplyingPromo = false
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
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
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
    
    // MARK: - Delete Item (unchanged, but you can also debounce if needed)
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
    let branchId: String
    let storeName: String
    
    init(viewModel: CartViewModel, branchId: String, storeName: String) {
        self._viewModel = State(initialValue: viewModel)
        self.branchId = branchId
        self.storeName = storeName // NEW: Initialize it
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "\(storeName) - Cart",
                showBackButton: true,
                kindOfTopRow: .justNotification,
                onBack: { dismiss() }
            )
            
            contentState
        }
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
            // 2. Replace ProgressView with Shimmering Skeleton
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
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(cart.items) { item in
                    CartItemCardView(
                        item: item,
                        onIncrement: {
                            Task {
                                await viewModel.incrementQuantity(for: item, branchId: branchId)
                            }
                        },
                        onDecrement: {
                            Task {
                                await viewModel.decrementQuantity(for: item, branchId: branchId)
                            }
                        },
                        onDelete: {
                            Task {
                                await viewModel.deleteItem(item, branchId: branchId)
                            }
                        }
                    )
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .overlay {
            // This will show a spinner right over the items while updating quantity/deleting
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                CartSummaryFooter2(
                    totals: cart.totals,
                    promoData: viewModel.promoData,
                    promoError: viewModel.promoError,
                    isApplyingPromo: viewModel.isApplyingPromo,
                    isKeyboardOpen: $isKeyboardOpen, // NEW: pass it to footer
                    onApplyCoupon: { code in
                        Task { await viewModel.applyPromo(cartId: "\(cart.cartId)", code: code) }
                    },
                    onRemoveCoupon: { viewModel.removePromo() }
                )
                
                // NEW: hide checkout button smoothly when keyboard is open
                if !isKeyboardOpen {
                    GreenButton(title: "Checkout") {
                        // TODO: Checkout Action
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(Color.brandGreen.opacity(0.1).ignoresSafeArea(edges: .bottom))
            .animation(.snappy, value: isKeyboardOpen) // smooth animation
        }
    }
}

// MARK: - Skeleton Loading Views
/// 3. Skeleton mimicking the Cart Items and Footer
struct CartSkeletonView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Items List Skeleton
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
            
            // Footer Skeleton attached to bottom
            CartFooterSkeleton()
        }
        .shimmering() // Applies effect to the entire layout
    }
}

struct CartItemSkeletonCell: View {
    var body: some View {
        HStack(spacing: 0) {
            // Image Placeholder area
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(width: 106, height: 86) // Approximate image bounds
                .clipShape(.rect(cornerRadius: 8))
                .padding(16)
                .frame(width: 138, height: 118)
                .overlay(alignment: .trailing) {
                    Rectangle().frame(width: 1).foregroundStyle(Color.cardBorder)
                }
            
            // Details Placeholder
            VStack(alignment: .leading, spacing: 8) {
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 60, height: 12).clipShape(.rect(cornerRadius: 4))
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 120, height: 16).clipShape(.rect(cornerRadius: 4))
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 80, height: 14).clipShape(.rect(cornerRadius: 4))
                
                Spacer(minLength: 0)
                
                HStack {
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 100, height: 36).clipShape(.rect(cornerRadius: 8)) // Stepper placeholder
                    Spacer()
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 24, height: 24).clipShape(.rect(cornerRadius: 4)) // Trash placeholder
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
            // Promo Field Placeholder
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 50)
                .clipShape(.rect(cornerRadius: 12))
            
            // Totals Rows
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
            
            // Final Total
            HStack {
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 100, height: 20).clipShape(.rect(cornerRadius: 4))
                Spacer()
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 80, height: 20).clipShape(.rect(cornerRadius: 4))
            }
            
            // Checkout Button Placeholder
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
            // Custom Stepper
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
            
            // Trash Button
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
            summaryRow(title: "Subtotal (Excl. VAT)", value: "\(totals.totalExc)")
            summaryRow(title: "Subtotal (Incl. VAT)", value: "\(totals.totalInc)")
            summaryRow(title: "Vat Value", value: "\(totals.totalTax)")
            summaryRow(title: "Discount", value: "\(totals.discount)", valueColor: .red, isDiscount: true)
            
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                Text("Total Price")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Reusing your custom PriceView component from the OrderDetails UI
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
    
    // NEW: receive the focus state
    var isKeyboardOpen: FocusState<Bool>.Binding
    
    let onApplyCoupon: (String) -> Void
    let onRemoveCoupon: () -> Void
    
    @State private var couponCode: String = ""
    
    // A computed property to clean up our conditional logic
    private var isButtonActive: Bool {
        promoData != nil || !couponCode.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    TextField("coupons", text: $couponCode)
                        .focused(isKeyboardOpen)
                        .padding(.horizontal, 16)
                        .foregroundStyle(Color.titleDark)
                        .disabled(promoData != nil || isApplyingPromo)
                    
                    Button(promoData != nil ? "Applied" : "Apply") {
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
                    // UPDATED: Use white if typing or applied, otherwise gray
                    .foregroundStyle(isButtonActive ? .white : .gray)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    // UPDATED: Use orange if typing or applied, otherwise gray
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
                summaryRow(title: "subtotal (no vat)", value: "\(totals.totalExc)")
                summaryRow(title: "subtotal (with vat)", value: "\(totals.totalInc)")
                summaryRow(title: "vat", value: "\(totals.totalTax)")
                
                let displayDiscount = promoData != nil ? "\(promoData!.couponValue ?? 0)" : "\(totals.discount)"
                summaryRow(title: "discount", value: displayDiscount, valueColor: .red, isDiscount: true)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // MARK: - final total
            HStack {
                Text("total price")
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
