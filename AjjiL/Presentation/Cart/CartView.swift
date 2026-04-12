//
//  CartView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/03/2026.
//

import SwiftUI

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack{
            TopRowNotForHome(title: "EL-MAGED - Cart", showBackButton: true, kindOfTopRow: .justNotification , onBack: {dismiss()})
            ScrollView{
                
                VStack {
                    // Example of the card in a list context
                    CartItemCardView(
                        item: CartItemCartItemForCartView(
                            imageName: "car", // Replace with your actual asset name
                            category: "Detergent & Care",
                            title: "Liquid Laundry",
                            price: 102.9,
                            quantity: 2
                        ),
                        onDelete: {
                            print("Delete item triggered")
                        }
                    )
                    .padding()
                    
                    Spacer()
                }

                
                Image("NoOrders")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 189, height: 176)
                    .padding(.top, 228)
                
            }
            
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CartView()
}
