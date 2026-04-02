//
//  ToastMessageSwiftUIView.swift
//  
//
//  Created by AMN on 3/8/23.
//  Copyright © 2023 AppsSquare.com. All rights reserved.
//

import SwiftUI
struct FancyToastView: View {
    var type: FancyToastStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Toast Icon based on type
                Image(systemName: type.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(type.themeColor.opacity(0.8))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)

                        .font(.headline)
                        .foregroundColor(.white)
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Dismiss Button
                Button(action: {
                    onCancelTapped()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
        }
        .background(type.themeColor.gradient)
        .cornerRadius(12)
        .shadow(color: type.themeColor.opacity(0.5), radius: 5, x: 0, y: 3)
        .padding(.horizontal, 16)
    }
}

enum FancyToastStyle {
    case error
    case warning
    case success
    case info
}

// MARK: - FancyToastStyle with Icons and Colors
extension FancyToastStyle {
    var themeColor: Color {
        switch self {
        case .error: return Color.red
        case .warning: return Color.orange
        case .info: return Color.blue
        case .success: return .green
        }
    }
    
    var iconName: String {
        switch self {
        case .error: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        }
    }
}

struct FancyToast: Equatable {
    var type: FancyToastStyle
    var title: String
    var message: String
    var duration: Double = 3
}

struct FancyToastView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
        FancyToastView(
            type: .error,
            title: "Error",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ") {}
        
        FancyToastView(
            type: .info,
            title: "Info",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ") {}
    }
  }
}

struct FancyToastModifier: ViewModifier {
    @Binding var toast: FancyToast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: -30)
                }.animation(.spring(), value: toast)
            )
            .onChange(of: toast) {
                showToast()
            }
    }
    
    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                Spacer()
                FancyToastView(
                    type: toast.type,
                    title: toast.title,
                    message: toast.message) {
                        dismissToast()
                    }
            }.padding(.bottom, 10)
            .transition(.move(edge: .bottom))
        }
    }
    
    private func showToast() {
        guard let toast = toast else { return }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
               dismissToast()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    func toastView(toast: Binding<FancyToast?>) -> some View {
        self.modifier(FancyToastModifier(toast: toast))
    }
}


import SwiftUI

enum SimpleToastStyle {
    case error
    case success
}

struct SimpleToastView: View {
    var style: SimpleToastStyle
    var message: String
    var onDismiss: (() -> Void)?

    var backgroundColor: Color {
        switch style {
        case .error: return .red
        case .success: return .green // Replace with .appPrimary if you have it
        }
    }

    var body: some View {
        HStack {
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            
        }
        .background(backgroundColor)
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .transition(.move(edge: .bottom))
    }
}

struct SimpleToast: Equatable {
    var style: SimpleToastStyle
    var message: String
    var duration: Double = 3
}

struct SimpleToastModifier: ViewModifier {
    @Binding var toast: SimpleToast?
    @State private var workItem: DispatchWorkItem?

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                VStack {
                    Spacer()
                    if let toast = toast {
                        SimpleToastView(style: toast.style, message: toast.message) {
                            dismissToast()
                        }
                        .padding(.bottom, 20)
                        .animation(.spring(), value: toast)
                        .transition(.move(edge: .bottom))
                    }
                }
            )
            .onChange(of: toast) { _,_ in
                showToast()
            }
    }

    private func showToast() {
        guard let toast = toast else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if toast.duration > 0 {
            workItem?.cancel()
            let task = DispatchWorkItem { dismissToast() }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }

    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    func simpleToast(toast: Binding<SimpleToast?>) -> some View {
        self.modifier(SimpleToastModifier(toast: toast))
    }
}
