//
//  CustomTabBar.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 16/02/2026.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications

struct TabBarView: View {
    @State private var tabRouter = TabRouter() // Use the new router
    @State private var tabVisibility = TabBarVisibility()
    @State private var tokenViewModel = TokenSubmitterViewModel()
    
    var body: some View {
        ZStack {
            // Content for selected tab
            TabView(selection: $tabRouter.selectedTab) { // Bind to router state
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
                            icon: tabRouter.selectedTab == 0 ? "greenStore" : "grayStore",
                            // 🛠️ FIX: Added .newlocalized
                            title: "Stores".newlocalized,
                            isSelected: tabRouter.selectedTab == 0,
                            keepOriginalColor: true // Prevents SwiftUI from tinting these specific icons
                        ) {
                            tabRouter.selectedTab = 0
                        }
                        
                        // Orders Tab
                        TabBarButton(
                            icon: "tabBarOrders",
                            // 🛠️ FIX: Added .newlocalized
                            title: "Orders".newlocalized,
                            isSelected: tabRouter.selectedTab == 1
                        ) {
                            tabRouter.selectedTab = 1
                        }
                        
                        // Home Tab (Center - Prominent)
                        Button(action: {
                            tabRouter.selectedTab = 2
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.0, green: 0.62, blue: 0.58))
                                    .frame(width: 70, height: 70)
                                
                                Image("tabBarHome")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.white)
                            }
                        }
                        .offset(y: -8)
                        .frame(maxWidth: .infinity)
                        
                        // Favorites Tab
                        TabBarButton(
                            icon: "tabBarLove",
                            // 🛠️ FIX: Added .newlocalized
                            title: "Favorites".newlocalized,
                            isSelected: tabRouter.selectedTab == 3
                        ) {
                            tabRouter.selectedTab = 3
                        }
                        
                        // Profile Tab
                        TabBarButton(
                            icon: "tabBarProfile",
                            // 🛠️ FIX: Added .newlocalized
                            title: "Profile".newlocalized,
                            isSelected: tabRouter.selectedTab == 4
                        ) {
                            tabRouter.selectedTab = 4
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .padding(.top, 12)
                    .background(Color.white)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .environment(tabVisibility)
        .environment(tabRouter) // Inject the router into the environment
        .task {
            await tokenViewModel.submitTokenIfNeeded()
        }
    }
}

@Observable
@MainActor
final class TokenSubmitterViewModel {
    private let submitTokenUseCase: SubmitTokenUseCase
    
    //
    init(submitTokenUseCase: SubmitTokenUseCase? = nil) {
        self.submitTokenUseCase = submitTokenUseCase ?? SubmitTokenUseCase(
            repository: NotificationRepositoryImpl(
                networkService: NetworkService()
            )
        )
    }
    
    func submitTokenIfNeeded() async {
        do {
            // 1. ASK FOR PERMISSION FIRST
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
            if !granted {
                print("⚠️ User denied notification permissions. We won't submit the token.")
                return
            }
            
            // ✅ FIX 2: Remove 'await' here since this is a synchronous UIKit method
            UIApplication.shared.registerForRemoteNotifications()
            
            // 2. Await the Firebase FCM Token safely
            let fcmToken = try await Messaging.messaging().token()
            
            // 3. Retrieve the unique Device ID
            guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
                print("⚠️ Could not retrieve device ID")
                return
            }
            
            // 4. Execute the network request
            let response = try await submitTokenUseCase.execute(token: fcmToken, deviceId: deviceId)
            
            if response.status == true {
                print("✅ Successfully submitted FCM token to backend!")
            } else {
                print("❌ Backend returned an error: \(response.message ?? "Unknown")")
            }
            
        } catch {
            print("❌ Failed to fetch or submit FCM token: \(error.localizedDescription)")
        }
    }
}

@Observable
@MainActor
final class TabRouter {
    var selectedTab: Int = 2 // Home is selected by default
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var keepOriginalColor: Bool = false // Allows specific icons to bypass template tinting
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(icon)
                    // Use original mode to keep the asset's exact colors if requested
                    .renderingMode(keepOriginalColor ? .original : .template)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .darkMainGreen: Color(red: 0.62, green: 0.66, blue: 0.66))
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(isSelected ? .darkMainGreen : Color(red: 0.62, green: 0.66, blue: 0.66))
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
