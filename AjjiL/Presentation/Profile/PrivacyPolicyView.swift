
//
//  TermsAndConditionView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/04/2026.
//


//
//  TermsAndConditionView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 18/02/2026.
//

import SwiftUI

struct TermsAndConditionView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Applying .capitalized to achieve the "Title case" specified in Figma
    private let termsText = "Our Privacy Policy explains what personal information we collect, how we use personal information, how personal information is shared, and privacy rights. Our Privacy Policy explains what personal information we collect, how we use personal information, how personal information is shared, and privacy rights. Our Privacy Policy explains what personal information we collect, how we use personal information, how personal information is shared, and privacy rights. personal information we collect, how we use personal information, how personal information is shared, and privacy rights. personal information we collect, how we use personal information, how personal information is shared, and privacy rights. ".capitalized
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "Terms & Conditions",
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
