////
////  FeaturedProductsView.swift
////  AjjiL
////
////  Created by mohamed mahmoud sobhy badawy on 18/02/2026.
////
//
//
//import SwiftUI
//
//struct FeaturedProductsView: View {
//    
//    @State private var isFavorite = false
//
//  
//    
//    private enum StateViewEnum {
//        case empty
//        case notEmpty
//    }
//    
//    // Using simple @State for view-local state
//    @State private var stateView: StateViewEnum = .notEmpty
//    
//    let categories: [Category] = [
//        .init(name: "All"),
//        .init(name: "Vegetables"),
//        .init(name: "Fruits"),
//        .init(name: "Personal Care"),
//        .init(name: "Stationery"),
//        .init(name: "Baby Care"),
//        .init(name: "Detergent & Care")
//    ]
//    
//    @State private var selectedCategoryID: UUID?
//    @State private var search = ""
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            
//            // MARK: - Header
//            TopRowNotForHome(
//                title: "Featured Products",
//                showBackButton: true,
//                cartCount: 3,
//                notificationCount: 12,
//                kindOfTopRow: .withCartAndNotification,
//                onBack: { print("Back") },
//                onCart: { print("Cart") },
//                onNotification: { print("Notifications") }
//            )
//           
//            
//       
//            VStack(spacing: 18) {
//                
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(categories) { category in
//                            CategoryRowFilterationCard(
//                                category: category,
//                                isSelected: category.id == selectedCategoryID,
//                                action: {
//                                    selectedCategoryID = category.id
//                                }
//                            )
//                        }
//                    }
//                    .padding(.horizontal)
//                }  .padding(.top, 18)
//                
//                ScrollView {
//                    VStack {
//                        switch stateView {
//                        case .empty:
//                            emptyStateView
//                        case .notEmpty:
//                            notEmptyStateView
//                        }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .padding(.horizontal, 18)
//                    .padding(.bottom, 18)
//                }
//            }
//
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//    
//    // MARK: - Subviews
//    
//    @ViewBuilder
//    private var emptyStateView: some View {
//        VStack(alignment: .center, spacing: 28) {
//            Image("NoResult")
//                .resizable()
//                .frame(width: 168, height: 168)
//            
//            Text("No Featured Products for now")
//                .font(.custom("Poppins-SemiBold", size: 28))
//        }
//        .padding(.top, 124)
//    }
//    
//    @ViewBuilder
//    private var notEmptyStateView: some View {
//        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()),], spacing: 16) {
//            ForEach(0..<15, id: \.self) { _ in
//                HomeProductCard(
//                    product: product,
//                    isFavorite: $isFavorite,
//                    onAddToCart: { print("Add to cart tapped") },
//                    onScanToBuy: {
//                        print("Scan to buy tapped")
//                    }
//                )
//            }
//        }
//    }
//}
//
//#Preview {
//    FeaturedProductsView()
//}
