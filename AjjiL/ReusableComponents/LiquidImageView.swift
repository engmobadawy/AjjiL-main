import SwiftUI
import Kingfisher

struct LiquidImageView: View {
    let url: URL?
    
    // Optional target size for memory optimization during downsampling
    var targetSize: CGSize? = nil
    
    var body: some View {
        KFImage(url)
            // Downsample if a size is provided; otherwise, use default processing
            .setProcessor(targetSize.map { DownsamplingImageProcessor(size: $0) } ?? DefaultImageProcessor.default)
            // Cache the original image to disk
            .cacheOriginalImage()
            // Add a smooth fade transition when the image loads
            .fade(duration: 0.25)
            // Handle loading state
            .placeholder {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.secondary.opacity(0.1))
            }
            // Handle failure state (optional, but good practice)
            .onFailureImage(KFCrossPlatformImage(systemName: "photo.badge.exclamationmark"))
            .resizable()
    }
}