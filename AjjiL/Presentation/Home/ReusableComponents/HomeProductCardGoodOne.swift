////
////  HomeProductCard.swift
////  AjjiL
////
////  Created by mohamed mahmoud sobhy badawy on 19/02/2026.
////
//
//import SwiftUI
//
//// MARK: - HomeProductCard
//
//struct HomeProductCard: View {
//
//    // MARK: Properties
//
//    let product: Product
//    @Binding var isFavorite: Bool
//    var onAddToCart: () -> Void
//    var onScanToBuy: () -> Void
//
//    // MARK: Layout Constants
//
//    private enum Metrics {
////        static let cardWidth: CGFloat = 197
//        static let cardHeight: CGFloat = 312
//        static let cornerRadius: CGFloat = 12
//        static let contentHPadding: CGFloat = 8
//        static let contentBottomPadding: CGFloat = 12
//        static let imageHeight: CGFloat = 140
//        static let actionButtonHeight: CGFloat = 36
//        static let actionRowWidth: CGFloat = 181
//        static let scanButtonWidth: CGFloat = 133
//        static let cartButtonWidth: CGFloat = 42
//        static let actionButtonCornerRadius: CGFloat = 8
//        static let borderColor = Color(red: 0.91, green: 0.94, blue: 0.95)
//    }
//
//    // MARK: Body
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            imageHeader
//            infoSection
//            actionRow
//        }
//        .frame(maxWidth:.infinity)
//        .frame(height:Metrics.cardHeight)
//        .background(.white, in: RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous))
//        .overlay {
//            RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous)
//                .stroke(Metrics.borderColor, lineWidth: 1)
//        }
//        .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous))
//    }
//}
//
//// MARK: - Subviews
//
//private extension HomeProductCard {
//
//    // MARK: Image Header
//
//    var imageHeader: some View {
//        productImage
//            .overlay(alignment: .topLeading) {
//                favoriteButton
//                    .padding(8)
//            }
//            .overlay(alignment: .topTrailing) {
//                DiscountRibbon(text: product.discount)
//            }
//    }
//
//    var productImage: some View {
//        ZStack {
//            Color.white
//            Image(product.imageName)
//                .resizable()
//                .scaledToFit()
//                .frame(height: Metrics.imageHeight)
//                .padding(.horizontal, 8)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: Metrics.imageHeight)
//        .clipped()
//    }
//
//    // MARK: Info Section
//
//    var infoSection: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            Text(product.category)
//                .font(.custom("Poppins-Medium", size: 12))
//                .foregroundStyle(.lightMainGreen)
//                .lineLimit(1)
//                .padding(.bottom, 4)
//
//            Text(product.name)
//                .font(.custom("Poppins-Regular", size: 16))
//                .lineLimit(1)
//                .padding(.bottom, 6)
//
//            brandRow
//            priceRow
//        }
//        .padding(.top, 8)
//        .padding(.horizontal, Metrics.contentHPadding)
//    }
//
//    var brandRow: some View {
//        HStack(spacing: 6) {
//            StorescardVeiw(image: "Stores3", size: 24, imagePadding: 0)
//
//            Text(product.brand)
//                .font(.custom("Poppins-Regular", size: 14))
//                .foregroundStyle(Color(red: 0.19, green: 0.22, blue: 0.20))
//                .lineLimit(1)
//        }
//        .padding(.bottom, 8)
//    }
//
//    var priceRow: some View {
//        HStack(alignment: .firstTextBaseline, spacing: 8) {
//            CurrencyAmount(
//                amount: product.price,
//                amountFont: .custom("Poppins-Medium", size: 14),
//                amountColor: Color(red: 1, green: 0.47, blue: 0),
//                currencyAssetName: "OrangeVector",
//                isStrikethrough: false
//            )
//            CurrencyAmount(
//                amount: product.originalPrice,
//                amountFont: .custom("Poppins-Regular", size: 10),
//                amountColor: Color(red: 0.44, green: 0.44, blue: 0.44),
//                currencyAssetName: "GrayVector",
//                isStrikethrough: true
//            )
//        }
//        .padding(.bottom, 8)
//    }
//
//    // MARK: Action Row
//
//    var actionRow: some View {
//        HStack(alignment: .top, spacing: 6) {
//            scanToBuyButton
//            cartButton
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//           .padding(.horizontal, Metrics.contentHPadding)
//           .padding(.bottom, Metrics.contentBottomPadding)
//    }
//
//    var scanToBuyButton: some View {
//        Button(action: onScanToBuy) {
//            Text("Scan to buy")
//                .font(.custom("Poppins-SemiBold", size: 14))
//                .foregroundStyle(Color(red: 0, green: 0.59, blue: 0.51))
//                .frame(height: Metrics.actionButtonHeight)
//                .frame(maxWidth: .infinity)
//                .background(
//                    Color(red: 0.79, green: 0.93, blue: 0.85),
//                    in: RoundedRectangle(cornerRadius: Metrics.actionButtonCornerRadius, style: .continuous)
//                )
//        }
//        .buttonStyle(.plain)
//    }
//
//    var cartButton: some View {
//        Button(action: onAddToCart) {
//            Image(systemName: "cart.badge.plus")
//                .font(.system(size: 16, weight: .semibold))
//                .foregroundStyle(.white)
//                .frame(width: Metrics.cartButtonWidth, height: Metrics.actionButtonHeight)
//                .background(
//                    Color(red: 0, green: 0.59, blue: 0.51),
//                    in: RoundedRectangle(cornerRadius: Metrics.actionButtonCornerRadius, style: .continuous)
//                )
//        }
//        .buttonStyle(.plain)
//        .accessibilityLabel("Add to cart")
//    }
//
//    // MARK: Favorite Button
//
//    var favoriteButton: some View {
//        Button {
//            isFavorite.toggle()
//        } label: {
//            Image(systemName: isFavorite ? "heart.fill" : "heart")
//                .font(.system(size: 20, weight: .semibold))
//                .foregroundStyle(Color.red.opacity(0.85))
//                .frame(width: 24, height: 24)
//                .contentShape(Rectangle())
//                .padding(8)
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - DiscountRibbon
//
//private struct DiscountRibbon: View {
//
//    let text: String
//
//    private enum Metrics {
//        static let angle: Angle = .degrees(45)
//        static let ribbonWidth: CGFloat = 120
//        static let ribbonHeight: CGFloat = 19
//        static let containerSize: CGFloat = 86
//        static let offset: CGFloat = 18
//    }
//
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(Color.red)
//                .frame(width: Metrics.ribbonWidth, height: Metrics.ribbonHeight)
//
//            (Text("   ") + Text(text))
//                .font(.system(size: 18, weight: .heavy))
//                .foregroundStyle(.white)
//                .lineLimit(1)
//                .minimumScaleFactor(0.8)
//        }
//        .rotationEffect(Metrics.angle)
//        .frame(width: Metrics.containerSize, height: Metrics.containerSize, alignment: .topTrailing)
//        .offset(x: 24, y: Metrics.offset)
//    }
//}
//
//// MARK: - CurrencyAmount
//
//private struct CurrencyAmount: View {
//
//    let amount: Double
//    let amountFont: Font
//    let amountColor: Color
//    let currencyAssetName: String
//    let isStrikethrough: Bool
//
//    private enum Metrics {
//        static let spacing: CGFloat = 4
//        static let iconSize: CGFloat = 12
//        static let strikeHeight: CGFloat = 1.0
//    }
//
//    var body: some View {
//        HStack(alignment: .firstTextBaseline, spacing: Metrics.spacing) {
//            Text(amount.formatted(.number.precision(.fractionLength(1))))
//                .font(amountFont)
//                .foregroundStyle(amountColor)
//
//            Image(currencyAssetName)
//                .resizable()
//                .scaledToFit()
//                .frame(width: Metrics.iconSize, height: Metrics.iconSize)
//                .baselineOffset(-1)
//        }
//        .overlay(alignment: .center) {
//            if isStrikethrough {
//                Rectangle()
//                    .fill(amountColor.opacity(0.8))
//                    .frame(height: Metrics.strikeHeight)
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview("HomeProductCardd") {
//    struct PreviewHost: View {
//        
//        @State private var isFavorite = false
//
//        private let product = Product(
//            category: "Groceries",
//            name: "Fresh Apples",
//            brand: "ElRaya",
//            price: 24.5,
//            originalPrice: 30.0,
//            discount: "20%",
//            imageName: "Item"
//        )
//
//        var body: some View {
//            ZStack {
//                Color(.systemGroupedBackground).ignoresSafeArea()
//                HomeProductCard(
//                    product: product,
//                    isFavorite: $isFavorite,
//                    onAddToCart: { print("Add to cart tapped") }
//                    ,onScanToBuy: {
//                        print("Scan to buy tapped")
//                        
//                    }
//                    
//                )
//                .padding(24)
//            }
//        }
//    }
//
//    return PreviewHost()
//}
