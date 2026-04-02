//
//  TermsAgreementView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 17/02/2026.
//

import SwiftUI

struct TermsAgreementView: View {

    @Binding var isAgreed: Bool
    let onAgreementTapped: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            agreementRow
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("already_have_account".localized())
                .font(.custom("Poppins-Medium", size: 18))
                .foregroundStyle(.softGray)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// MARK: - Subviews
private extension TermsAgreementView {

    var agreementRow: some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
                withAnimation(.snappy) {
                    isAgreed.toggle()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isAgreed ? .brandGreen : .gray.opacity(0.3))
                        .frame(width: 24, height: 24)

                    if isAgreed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("agree_to_terms_accessibility".localized())

            Button(action: onAgreementTapped) {
                agreementText
            }
            .buttonStyle(.plain)
        }
    }

    var agreementText: some View {
        (
            Text("by_tapping".localized())
                .foregroundStyle(.gray)
            +
            Text("sign_up_quote".localized())
                .foregroundStyle(.customOrange)
                .fontWeight(.bold)
            +
            Text("you_agree_with".localized())
                .foregroundStyle(.gray)
            +
            Text("terms_and_conditions".localized())
                .foregroundStyle(.brandGreen)
                .fontWeight(.bold)
                .underline()
        )
        .font(.custom("Poppins-Regular", size: 20))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}
