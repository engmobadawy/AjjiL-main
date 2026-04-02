//
//  CategoryRowFilterationCard.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 19/02/2026.
//


import SwiftUI
struct CategoryRowFilterationCard: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.name)
                .font(.custom("Poppins-Medium", size: 14))
                .lineLimit(1)
                .frame(maxWidth: 170, idealHeight: 44)
                .padding(.horizontal, 8)
                .padding(.vertical, 18)
                .foregroundStyle(isSelected ? .white : Color(red: 134/255, green: 134/255, blue: 134/255))
                .background(isSelected ? Color.orange : Color.goodGray)
                .clipShape(.rect(cornerRadius: 8))
                .animation(.snappy, value: isSelected)
        }
        .buttonStyle(.plain)
    }
}