import SwiftUI

struct StorescardVeiw: View {
    
    let imageURL: String
    var size: CGFloat = 95
    var imagePadding: CGFloat = 14

    var body: some View {
        Circle()
            .fill(.goodGray) // Assuming .goodGray is defined in your Color assets
            .overlay {
                // Use AsyncImage to load the network URL
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        // Show a loading indicator while fetching
                        ProgressView()
                    case .success(let image):
                        // Image loaded successfully
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(imagePadding)
                    case .failure:
                        // Fallback icon if the network request fails
                        Image(systemName: "storefront")
                            .foregroundStyle(.gray) // Modern API replacing .foregroundColor()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .frame(width: size, height: size)
            // Modern API: Visually clips the content to the circle
            .clipShape(.circle)
            .accessibilityLabel("Store logo")
    }
}
