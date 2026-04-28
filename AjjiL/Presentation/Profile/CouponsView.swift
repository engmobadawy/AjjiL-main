import SwiftUI

// MARK: - State

enum CouponsViewState {
    case loading
    case empty
    case loaded([CouponModel])
    case error(String)
}

// MARK: - ViewModel

@Observable
@MainActor
final class CouponsViewModel {
    // Internal view state must be private per guidelines
    private(set) var state: CouponsViewState = .loading
    
    // Dependencies
    private let getCouponsUseCase: GetCouponsUseCase
    
    init(getCouponsUseCase: GetCouponsUseCase) {
        self.getCouponsUseCase = getCouponsUseCase
    }
    
    func fetchCoupons(search: String? = nil) async {
        state = .loading
        
        do {
            let fetchedCoupons = try await getCouponsUseCase.execute(search: search)
            
            if fetchedCoupons.isEmpty {
                state = .empty
            } else {
                state = .loaded(fetchedCoupons)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

// MARK: - Main View

struct CouponsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Inject the ViewModel from the parent view
    @State private var viewModel: CouponsViewModel
    
    // Toast State
    @State private var showToast: Bool = false
    
    init(viewModel: CouponsViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Static top row that persists across all states
                TopRowNotForHome(
                    // 🛠️ FIX: Added .newlocalized
                    title: "Coupons".newlocalized,
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
                        EmptyCouponContent()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    case .loaded(let coupons):
                        // Pass the closure to trigger the toast
                        CouponsListView(coupons: coupons) {
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
                                Task { await viewModel.fetchCoupons() }
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
                    Text("Coupon copied!".newlocalized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(red: 20/255, green: 140/255, blue: 90/255)) // Brand green
                        .clipShape(Capsule())
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
            await viewModel.fetchCoupons()
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

struct EmptyCouponContent: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("coupon") // Make sure this asset exists in your catalog
                .resizable()
                .scaledToFit()
                .frame(width: 129, height: 90)
            
            VStack(spacing: 8) {
                // 🛠️ FIX: Added .newlocalized
                Text("No Coupons Available".newlocalized)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.primary)
                
                // 🛠️ FIX: Added .newlocalized
                Text("All the available Coupons will be here".newlocalized)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }
}

struct CouponsListView: View {
    let coupons: [CouponModel]
    var onCopy: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Using stable identity (id) from the CouponModel
                ForEach(coupons, id: \.id) { coupon in
                    PromoCodeCardView1(coupon: coupon, onCopy: onCopy)
                }
            }
            .padding()
        }
    }
}

// MARK: - Promo Code Card Component
struct PromoCodeCardView1: View {
    let coupon: CouponModel
    var onCopy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Header Row
            HStack(alignment: .center) {
                // 🛠️ FIX: Added .newlocalized
                Text(coupon.code ?? "N/A".newlocalized)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color(red: 20/255, green: 140/255, blue: 90/255))
                
                CouponBadgeView(isUsed: coupon.isUsed ?? false)
                
                Spacer()
                
                Button {
                    copyToClipboard(text: coupon.code ?? "")
                    onCopy() // Trigger toast
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 20))
                        .foregroundStyle(.gray.opacity(0.6))
                }
            }
            
            // Stores Row
            CouponStoresRowView()
            
            Spacer(minLength: 0)
            
            // Footer
            HStack {
                // 🛠️ FIX: Added .newlocalized
                Text("Expiration Date: ".newlocalized)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 229/255, green: 57/255, blue: 53/255)) +
                Text(coupon.expirationDate ?? "N/A".newlocalized)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 229/255, green: 57/255, blue: 53/255)) // Requested Red
                
                Spacer()
                
                let discountValue = Int(coupon.value ?? 0)
                
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
struct CouponBadgeView: View {
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
struct CouponStoresRowView: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "storefront")
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 20/255, green: 140/255, blue: 90/255))
            
            // 🛠️ FIX: Added .newlocalized
            Text("Stores:".newlocalized)
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 20/255, green: 140/255, blue: 90/255))
            
            // 🛠️ FIX: Added .newlocalized
            Text("All Stores".newlocalized)
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 20/255, green: 140/255, blue: 90/255))
        }
    }
}
