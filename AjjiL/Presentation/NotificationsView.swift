//
//  NotificationView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/03/2026.
//

import SwiftUI

struct NotificationView: View {
    // Internal view state to track your notifications
    @State private var notifications: [String] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "Notifications",
                showBackButton: true,
                kindOfTopRow: .none,
                onBack: {
                    dismiss()
                }
            )
            
            // Content Area
            Group {
                if notifications.isEmpty {
                    EmptyNotificationView()
                } else {
                    // Your future list of notifications goes here
                    ScrollView {
                        VStack {
                            Text("Hello, NotificationView!")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

#Preview {
    NotificationView()
}
