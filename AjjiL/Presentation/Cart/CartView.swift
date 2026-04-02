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
