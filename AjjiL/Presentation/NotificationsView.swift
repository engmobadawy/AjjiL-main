//
//  NotificationView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/03/2026.
//

import SwiftUI


struct NotificationsView: View {
    @State private var viewModel: NotificationsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(useCase: GetNotificationsUseCase) {
        _viewModel = State(initialValue: NotificationsViewModel(getNotificationsUseCase: useCase))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Using your existing top row component
            TopRowNotForHome(
                title: "Notifications".newlocalized,
                showBackButton: true,
                kindOfTopRow: .none,
                onBack: { dismiss() }
            )
            
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                Spacer()
                // 🛠️ FIX: Added .newlocalized
                ProgressView("Loading notifications...".newlocalized)
                Spacer()
            }
            
                else if let errorMessage = viewModel.errorMessage {
                Spacer()
                Text(errorMessage)
                    .foregroundStyle(.red)
                Spacer()
            } else if viewModel.notifications.isEmpty {
                emptyStateView
            } else {
                notificationsList
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadNotifications()
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
        private var emptyStateView: some View {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "bell.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(.tertiary)
                
                // 🛠️ FIX: Added .newlocalized
                Text("No notifications yet".newlocalized)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    
    @ViewBuilder
    private var notificationsList: some View {
        ScrollView {
            // LazyVStack for optimal list performance
            LazyVStack(spacing: 0) {
                ForEach(viewModel.notifications) { notification in
                    Button {
                        viewModel.handleNotificationTap(notification)
                    } label: {
                        NotificationRowView(notification: notification)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
        .refreshable {
            await viewModel.loadNotifications()
        }
    }
}

// Extracted subview for the empty state
struct EmptyNotificationView: View {
    var body: some View {
        VStack {
            Image("noNatificationCompleted")
                .resizable()
                .scaledToFit()
                .frame(width: 226, height: 228)
                .padding(.top, 240)
            
            Spacer()
        }
    }
}






struct NotificationRowView: View {
    let notification: NotificationDTO
    
    // Soft green color matching the screenshot's icon
    private let iconColor = Color(red: 168/255, green: 220/255, blue: 198/255)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Checkmark Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)
                    .padding(.top, 2)
                
                // Text Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(notification.title ?? "Notification".newlocalized)
                        .font(.custom("Poppins-SemiBold", size: 16, relativeTo: .headline))
                        .foregroundStyle(Color.primary.opacity(0.8))
                    
                    Text(notification.body ?? "")
                        .font(.custom("Poppins-Regular", size: 14, relativeTo: .subheadline))
                        .foregroundStyle(Color.secondary.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true) // Prevents truncation bugs
                    
                    Text(notification.createdAt ?? "")
                        .font(.custom("Poppins-Regular", size: 12, relativeTo: .caption))
//                        .foregroundStyle(Color.tertiary)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle()) // Ensures the whole row is tappable
            
            // Subtle Divider under each item
            Divider()
                .padding(.horizontal, 20)
        }
    }
}

import SwiftUI

@MainActor
@Observable
class NotificationsViewModel {
    // Dependencies
    private let getNotificationsUseCase: GetNotificationsUseCase
    
    // View State (Private setters to enforce unidirectional data flow)
    private(set) var notifications: [NotificationDTO] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil
    
    init(getNotificationsUseCase: GetNotificationsUseCase) {
        self.getNotificationsUseCase = getNotificationsUseCase
    }
    
    func loadNotifications() async {
        // Prevent redundant network calls if already loading
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            notifications = try await getNotificationsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func handleNotificationTap(_ notification: NotificationDTO) {
        // Matching your Android click logic based on type
        switch notification.type {
        case 1:
            print("Navigate: Order Completed for value \(notification.value ?? 0)")
        case 2:
            print("Navigate: Store details")
        case 3:
            print("Navigate: Offers screen")
        default:
            print("Unknown Type")
        }
    }
}
