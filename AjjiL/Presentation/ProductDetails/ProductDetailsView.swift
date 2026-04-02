import SwiftUI

struct ProductDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // The view owns the ViewModel using @State, per modern @Observable guidelines
    @State private var viewModel: ProductDetailsViewModel

    init(product: HomeFeaturedProductDataEntity, isFavorite: Bool, onToggleFavorite: @escaping () -> Void) {
        // Initialize the State-wrapped ViewModel
        self._viewModel = State(initialValue: ProductDetailsViewModel(
            product: product,
            isFavorite: isFavorite,
            onToggleFavorite: onToggleFavorite
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "Details",
                showBackButton: true,
                kindOfTopRow: .withCartAndNotification,
                onBack: { dismiss() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // We pass only the necessary properties to subviews to prevent over-invalidation
                    ProductDetailsImageHeader(
                        imageURL: viewModel.product.imageURL,
                        discount: viewModel.product.discount,
                        isFavorite: viewModel.isFavorite,
                        onToggleFavorite: {
                            withAnimation(.snappy) {
                                viewModel.toggleFavorite()
                            }
                        }
                    )
                    
                    ProductDetailsInfoSection(product: viewModel.product)
                    
                    ProductDetailsDescriptionSection(points: viewModel.descriptionPoints)
                    
                    ProductDetailsBarcodeSection(barcode: viewModel.product.barcode)
                    
                    GreenButton(title: "Scan to buy") {
                        viewModel.scanToBuy()
                    }
                    .padding(.horizontal, 18)
                }
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .background(.white)
    }
}

// MARK: - Subviews
// (Subviews remain pure and stateless, taking only the data they need)

private struct ProductDetailsImageHeader: View {
    let imageURL: String
    let discount: String
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .top) {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Top Overlays
                HStack(alignment: .top) {
                    // Favorite Button
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Color(red: 0.9, green: 0.3, blue: 0.3))
                            .padding(20)
                    }
                    
                    Spacer()
                    
                    // Diagonal Ribbon
                    if !discount.isEmpty && discount != "0" {
                        ProductDetailRibbon(text: "\(discount)% OFF")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
            
            // Single Thumbnail (Leading Aligned)
            HStack {
                ThumbnailView(
                    imageURL: imageURL,
                    isSelected: true
                )
                .padding(.leading, 8)
                
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .frame(height: 321)
    }
}

private struct ThumbnailView: View {
    let imageURL: String
    let isSelected: Bool
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Color.gray.opacity(0.1)
        }
        .frame(width: 56, height: 56)
        .padding(6)
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? Color(red: 0.1, green: 0.6, blue: 0.5) : .gray.opacity(0.2),
                    lineWidth: isSelected ? 1.5 : 1
                )
        }
    }
}

private struct ProductDetailsInfoSection: View {
    let product: HomeFeaturedProductDataEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(product.category)
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundStyle(Color(red: 0.1, green: 0.7, blue: 0.5))
            
            Text(product.name)
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundStyle(.black)
            
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: product.brandImage)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Circle().fill(.gray.opacity(0.1))
                }
                .frame(width: 28, height: 28)
                .clipShape(.circle)
                
                Text(product.brand)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundStyle(.gray)
            }
            .padding(.bottom, 6)
            
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                CurrencyAmount(
                    amount: product.price,
                    amountFont: .custom("Poppins-Bold", size: 28),
                    amountColor: .orange,
                    currencyAssetName: "OrangeVector",
                    isStrikethrough: false
                )
                
                if product.originalPrice >= product.price {
                    CurrencyAmount(
                        amount: product.originalPrice,
                        amountFont: .custom("Poppins-Regular", size: 16),
                        amountColor: .gray,
                        currencyAssetName: "GrayVector",
                        isStrikethrough: true
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct ProductDetailsDescriptionSection: View {
    let points: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Description")
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundStyle(.black)
            
            ForEach(points, id: \.self) { point in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.6, blue: 0.5))
                        .frame(width: 14, height: 14)
                        .padding(.top, 4)
                    
                    Text(point)
                        .font(.custom("Poppins-Regular", size: 15))
                        .foregroundStyle(.gray)
                        .lineSpacing(4)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct ProductDetailsBarcodeSection: View {
    let barcode: String
    
    var body: some View {
        VStack(spacing: 4) {
            if let uiImage = BarcodeGenerator.generate(from: barcode) {
                Image(uiImage: uiImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "barcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundStyle(.gray.opacity(0.5))
                    .frame(maxHeight: .infinity)
            }
            
            Text(barcode.isEmpty ? "No Barcode" : barcode)
                .font(.custom("Courier", size: 16))
                .tracking(4)
                .foregroundStyle(.gray)
        }
        .frame(width: 138, height: 81)
        .frame(maxWidth: .infinity)
        .frame(height: 117)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - Helpers

private struct CurrencyAmount: View {
    let amount: Double
    let amountFont: Font
    let amountColor: Color
    let currencyAssetName: String
    let isStrikethrough: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(amount.formatted(.number.precision(.fractionLength(1))))
                .font(amountFont)
                .foregroundStyle(amountColor)

            Image(currencyAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .baselineOffset(-2)
        }
        .overlay(alignment: .center) {
            if isStrikethrough {
                Rectangle()
                    .fill(amountColor.opacity(0.8))
                    .frame(height: 1)
            }
        }
    }
}

private struct ProductDetailRibbon: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 40)
            .background(Color(red: 0.9, green: 0.3, blue: 0.3))
            .rotationEffect(.degrees(45))
            .offset(x: 38, y: 12)
    }
}
