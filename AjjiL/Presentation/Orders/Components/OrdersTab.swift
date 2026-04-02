//
//  OrdersTab.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 24/03/2026.
//


import SwiftUI

// MARK: - Models

// 1. Renamed to OrdersTab to avoid conflicts with StoreTab
enum OrdersTab: String, Hashable, CaseIterable {
    case currentOrders = "Current Orders"
    case history = "History"
}

// MARK: - Subviews

// 2. Renamed to OrdersTabBar to avoid conflicts with StoreTabBar
struct OrdersTabBar: View {
    @Binding var selectedTab: OrdersTab
    
    // Original colors preserved
    private let tealGreen = Color(red: 0.25, green: 0.62, blue: 0.54)
    private let vibrantOrange = Color(red: 0.95, green: 0.55, blue: 0.24)
    private let topBgColor = Color(red: 0.94, green: 0.95, blue: 0.96)
    
    var body: some View {
        HStack(spacing: 35) {
            ForEach(OrdersTab.allCases, id: \.self) { tab in
                Button {
                    // Added animation for a premium feel when switching tabs
                    withAnimation(.snappy) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .bold : .semibold)
                            .foregroundStyle(selectedTab == tab ? tealGreen : .secondary)
                            .padding(.bottom, 8)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? vibrantOrange : Color.clear)
                            .frame(height: 3)
                            .clipShape(.rect(cornerRadius: 1.5))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(topBgColor)
    }
}