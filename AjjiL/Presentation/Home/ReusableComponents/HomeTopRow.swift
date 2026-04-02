//
//  HeaderRow.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/02/2026.
//


import SwiftUI

struct HomeTopRow: View {
    
    let username: String = "AJJil User"
    let notificationCount: Int = 9
    
    var body: some View {
        HStack(alignment: .center) {
            // MARK: - Welcome Text & Emoji
            VStack(alignment: .leading, spacing: 0) {
                Text("Welcome!")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    Text(username)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.primary)
                    
                    Text("👋")
                        .font(.system(size: 22))
                }
            }
            
            Spacer()
            
            
            NotificationBell(count: notificationCount)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
//        .background(Image("background"))
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
