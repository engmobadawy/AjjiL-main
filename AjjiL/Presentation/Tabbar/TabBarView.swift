//
//  CustomTabBar.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 16/02/2026.
//


import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 2 // Home is selected by default
    @State private var tabVisibility = TabBarVisibility()
    var body: some View {
        ZStack {
            // Content for selected tab
            TabView(selection: $selectedTab) {
                StoresView()
                    .tag(0)
                
                OrdersView()
                    .tag(1)
                
                HomeView()
                    .tag(2)
                
                FavoritesView()
                    .tag(3)
                
                ProfileView()
                    .tag(4)
            }
            if !tabVisibility.isHidden {
                // Custom Tab Bar
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        // Stores Tab
                        TabBarButton(
                            icon: "tabBarStoresGray",
                            title: "Stores",
                            isSelected: selectedTab == 0
                        ) {
                            selectedTab = 0
                        }
                        
                        // Orders Tab
                        TabBarButton(
                            icon: "tabBarOrders",
                            title: "Orders",
                            isSelected: selectedTab == 1
                        ) {
                            selectedTab = 1
                        }
                        
                        // Home Tab (Center - Prominent)
                        Button(action: {
                            selectedTab = 2
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.0, green: 0.62, blue: 0.58))
                                    .frame(width: 70, height: 70)
                                
                                Image("tabBarHome")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }
                        .offset(y: -8)
                        .frame(maxWidth: .infinity)
                        
                        // Favorites Tab
                        TabBarButton(
                            icon: "tabBarLove",
                            title: "Favorites",
                            isSelected: selectedTab == 3
                        ) {
                            selectedTab = 3
                        }
                        
                        // Profile Tab
                        TabBarButton(
                            icon: "tabBarProfile",
                            title: "Profile",
                            isSelected: selectedTab == 4
                        ) {
                            selectedTab = 4
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .padding(.top, 12)
                    .background(Color.white)
                }.ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }.environment(tabVisibility)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(icon)
                    .renderingMode(.template)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .darkMainGreen: Color(red: 0.62, green: 0.66, blue: 0.66))
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .darkMainGreen : Color(red: 0.62, green: 0.66, blue: 0.66))
            }
        }
        .frame(maxWidth: .infinity)
    }
}


struct StoresView: View {
    var body: some View {
        Text("Stores")
            .font(.largeTitle)
    }
}




@Observable
@MainActor
final class TabBarVisibility {
    var isHidden: Bool = false
}



#Preview {
    TabBarView()
}
