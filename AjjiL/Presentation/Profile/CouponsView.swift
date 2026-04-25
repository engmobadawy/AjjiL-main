//
//  CouponsViewState.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//


import SwiftUI

// MARK: - State & Models

enum CouponsViewState {
    case loading
    case empty
    case loaded([Coupon])
    case error(String)
}

// Placeholder model to represent a single coupon
struct Coupon: Identifiable, Hashable {
    let id: UUID
    let title: String
}

@Observable
@MainActor
final class CouponsViewModel {
    // Internal view state must be private per guidelines
    private(set) var state: CouponsViewState = .loading
    
    func fetchCoupons() async {
        state = .loading
        
        // Simulating a network request delay
        try? await Task.sleep(for: .seconds(1))
        
        // Switching to empty state for demonstration
        state = .empty
    }
}

// MARK: - Main View

struct CouponsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CouponsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Static top row that persists across all states
            TopRowNotForHome(
                title: "Coupons",
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case .empty:
                    EmptyCouponContent()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case .loaded(let coupons):
                    // Extracted subview for the populated list
                    CouponsListView(coupons: coupons)
                    
                case .error(let message):
                    Text(message)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            // Automatic cancellation of async work tied to view lifecycle
            await viewModel.fetchCoupons()
        }
    }
}

// MARK: - Subviews

struct EmptyCouponContent: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("coupon")
                .resizable()
                .scaledToFit()
                .frame(width: 129, height: 90)
            
            VStack(spacing: 8) {
                Text("No Coupons Available")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text("All the available Coupons will be here")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }
}

struct CouponsListView: View {
    let coupons: [Coupon]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                // Ensure stable identity for dynamic content
                ForEach(coupons) { coupon in
                    Text(coupon.title)
                        .padding()
                }
            }
        }
    }
}