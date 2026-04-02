//
//  ShimmerViewModifier.swift
//  lifeCare
//
//  Created by AMNY on 24/08/2025.
//


import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var moveTo: CGFloat = -1.0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    let size = geo.size
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.28),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    // The shimmer band covers the whole view and slides diagonally
                    .frame(width: size.width * 2, height: size.height * 2)
                    .rotationEffect(.degrees(15))
                    .offset(
                        x: moveTo * size.width,
                        y: moveTo * size.height
                    )
                    .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: moveTo)
                    .blendMode(.plusLighter)
                }
                .clipped()
                .allowsHitTesting(false)
            )
            .onAppear {
                moveTo = 1.0
            }
    }
}

import SwiftUI

extension View {
    func shimmer(active: Bool) -> some View {
        Group {
            if active {
                self.modifier(ShimmerModifier())
            } else {
                self
            }
        }
    }
}
