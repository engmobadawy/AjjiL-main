//
//  PromoCodesViewState.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//

import SwiftUI

// MARK: - State

enum PromoCodesViewState {
    case loading
    case empty
    case loaded([PromoCodeDTO])
    case error(String)
}

// MARK: - ViewModel

@Observable
@MainActor
final class PromoCodesViewModel {
    // Internal view state must be private per guidelines
    private(set) var state: PromoCodesViewState = .loading
    
    // Dependencies
    private let getPromoCodesUC: GetPromoCodesUC
    
    init(getPromoCodesUC: GetPromoCodesUC) {
        self.getPromoCodesUC = getPromoCodesUC
    }
    
    func fetchPromoCodes() async {
        state = .loading
        
        do {
            let fetchedCodes = try await getPromoCodesUC.execute()
            
            if fetchedCodes.isEmpty {
                state = .empty
            } else {
                state = .loaded(fetchedCodes)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

// MARK: - Main View

struct PromoCodesView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Inject the ViewModel from the parent view
    @State private var viewModel: PromoCodesViewModel
    
    // Toast State
    @State private var showToast: Bool = false
    
    init(viewModel: PromoCodesViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Static top row that persists across all states
                TopRowNotForHome(
                    // 🛠️ FIX: Added .newlocalized
                    title: "Promo Code".newlocalized,
                    showBackButton: true,
                    kindOfTopRow: .none,
                    onBack: {
                        dismiss()
                    }
                )
                
                // Switch statement driving the view identity based on state
                Group {
                    switch viewModel.state {
                    case .loading:
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    case .empty:
                        EmptyPromoCodeContent()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    case .loaded(let promoCodes):
                        PromoCodesListView(promoCodes: promoCodes) {
                            triggerToast()
                        }
                        
                    case .error(let message):
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundStyle(.red)
                            Text(message)
                                .font(.body)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                            
                            // 🛠️ FIX: Added .newlocalized
                            Button("Try Again".newlocalized) {
                                Task { await viewModel.fetchPromoCodes() }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .background(Color(red: 245/255, green: 245/255, blue: 245/255)) // Light background behind cards
            
            // MARK: - Toast Overlay
            if showToast {
                VStack {
                    Spacer()
                    // 🛠️ FIX: Added .newlocalized
                    Text("Promo code copied!".newlocalized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(red: 20/255, green: 140/255, blue: 90/255)) // Brand green
                        .clipShape(.capsule)
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(1) // Ensures it sits on top of everything
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            // Automatic cancellation of async work tied to view lifecycle
            await viewModel.fetchPromoCodes()
        }
    }
    
    // MARK: - Helper Methods
    private func triggerToast() {
        // Use animation for smooth appearance
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showToast = true
        }
        
        // Auto-hide after 2 seconds using modern Task API
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeOut(duration: 0.3)) {
                showToast = false
            }
        }
    }
}

// MARK: - Subviews

struct EmptyPromoCodeContent: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("coupon") // Make sure this asset exists in your catalog
                .resizable()
                .scaledToFit()
                .frame(width: 129, height: 90)
            
            VStack(spacing: 8) {
                // 🛠️ FIX: Added .newlocalized
                Text("No Promo Codes Available".newlocalized)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.primary)
                
                // 🛠️ FIX: Added .newlocalized
                Text("All the available promo codes will be here".newlocalized)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }
}

struct PromoCodesListView: View {
    let promoCodes: [PromoCodeDTO]
    var onCopy: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Using stable identity (id) from the DTO
                ForEach(promoCodes, id: \.id) { promoCode in
                    PromoCodeCardView(promoCode: promoCode, onCopy: onCopy)
                }
            }
            .padding()
        }
    }
}

// MARK: - Promo Code Card Component
struct PromoCodeCardView: View {
    let promoCode: PromoCodeDTO
    var onCopy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Header Row
            HStack(alignment: .center) {
                // 🛠️ FIX: Added .newlocalized for N/A
                Text(promoCode.code ?? "N/A".newlocalized)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color(red: 20/255, green: 140/255, blue: 90/255))
                
                PromoCodeBadgeView(isUsed: promoCode.isUsed ?? false)
                
                Spacer()
                
                Button {
                    copyToClipboard(text: promoCode.code ?? "")
                    onCopy() // Trigger toast
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 20))
                        .foregroundStyle(.gray.opacity(0.6))
                }
            }
            
            // Subtitle
            // 🛠️ FIX: Added .newlocalized
            Text("Apply promo code to avail exciting offers".newlocalized)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(red: 1/255, green: 150/255, blue: 131/255))
            
            // Stores Row
            PromoCodeStoresRowView(stores: promoCode.stores)
            
            Spacer(minLength: 0)
            
            // Footer
            HStack {
                // 🛠️ FIX: Added .newlocalized
                Text("Expiration Date: ".newlocalized)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 229/255, green: 57/255, blue: 53/255)) +
                // 🛠️ FIX: Added .newlocalized for N/A
                Text(promoCode.expirationDate ?? "N/A".newlocalized)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 229/255, green: 57/255, blue: 53/255))
                
                Spacer()
                
                let discountValue = Int(promoCode.value ?? 0)
                
                HStack(spacing: 4) {
                    Text("-\(discountValue)")
                        .font(.title2.bold())
                        .foregroundStyle(.black)
                    
                    Image("GrayVector")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                }
            }
        }
        .padding()
        .frame(height: 142) // Strict design requirement
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
    }
}

// MARK: - Badge Subview
struct PromoCodeBadgeView: View {
    let isUsed: Bool
    
    var body: some View {
        // 🛠️ FIX: Added .newlocalized
        Text(isUsed ? "Used".newlocalized : "Not Used".newlocalized)
            .font(.system(size: 8, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                isUsed
                ? Color(red: 139/255, green: 197/255, blue: 63/255)
                : Color(red: 255/255, green: 119/255, blue: 1/255)
            )
            .clipShape(.rect(cornerRadius: 4))
    }
}

// MARK: - Stores Row Subview
struct PromoCodeStoresRowView: View {
    let stores: [StoreDTO]?
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "storefront")
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 20/255, green: 140/255, blue: 90/255))
            
            // 🛠️ FIX: Added .newlocalized
            Text("Stores:".newlocalized)
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 20/255, green: 140/255, blue: 90/255))
            
            if let stores = stores, !stores.isEmpty {
                HStack(spacing: -2) {
                    // Safe bounding: Display up to 5 overlapping store images to prevent layout breaking
                    ForEach(stores.prefix(5), id: \.id) { store in
                        AsyncImage(url: URL(string: store.image ?? "")) { phase in
                            switch phase {
                            case .empty:
                                Circle().fill(Color.gray.opacity(0.2))
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                // Fallback if image fails to load
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        Image(systemName: "building.2.fill")
                                            .font(.system(size: 8))
                                            .foregroundStyle(.blue)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 20, height: 20)
                        .clipShape(.circle)
                        .overlay(
                            Circle().stroke(.white, lineWidth: 1)
                        )
                    }
                }
                .padding(.leading, 4)
            } else {
                // 🛠️ FIX: Added .newlocalized
                Text("All Stores".newlocalized)
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                    .padding(.leading, 4)
            }
        }
    }
}
