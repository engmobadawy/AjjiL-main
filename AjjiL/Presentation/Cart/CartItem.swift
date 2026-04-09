import SwiftUI

// MARK: - Model
@Observable
@MainActor
final class CartItem: Identifiable {
    let id: UUID
    let imageName: String
    let category: String
    let title: String
    let price: Double
    var quantity: Int
    
    init(id: UUID = UUID(), imageName: String, category: String, title: String, price: Double, quantity: Int = 1) {
        self.id = id
        self.imageName = imageName
        self.category = category
        self.title = title
        self.price = price
        self.quantity = quantity
    }
    
    func incrementQuantity() {
        quantity += 1
    }
    
    func decrementQuantity() {
        if quantity > 1 {
            quantity -= 1
        }
    }
}

// MARK: - Color Theme
extension Color {
    static let cardBorder = Color(red: 232/255, green: 239/255, blue: 243/255)
    static let categoryRed = Color(red: 255/255, green: 100/255, blue: 100/255)
    static let titleDark = Color(red: 48/255, green: 55/255, blue: 51/255)
    static let priceOrange = Color(red: 255/255, green: 119/255, blue: 1/255)
    static let buttonGreen = Color(red: 2/255, green: 115/255, blue: 53/255)
}

// MARK: - Main Card View
struct CartItemCardView: View {
    let item: CartItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            CartItemImageView(imageName: item.imageName)
            
            CartItemDetailsView(item: item, onDelete: onDelete)
        }
        .frame(height: 118)
        .background(.white)
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cardBorder, lineWidth: 1)
        }
    }
}

// MARK: - Subviews
private struct CartItemImageView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .padding(16) // Padding inside the image container
            .frame(width: 138, height: 118)
            .overlay(alignment: .trailing) {
                // Separator line matching the 1px border requirement
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(Color.cardBorder)
            }
    }
}

private struct CartItemDetailsView: View {
    let item: CartItem
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.category)
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundStyle(Color.categoryRed)
            
            Text(item.title)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundStyle(Color.titleDark)
            
            HStack(spacing: 4) {
                Text(item.price, format: .number.precision(.fractionLength(1)))
                    .font(.system(size: 14))
                    .foregroundStyle(Color.priceOrange)
                
                Image("OrangeVector")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 11, height: 11)
            }
            
            Spacer(minLength: 0)
            
            CartItemControlsView(item: item, onDelete: onDelete)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

private struct CartItemControlsView: View {
    let item: CartItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            // Custom Stepper
            HStack(spacing: 16) {
                Button(action: item.decrementQuantity) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 39.6, height: 36)
                        .background(Color.buttonGreen)
                        .clipShape(.rect(cornerRadius: 8))
                }
                
                Text(item.quantity, format: .number)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.buttonGreen)
                
                Button(action: item.incrementQuantity) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 39.6, height: 36)
                        .background(Color.buttonGreen)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            
            Spacer()
            
            // Trash Button
            Button(action: onDelete) {
                Image("redTrash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
    }
}