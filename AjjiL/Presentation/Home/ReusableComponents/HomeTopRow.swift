//
//  HeaderRow.swift
//  AjjiL
//

import SwiftUI

struct HomeTopRow: View {
    
    // Action handler for the bell
    var onNotification: (() -> Void)? = nil
    
    // State Management
    @State private var viewModel = NotificationBadgeViewModel()
    @State private var showGuestLoginSheet: Bool = false
    @State private var navigateToNotifications: Bool = false
    
    // 1. Add local state for the username
    @State private var username: String = "AJJil User".newlocalized
    
    var body: some View {
        HStack(alignment: .center) {
            // MARK: - Welcome Text & Emoji
            VStack(alignment: .leading, spacing: 0) {
                Text("Welcome!".newlocalized)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    // 2. Use the state variable
                    Text(username)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.primary)
                    
                    Text("👋")
                        .font(.system(size: 22))
                }
            }
            
            Spacer()
            
            // Wrapped the bell in a Button to handle taps
            Button {
                handleNotificationTap()
            } label: {
                NotificationBell(count: viewModel.unreadCount)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background {
            // 1. Create a rigid, invisible box that ignores the top safe area
            Color.clear
                .overlay {
                    // 2. Put the image inside the box and let it fill that exact space
                    Image("background")
                        .resizable()
                        .scaledToFill()
                }
                // 3. Strictly clip anything that escapes the clear box
                .clipped()
                // 4. Push the clear box up into the notch/status bar area
                .ignoresSafeArea(edges: .top)
        }
        .sheet(isPresented: $showGuestLoginSheet) {
            GuestLoginSheetView() // Replace with your actual view if different
                .presentationDetents([.fraction(0.5), .medium])
                .presentationDragIndicator(.visible)
                .background(.white)
        }
        .navigationDestination(isPresented: $navigateToNotifications) {
            let networkService = NetworkService()
            let repository = NotificationRepositoryImpl(networkService: networkService)
            let useCase = GetNotificationsUseCase(repository: repository)
            
            NotificationsView(useCase: useCase)
        }
        .task {
            // 3. Fetch both the unread count and the username concurrently
            await viewModel.fetchUnreadCount()
            await fetchUserName()
        }
        .onChange(of: navigateToNotifications) { oldValue, newValue in
            // Refresh count when returning from the Notifications view
            if newValue == false {
                Task {
                    await viewModel.fetchUnreadCount()
                }
            }
        }
    }
    
    // MARK: - Actions
    private func handleNotificationTap() {
        if Constants.isGuestMode {
            showGuestLoginSheet = true
        } else {
            navigateToNotifications = true
            onNotification?()
        }
    }
    
    // MARK: - Data Fetching
    private func fetchUserName() async {
        let token = GenericUserDefault.shared.getValue(Constants.shared.token) as? String ?? ""
        
        // Bail out early if guest mode or no token is found
        guard !token.isEmpty, !Constants.isGuestMode else { return }
        
        // Initialize the use case just like in ProfileView
        let networkService = NetworkService()
        let repository = ProfileRepositoryImp(networkService: networkService)
        let getProfileUC = GetProfileUC(repo: repository)
        
        do {
            let profile = try await getProfileUC.execute()
            // Safely update the state on the MainActor
            await MainActor.run {
                self.username = profile.name
            }
        } catch {
            print("❌ Failed to fetch user name for HomeTopRow: \(error)")
            // It fails silently for the UI and keeps the default "AJJil User" text
        }
    }
}

// MARK: - Subviews
struct NotificationBell: View {
    let count: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(Color(red: 214/255, green: 255/255, blue: 248/255))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: "bell.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.black)
                        .offset(x: -3, y: 5)
                }

            Text(count < 99 ? count.formatted() : "99")
                .font(count < 99 ? .system(size: 7, weight: .bold, design: .default) : .caption2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 14, height: 14)
                .background(.orange, in: .circle)
                .offset(x: -8, y: 5)
                // Ensures the badge stays hidden if there are 0 notifications
//                .opacity(count > 0 ? 1 : 0)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        VStack {
            HomeTopRow()
            Spacer()
        }
    }
}
