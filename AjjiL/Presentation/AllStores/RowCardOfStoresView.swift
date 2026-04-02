//
//  OrganizationCardView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 19/02/2026.
//


import SwiftUI

struct RowCardOfStoresView: View {
    let logoName: String
    let title: String
    let count: Int
    let isStarred: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Logo Section
            Image(logoName)
                .resizable()
                .scaledToFit()
                .padding(12)
                .frame(width: 68, height: 68)
                .background(Color(red: 232/255, green: 239/255, blue: 243/255))
                .clipShape(.circle)
            
        
            HStack(alignment: .center, spacing: 6) {
                Text(title)
                    .font(.custom("Poppins-Regular", size: 20))
                 
                
                Text("(\(count.formatted()))")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                
                if isStarred {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                        .font(.system(size: 16))
                }
            }
            
                        Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
  
        .frame(height: 104) 
        .background(.white)
    
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(UIColor.opaqueSeparator), lineWidth: 1)
        }
    }
}


#Preview {
    RowCardOfStoresView(
        logoName: "car",
        title: "EL-MAGED",
        count: 243,
        isStarred: true
    )
    .padding()
}
