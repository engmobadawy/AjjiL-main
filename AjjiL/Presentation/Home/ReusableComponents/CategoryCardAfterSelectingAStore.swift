//
//  CategoryCardAfterSelectingAStore.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 19/02/2026.
//


import SwiftUI



struct CategoryCardAfterSelectingAStore: View {
    let title: String
    let imageName: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Image
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 168)
                .frame(maxWidth: .infinity)
                .background(Color.goodGray)
                .clipShape(.rect(cornerRadius: 28))
            
            // Extracted Label Subview
            CategoryLabel(title: title)
        }
    }
}

struct CategoryLabel: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom("Poppins-semibold", size: 16))
            .foregroundStyle(.white)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(
                            LinearGradient(
                                stops: [
                                    // 0% stop - 0% Opacity
                                    .init(color: Color(red: 5/255, green: 167/255, blue: 136/255).opacity(0), location: 0.0),
                                    // 52% stop - 78% Opacity
                                    .init(color: Color(red: 3/255, green: 98/255, blue: 80/255).opacity(0.78), location: 0.52),
                                    // 100% stop - 100% Opacity
                                    .init(color: Color(red: 2/255, green: 65/255, blue: 53/255), location: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            in: .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 28,
                                bottomTrailingRadius: 28,
                                topTrailingRadius: 0
                            )
                        )
    }
}


import SwiftUI

// Example Model
struct Categoryy: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

