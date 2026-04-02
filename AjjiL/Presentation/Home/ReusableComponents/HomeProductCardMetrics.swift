//
//  HomeProductCardMetrics.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 05/03/2026.
//



import SwiftUI

// MARK: - Metrics
private enum HomeProductCardMetrics {
    static let cardHeight: CGFloat = 312
    static let cornerRadius: CGFloat = 12
    static let contentHPadding: CGFloat = 8
    static let contentBottomPadding: CGFloat = 12
    static let imageHeight: CGFloat = 140
    static let actionButtonHeight: CGFloat = 36
    static let actionButtonCornerRadius: CGFloat = 8
    static let borderColor = Color(red: 0.91, green: 0.94, blue: 0.95)
}

struct HomeProductCard: View {
    // MARK: Properties
    let product: HomeFeaturedProductDataEntity
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onAddToCart: () -> Void
    let onScanToBuy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProductImageHeader(
                imageURL: product.imageURL,
                discount: product.discount,
                isFavorite: isFavorite,
                onToggleFavorite: onToggleFavorite
            )
            
            ProductInfoSection(product: product)
            
            ProductActionRow(
                onScanToBuy: onScanToBuy,
                onAddToCart: onAddToCart
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: HomeProductCardMetrics.cardHeight)
        .background(.white)
        .clipShape(.rect(cornerRadius: HomeProductCardMetrics.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: HomeProductCardMetrics.cornerRadius)
                .stroke(HomeProductCardMetrics.borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Subviews

private struct ProductInfoSection: View {
    let product: HomeFeaturedProductDataEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(product.category)
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundStyle(.lightMainGreen)
                .lineLimit(1)
                .padding(.bottom, 4)

            Text(product.name)
                .font(.custom("Poppins-Regular", size: 16))
                .lineLimit(1)
                .padding(.bottom, 6)

            brandRow

            priceRow
        }
        .padding(.top, 8)
        .padding(.horizontal, HomeProductCardMetrics.contentHPadding)
    }
    
    // MARK: - Extracted Subviews
    
    @ViewBuilder
    private var brandRow: some View {
        HStack(spacing: 8) {
            AsyncImage(url: URL(string: product.brandImage)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else if phase.error != nil {
                    // Fallback if the image fails to load or URL is invalid
                    Image(systemName: "storefront")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray.opacity(0.5))
                } else {
                    // Loading state
                    ProgressView()
                        .scaleEffect(0.6)
                }
            }
            .frame(width: 24, height: 24)
            .padding(4.5)
            .background(Color(red: 232/255, green: 239/255, blue: 243/255))
            .clipShape(.circle)
            
            Text(product.brand)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundStyle(Color(red: 0.19, green: 0.22, blue: 0.20))
                .lineLimit(1)
        }
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var priceRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            CurrencyAmount(
                amount: product.price,
                amountFont: .custom("Poppins-Medium", size: 14),
                amountColor: .orange,
                currencyAssetName: "OrangeVector",
                isStrikethrough: false
            )
            
            if product.originalPrice >= product.price {
                CurrencyAmount(
                    amount: product.originalPrice,
                    amountFont: .custom("Poppins-Regular", size: 10),
                    amountColor: .gray,
                    currencyAssetName: "GrayVector",
                    isStrikethrough: true
                )
            }
        }
        .padding(.bottom, 8)
    }
}


private struct ProductImageHeader: View {
    let imageURL: String
    let discount: String
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    /// Determines if the ribbon should be displayed based on string content
    private var isDiscountVisible: Bool {
        let cleaned = discount.trimmingCharacters(in: .whitespacesAndNewlines)
        return !cleaned.isEmpty && cleaned != "0" && cleaned != "0%"
    }
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Color.gray.opacity(0.1)
        }
        .frame(height: HomeProductCardMetrics.imageHeight)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .overlay(alignment: .topLeading) {
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.red.opacity(0.85))
                    .frame(width: 24, height: 24)
                    .contentShape(.rect)
                    .padding(8)
            }
            .buttonStyle(.plain)
            .padding(8)
        }
        .overlay(alignment: .topTrailing) {
            if isDiscountVisible {
                DiscountRibbon(text: discount)
            }
        }
    }
}



private struct ProductActionRow: View {
    // Read the toggle state directly from UserDefaults
    @AppStorage("isStoreMode") private var isStoreMode: Bool = false
    
    let onScanToBuy: () -> Void
    let onAddToCart: () -> Void
    
    // Brand colors extracted from your existing code
    private let darkGreen = Color(red: 0, green: 0.59, blue: 0.51)
    private let lightGreen = Color(red: 0.79, green: 0.93, blue: 0.85)
    
    var body: some View {
        Button {
            isStoreMode ? onAddToCart() : onScanToBuy()
        } label: {
            // Animate the spacing so the text slides smoothly into the center
            HStack(spacing: isStoreMode ? 8 : 0) {
                
                // Use modifiers instead of an 'if' block to maintain view identity
                Image(systemName: "cart.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: isStoreMode ? nil : 0)
                    .opacity(isStoreMode ? 1 : 0)
                    .clipped()
                
                Text(isStoreMode ? "Add to cart" : "Scan to buy")
                    .font(.custom("Poppins-SemiBold", size: 14))
                    // Modern API to smoothly crossfade the text value change
                    .contentTransition(.opacity)
            }
            .frame(maxWidth: .infinity)
            .frame(height: HomeProductCardMetrics.actionButtonHeight)
            .foregroundStyle(isStoreMode ? .white : darkGreen)
            .background(
                isStoreMode ? darkGreen : lightGreen,
                in: .rect(cornerRadius: HomeProductCardMetrics.actionButtonCornerRadius)
            )
        }
        // Attach a spring animation tied directly to the AppStorage value
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isStoreMode)
        .padding(.horizontal, HomeProductCardMetrics.contentHPadding)
        .padding(.bottom, HomeProductCardMetrics.contentBottomPadding)
    }
}

// MARK: - DiscountRibbon

private struct DiscountRibbon: View {
    let text: String

    private enum Metrics {
        static let angle: Angle = .degrees(45)
        static let ribbonWidth: CGFloat = 120
        static let ribbonHeight: CGFloat = 19
        static let containerSize: CGFloat = 86
        static let offset: CGFloat = 18
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.red)
                .frame(width: Metrics.ribbonWidth, height: Metrics.ribbonHeight)

            (Text("   ") + Text(text))
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .rotationEffect(Metrics.angle)
        .frame(width: Metrics.containerSize, height: Metrics.containerSize, alignment: .topTrailing)
        .offset(x: 24, y: Metrics.offset)
    }
}

// MARK: - CurrencyAmount

private struct CurrencyAmount: View {
    let amount: Double
    let amountFont: Font
    let amountColor: Color
    let currencyAssetName: String
    let isStrikethrough: Bool

    private enum Metrics {
        static let spacing: CGFloat = 4
        static let iconSize: CGFloat = 12
        static let strikeHeight: CGFloat = 1.0
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Metrics.spacing) {
            Text(amount.formatted(.number.precision(.fractionLength(1))))
                .font(amountFont)
                .foregroundStyle(amountColor)

            Image(currencyAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                .baselineOffset(-1)
        }
        .overlay(alignment: .center) {
            if isStrikethrough {
                Rectangle()
                    .fill(amountColor.opacity(0.8))
                    .frame(height: Metrics.strikeHeight)
            }
        }
    }
}
