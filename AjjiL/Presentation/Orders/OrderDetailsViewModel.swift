//
//  OrderDetailsViewModel.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 09/04/2026.
//

import SwiftUI
import UIKit
import Shimmer // 1. Import Shimmer

@MainActor
@Observable
final class OrderDetailsViewModel {
    private let getOrderDetailsUC: GetOrderDetailsUC
   
    private(set) var isLoading = false
    private(set) var order: OrderDetailEntity? = nil
    private(set) var errorMessage: String? = nil
    
    init(getOrderDetailsUC: GetOrderDetailsUC) {
        self.getOrderDetailsUC = getOrderDetailsUC
    }
    
    func fetchDetails(id: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            order = try await getOrderDetailsUC.execute(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Main View

struct OrderDetailsView: View {
    @Environment(TabBarVisibility.self) private var tabVisibility
    @Environment(\.dismiss) private var dismiss
    let orderId: Int
    @State private var viewModel: OrderDetailsViewModel
    
    @State private var goToRateServicesView: Bool = false
    
    init(orderId: Int, viewModel: OrderDetailsViewModel) {
        self.orderId = orderId
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "Order Details",
                showBackButton: true,
                kindOfTopRow: .rate,
                onBack: {
                    dismiss()
                },onRate: {
                    goToRateServicesView = true
                }
            )
            
            ScrollView {
                contentState
            }
            .scrollIndicators(.hidden)
            
            .safeAreaInset(edge: .bottom) {
                // Safe area inset is applied to the ScrollView to float the footer properly
                if let order = viewModel.order {
                    OrderSummaryFooter(
                        subtotalExclVat: order.priceExcludeVate,
                        subtotalInclVat: order.priceIncludeVate,
                        vatValue: order.totalTax,
                        discount: order.discount,
                        totalPrice: order.grandTotal
                    ).padding(.bottom, 10)
                } else if viewModel.isLoading {
                    // 2. Show Footer Skeleton while loading
                    OrderSummaryFooterSkeleton()
                        .shimmering()
                        .padding(.bottom, 10)
                }
            }
        }
        .onAppear {
            // Hide the custom tab bar when entering this screen
            tabVisibility.isHidden = true
        }
        .onDisappear {
            // Show it again when navigating back
            tabVisibility.isHidden = false
        }
        .navigationDestination(isPresented: $goToRateServicesView) {
            // 1. Initialize your dependencies (matching your project's pattern)
            let repo = OrdersRepositoryImp(networkService: NetworkService())
            let useCase = ReviewOrderUC(repo: repo)
            let rateViewModel = RateServicesViewModel(orderId: orderId, reviewOrderUC: useCase)
            
            // 2. Return the RateServicesView
            RateServicesView(viewModel: rateViewModel) {
                // onSuccessDoubleDismiss closure
                // This dismisses the OrderDetailsView, returning the user to the OrdersView
                dismiss()
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task(id: orderId) {
            await viewModel.fetchDetails(id: orderId)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var contentState: some View {
        // 1. If we have the order, show it immediately.
        if let order = viewModel.order {
            VStack(spacing: 24) {
                OrderDetailsHeaderCard(
                    referenceNo: order.referenceNo,
                    totalAmount: order.priceIncludeVate,
                    dateString: order.createdAt,
                    storeName: order.store,
                    storeImageUrl: URL(string: order.storeImage),
                    rating: order.rate
                )
                
                productListSection(items: order.items, status: order.status)
            }
            .padding()
            // Optional: If you ever add a "Pull to Refresh", this overlays
            // a small spinner on top of the existing details so the screen doesn't flash.
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            
        // 2. If we hit an error, show the message.
        } else if let error = viewModel.errorMessage {
            Text(error)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding()
                .containerRelativeFrame([.horizontal, .vertical])
                
        // 3. Fallback: Replaced ProgressView with Shimmer Skeleton!
        } else {
            OrderDetailsContentSkeleton()
                .shimmering()
        }
    }
    
    @ViewBuilder
    private func productListSection(items: [OrderItemEntity], status: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Product List")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(status)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundStyle(.orange)
                    .clipShape(.rect(cornerRadius: 4))
            }
            
            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    OrderProductCell(
                        imageUrl: URL(string: item.image),
                        category: item.category,
                        productName: item.productName,
                        quantity: item.quantity,
                        price: "\(item.total)"
                    )
                }
            }
        }
    }
}

// MARK: - Skeleton Views

struct OrderDetailsContentSkeleton: View {
    var body: some View {
        VStack(spacing: 24) {
            // Header Card Skeleton
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 140, height: 24).clipShape(.rect(cornerRadius: 6))
                    Spacer()
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 80, height: 20).clipShape(.rect(cornerRadius: 6))
                }
                
                HStack(spacing: 8) {
                    Circle().fill(.gray.opacity(0.3)).frame(width: 16, height: 16)
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 180, height: 16).clipShape(.rect(cornerRadius: 4))
                }
                
                HStack(spacing: 8) {
                    Circle().fill(.gray.opacity(0.3)).frame(width: 16, height: 16)
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 60, height: 16).clipShape(.rect(cornerRadius: 4))
                    Circle().fill(.gray.opacity(0.3)).frame(width: 22, height: 22)
                    
                    Spacer()
                    
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 40, height: 16).clipShape(.rect(cornerRadius: 4))
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .clipShape(.rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            // Product List Section Skeleton
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 120, height: 24).clipShape(.rect(cornerRadius: 6))
                    Spacer()
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 80, height: 24).clipShape(.rect(cornerRadius: 4))
                }
                
                LazyVStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 16) {
                            Rectangle().fill(.gray.opacity(0.3)).frame(width: 64, height: 64).clipShape(.rect(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Rectangle().fill(.gray.opacity(0.3)).frame(width: 60, height: 12).clipShape(.rect(cornerRadius: 4))
                                Rectangle().fill(.gray.opacity(0.3)).frame(width: 130, height: 18).clipShape(.rect(cornerRadius: 4))
                                
                                HStack {
                                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 80, height: 14).clipShape(.rect(cornerRadius: 4))
                                    Spacer()
                                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 60, height: 16).clipShape(.rect(cornerRadius: 4))
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                }
            }
        }
        .padding()
    }
}

struct OrderSummaryFooterSkeleton: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { _ in
                HStack {
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 140, height: 16).clipShape(.rect(cornerRadius: 4))
                    Spacer()
                    Rectangle().fill(.gray.opacity(0.3)).frame(width: 60, height: 16).clipShape(.rect(cornerRadius: 4))
                }
            }
            
            Divider().padding(.vertical, 4)
            
            HStack {
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 100, height: 22).clipShape(.rect(cornerRadius: 4))
                Spacer()
                Rectangle().fill(.gray.opacity(0.3)).frame(width: 80, height: 22).clipShape(.rect(cornerRadius: 4))
            }
        }
        .padding()
        .background(Color.brandGreen.opacity(0.1))
    }
}


// MARK: - POD Subviews

struct OrderDetailsHeaderCard: View {
    let referenceNo: String
    let totalAmount: String
    let dateString: String
    let storeName: String
    let storeImageUrl: URL?
    let rating: String? // 👈 Changed from Int? to String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(referenceNo)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.brandGreen)
                
                Spacer()
                
                PriceView(value: totalAmount, font: .headline)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundStyle(.brandGreen)
                Text("Requested Date: \(dateString)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "storefront")
                    .foregroundStyle(.brandGreen)
                
                Text("Store")
                    .font(.subheadline)
                    .foregroundStyle(.brandGreen)
                
                // Store Logo
                AsyncImage(url: storeImageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .controlSize(.mini)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundStyle(.gray)
                            .font(.caption2)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 22, height: 22)
                .clipShape(.circle)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                
                Spacer()
                
                // Rating Display
                if let rating = rating {
                    HStack(spacing: 4) {
                        Text("(\(rating))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: "star.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct OrderProductCell: View {
    let imageUrl: URL?
    let category: String
    let productName: String
    let quantity: Int
    let price: String
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(.rect(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.caption)
                    .foregroundStyle(.brandGreen)
                
                Text(productName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack {
                    Text("Quantity: \(quantity)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    PriceView(value: price)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct OrderSummaryFooter: View {
    let subtotalExclVat: String
    let subtotalInclVat: String
    let vatValue: String
    let discount: String
    let totalPrice: String
    
    var body: some View {
        VStack(spacing: 12) {
            summaryRow(title: "Subtotal (Excl. VAT)", value: subtotalExclVat)
            summaryRow(title: "Subtotal (Incl. VAT)", value: subtotalInclVat)
            summaryRow(title: "Vat Value", value: vatValue)
            summaryRow(title: "Discount", value: discount, valueColor: .red, isDiscount: true)
            
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                Text("Total Price")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                PriceView(value: totalPrice, font: .title3, weight: .bold)
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

struct PriceView: View {
    let value: String
    var font: Font = .subheadline
    var weight: Font.Weight = .regular
    var color: Color = .orange
    var isDiscount: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(isDiscount ? "-\(value)" : value)
                .font(font)
                .fontWeight(weight)
                .foregroundStyle(color)
            
            Image("OrangeVector")
                .resizable()
                .scaledToFit()
                // Using relative scaling so it matches the font size automatically
                .frame(height: UIFont.preferredFont(forTextStyle: textStyle(for: font)).pointSize * 0.7)
        }
    }
    
    // Helper to map SwiftUI Font to UIFont.TextStyle for relative image sizing
    private func textStyle(for font: Font) -> UIFont.TextStyle {
        switch font {
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .caption: return .caption1
        default: return .body
        }
    }
}

#Preview {
    // 1. Setup Mock Repository and Use Case
    let mockRepo = OrdersRepositoryImp(networkService: NetworkService())
    let useCase = GetOrderDetailsUC(repo: mockRepo)
    let viewModel = OrderDetailsViewModel(getOrderDetailsUC: useCase)
    
    // 2. Initialize View with the specific Order ID
    NavigationStack {
        OrderDetailsView(orderId: 229, viewModel: viewModel)
    }
}
