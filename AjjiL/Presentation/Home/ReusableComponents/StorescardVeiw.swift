import SwiftUI
import Kingfisher
struct StorescardVeiw: View {
    
    let imageURL: String
    var size: CGFloat = 95
    var imagePadding: CGFloat = 14

    var body: some View {
        Circle()
            .fill(.goodGray) // Assuming .goodGray is defined in your Color assets
            .overlay {
                KFImage(URL(string: imageURL))
                    // 1. Show the ProgressView while fetching from network/disk
                    .placeholder {
                        ProgressView()
                    }
                    // 2. Fallback if the URL is broken or network fails
                    // We use UIImage here because Kingfisher's failure modifier expects a cross-platform image object
                    .onFailureImage(UIImage(systemName: "storefront")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal))
                    // 3. Modifiers applied to the successfully loaded image
                    .resizable()
                    .scaledToFit()
                    .padding(imagePadding)
            }
            .frame(width: size, height: size)
            .clipShape(.circle)
            .accessibilityLabel("Store logo")
    }
}
