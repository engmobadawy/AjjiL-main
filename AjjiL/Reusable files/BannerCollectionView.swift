//
//  BannerCollectionView.swift
//  ElRaya
//
//  Created by mohamed mahmoud sobhy badawy on 25/01/2026.
//

import SwiftUI
import Kingfisher

struct BannerCollectionView: View {
    let banners: [HomeBannerDataEntity]

    // Active page
    @State private var selection: Int = 0

    // Note: Assuming these custom colors exist in your Assets
    private let activeDot = Color(.darkMainGreen)
    private let inactiveDot = Color(.lightMainGreen)
    
    var body: some View {
        VStack(spacing: 10) {
            if banners.isEmpty {
                ProgressView()
                    .frame(height: 160)
            } else {
                TabView(selection: $selection) {
                    // Note: If HomeBannerDataEntity has a unique 'id', consider
                    // using that instead of \.offset for more stable identity.
                    ForEach(Array(banners.enumerated()), id: \.offset) { index, banner in
                        OnBoardingCard(banner: banner)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 160)
                // Modern auto-scroll using Swift Concurrency
                .task(id: banners.count) {
                    // Only auto-slide if there's more than one banner
                    guard banners.count > 1 else { return }
                    
                    while !Task.isCancelled {
                        // Wait for 2 seconds
                        try? await Task.sleep(for: .seconds(2))
                        
                        // Update the active page with animation
                        withAnimation {
                            selection = (selection + 1) % banners.count
                        }
                    }
                }

                if banners.count > 1 {
                    PageIndicator(
                        count: banners.count,
                        index: selection,
                        activeColor: activeDot,
                        inactiveColor: inactiveDot
                    )
                    .padding(.bottom, 2)
                }
            }
        }
    }
}

private struct OnBoardingCard: View {
    let banner: HomeBannerDataEntity

    var body: some View {
        // FIXED: Replaced AsyncImage with Kingfisher
        KFImage(URL(string: banner.image))
            .placeholder {
                ProgressView()
            }
            .onFailureImage(UIImage(systemName: "photo")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal))
            .resizable()
            .scaledToFill()
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(.rect(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.secondary.opacity(0.18), lineWidth: 1)
            }
            .contentShape(.rect(cornerRadius: 20))
            .accessibilityLabel(Text("Banner image"))
    }
}

private struct PageIndicator: View {
    let count: Int
    let index: Int

    var activeColor: Color
    var inactiveColor: Color

    private let dotSize: CGFloat = 8
    private let spacing: CGFloat = 6

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(i == index ? activeColor : inactiveColor)
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .animation(.snappy(duration: 0.25), value: index)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(index + 1) of \(count)")
    }
}

// Working Preview using your model structure
#Preview {
    BannerCollectionView(
        banners: [
            HomeBannerDataEntity(id: 1, image: "https://via.placeholder.com/400x160/FF5733/FFFFFF?text=Banner+1"),
            HomeBannerDataEntity(id: 2, image: "https://via.placeholder.com/400x160/33FF57/FFFFFF?text=Banner+2"),
            HomeBannerDataEntity(id: 3, image: "https://via.placeholder.com/400x160/3357FF/FFFFFF?text=Banner+3")
        ]
    )
}
