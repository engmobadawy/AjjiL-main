import SwiftUI

struct AboutUsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Applying .capitalized to achieve the "Title case" specified in Figma
    private let termsText = "Our Privacy Policy explains what personal information we collect, how we use personal information, how personal information is shared, and privacy rights. Our Privacy Policy explains what personal information we collect, how we use personal information, how personal information is shared, and privacy rights. Our Privacy Policy explains what personal information we collect, how we use personal information, how personal information is shared, and privacy rights. personal information we collect, how we use personal information, how personal information is shared, and privacy rights. personal information we collect, how we use personal information, how personal information is shared, and privacy rights. ".capitalized
    
    var body: some View {
        VStack(spacing: 0) {
            // Your custom navigation row
            TopRowNotForHome(
                title: "About Us",
                showBackButton: true,
                kindOfTopRow: .none,
                onBack: {
                    dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 0) {
                    // Logo Image
                    Image("AJJIL_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 227, height: 50)
                        .padding(.top, 48)    // 48 padding from the top row
                        .padding(.bottom, 24) // 24 padding from the social media row
                    
                    // Social Media Links
                    SocialMediaRow()
                        .padding(.bottom, 32) // Spacing between social icons and text
                    
                    // Privacy Policy Text
                    Text(termsText)
                        .font(.custom("Poppins-Medium", size: 22))
                        .foregroundStyle(Color(red: 71 / 255, green: 86 / 255, blue: 102 / 255))
                        .lineSpacing(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Subviews

private struct SocialMediaRow: View {
    @Environment(\.openURL) private var openURL
    
    // Using a model array to drive the UI.
    // Replace the 'imageName' strings with your actual Asset catalog names.
    private let platforms: [SocialPlatform] = [
            SocialPlatform(imageName: "x", url: "https://x.com"),
            SocialPlatform(imageName: "instagram", url: "https://instagram.com"),
            SocialPlatform(imageName: "facebook", url: "https://facebook.com"),
            SocialPlatform(imageName: "linkedIn", url: "https://linkedin.com"),
            SocialPlatform(imageName: "snapchat", url: "https://snapchat.com"),
            SocialPlatform(imageName: "youtube", url: "https://youtube.com")
        ]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(platforms) { platform in
                Button {
                    if let url = URL(string: platform.url) {
                        openURL(url)
                    }
                } label: {
                    Image(platform.imageName)
                        .resizable()
                        .renderingMode(.original) // Ensures brand colors are kept instead of tinting blue
                        .scaledToFit()
                        .frame(width: 20, height: 20) // Inner icon size
                        .frame(width: 42, height: 42) // Outer card size requirement
                        .background(Color(red: 232 / 255, green: 239 / 255, blue: 243 / 255))
                        .clipShape(.circle)
                }
                .buttonStyle(.plain) // Prevents standard button styling from messing with the layout
            }
        }
    }
}

// MARK: - Models

private struct SocialPlatform: Identifiable {
    var id: String { imageName } // Stable identity using the image name
    let imageName: String
    let url: String
}
