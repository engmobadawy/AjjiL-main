//
//  AllStores.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 19/02/2026.
//

//
//  FeaturedProductsView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 18/02/2026.
//


import SwiftUI

struct AllStoresView: View {
    private enum StateViewEnum {
        case empty
        case notEmpty
    }
    
    // Using simple @State for view-local state
    @State private var stateView: StateViewEnum = .notEmpty
    
    let categories: [Category] = [
        .init(name: "All"),
        .init(name: "Vegetables"),
        .init(name: "Fruits"),
        .init(name: "Personal Care"),
        .init(name: "Stationery"),
        .init(name: "Baby Care"),
        .init(name: "Detergent & Care")
    ]
    
    @State private var selectedCategoryID: UUID?
    @State private var search = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header (Excluded from white background)
            TopRowNotForHome(
                title: "All Stores",
                showBackButton: true,
                cartCount: 3,
//                notificationCount: 12,
                kindOfTopRow: .withCartAndNotification,
                onBack: { print("Back") },
                onCart: { print("Cart") },
                onNotification: { print("Notifications") }
            )
           
            
       
            VStack(spacing: 18) {
                
                SearchBarButton(text: $search, placeholder: "hey from search bar", onSubmit: { })
                    .padding(.top, 18)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories) { category in
                            CategoryRowFilterationCard(
                                category: category,
                                isSelected: category.id == selectedCategoryID,
                                action: {
                                    selectedCategoryID = category.id
                                }
                            )
                        }
                    }
                
                } .padding(.top, -6)
                
                ScrollView {
                    VStack {
                        switch stateView {
                        case .empty:
                            emptyStateView
                        case .notEmpty:
                            notEmptyStateView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
               
                    .padding(.bottom, 18)
                }
            }.padding(.horizontal , 18)
            .background(.white)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(alignment: .center, spacing: 28) {
            Image("NoResult")
                .resizable()
                .frame(width: 168, height: 168)
            
            Text("NO Result for now")
                .font(.custom("Poppins-SemiBold", size: 28))
        }
        .padding(.top, 124)
    }
    
    @ViewBuilder
    private var notEmptyStateView: some View {
        VStack(spacing :12 ) {
           
            ForEach(0..<5, id: \.self) { _ in
                RowCardOfStoresView(
                    logoName: "car",
                    title: "EL-MAGED",
                    count: 243,
                    isStarred: true
                )
            }
        }
    }
}



#Preview {
    AllStoresView()
}




