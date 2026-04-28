import SwiftUI

struct TermsAndConditionView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 🛠️ FIX: Added .newlocalized
    private let termsText = "Our Privacy Policy explains what personal information we collect, how we use personal information, how personal information is shared, and privacy rights. Our Privacy Policy explains what personal information we collect, how we use personal information, how personal information is shared, and privacy rights. Our Privacy Policy explains what personal information we collect, how we use personal information, how personal information is shared, and privacy rights. personal information we collect, how we use personal information, how personal information is shared, and privacy rights. personal information we collect, how we use personal information, how personal information is shared, and privacy rights. ".newlocalized.capitalized
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                // 🛠️ FIX: Added .newlocalized
                title: "Terms & Conditions".newlocalized,
                showBackButton: true,
                kindOfTopRow: .none,
                onBack: {
                    dismiss()
                }
            )
            
            ScrollView {
                Text(termsText)
                    .font(.custom("Poppins-Medium", size: 22)) // Size: 22px, Font: Poppins Medium
                    .foregroundStyle(Color(red: 71 / 255, green: 86 / 255, blue: 102 / 255)) // rgba(71, 86, 102, 1)
                    .lineSpacing(16) // Line height 38px - Font size 22px = 16px spacing
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TermsAndConditionView()
}
