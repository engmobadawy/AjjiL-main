import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications

struct TabBarView: View {
    @State private var tabRouter = TabRouter()
    @State private var tabVisibility = TabBarVisibility()
    @State private var tokenViewModel = TokenSubmitterViewModel()
    
    // Read the cashier state once when the TabBar initializes
    @State private var isCashier: Bool = GenericUserDefault.shared.getValue(Constants.shared.isCashier) as? Bool ?? false
    
    var body: some View {
        ZStack {
            // Content for selected tab
            TabView(selection: $tabRouter.selectedTab) {
                if isCashier {
                    // MARK: - Cashier Views
                    ScanCashier()
                        .tag(0)
                    
                    HistoryCashier()
                        .tag(1)
                    
                    HomeCashier()
                        .tag(2)
                    
                    OrderCashier()
                        .tag(3)
                    
                    MoreCashier()
                        .tag(4)
                } else {
                    // MARK: - User Views
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
            }
            
            if !tabVisibility.isHidden {
                // Custom Tab Bar
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        if isCashier {
                            // MARK: - Cashier Tab Bar Buttons
                            TabBarButton(
                                icon: "tabBarScan",
                                title: "Scan".newlocalized,
                                isSelected: tabRouter.selectedTab == 0
                            ) { tabRouter.selectedTab = 0 }
                            
                            TabBarButton(
                                icon: "tabBarHistory",
                                title: "History".newlocalized,
                                isSelected: tabRouter.selectedTab == 1
                            ) { tabRouter.selectedTab = 1 }
                            
                            centerHomeButton
                            
                            TabBarButton(
                                icon: "tabBarOrder",
                                title: "Order".newlocalized,
                                isSelected: tabRouter.selectedTab == 3
                            ) { tabRouter.selectedTab = 3 }
                            
                            TabBarButton(
                                icon: "tabBarMore",
                                title: "More".newlocalized,
                                isSelected: tabRouter.selectedTab == 4
                            ) { tabRouter.selectedTab = 4 }
                            
                        } else {
                            // MARK: - User Tab Bar Buttons
                            TabBarButton(
                                icon: tabRouter.selectedTab == 0 ? "greenStore" : "grayStore",
                                title: "Stores".newlocalized,
                                isSelected: tabRouter.selectedTab == 0,
                                keepOriginalColor: true
                            ) { tabRouter.selectedTab = 0 }
                            
                            TabBarButton(
                                icon: "tabBarOrders",
                                title: "Orders".newlocalized,
                                isSelected: tabRouter.selectedTab == 1
                            ) { tabRouter.selectedTab = 1 }
                            
                            centerHomeButton
                            
                            TabBarButton(
                                icon: "tabBarLove",
                                title: "Favorites".newlocalized,
                                isSelected: tabRouter.selectedTab == 3
                            ) { tabRouter.selectedTab = 3 }
                            
                            TabBarButton(
                                icon: "tabBarProfile",
                                title: "Profile".newlocalized,
                                isSelected: tabRouter.selectedTab == 4
                            ) { tabRouter.selectedTab = 4 }
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
        .environment(tabRouter)
        .task {
            await tokenViewModel.submitTokenIfNeeded()
        }
    }
    
    private var centerHomeButton: some View {
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
    }
}

// MARK: - Placeholder Cashier Views
struct ScanCashier: View { var body: some View { Text("Scan Cashier").font(.largeTitle) } }
struct HistoryCashier: View { var body: some View { Text("History Cashier").font(.largeTitle) } }
struct HomeCashier: View { var body: some View { Text("Home Cashier").font(.largeTitle) } }
struct OrderCashier: View { var body: some View { Text("Order Cashier").font(.largeTitle) } }
struct MoreCashier: View { var body: some View { Text("More Cashier").font(.largeTitle) } }

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
