import SwiftUI

struct BrandCard: View {
    let image: String

    let width: CGFloat = 130
    let height: CGFloat = 148
    let cornerRadius: CGFloat = 18

    var onTap: (() -> Void)? = nil

    

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Button {
            onTap?()
        } label: {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .clipShape(shape)
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Image")
    }
}



#Preview {
    BrandCard(image: "Brand1", onTap: {})
    
}
