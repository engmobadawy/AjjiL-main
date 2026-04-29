//
//  OrderHistoryCell.swift
//  AjjiLMB
//

import SwiftUI
import Kingfisher

// MARK: - POD Configuration
/// A Plain Old Data struct for fast view diffing.
struct OrderCellConfig: Equatable, Identifiable {
    let id: Int
    let referenceNo: String
    let dateString: String
    let storeName: String
    let storeImageUrl: URL?
    let totalAmount: String
    let statusText: String?
    let statusColor: Color
    let canReturn: Bool
    let canScanCashier: Bool
}

// MARK: - Reusable Cell View
struct OrderHistoryCell: View {
    let config: OrderCellConfig
    let onViewOrder: () -> Void
    let onReturn: () -> Void
    let onCashierScan: () -> Void
    
    // Custom colors matching the design
    private let primaryGreen = Color(red: 0.16, green: 0.53, blue: 0.38)
    private let primaryOrange = Color(red: 0.91, green: 0.49, blue: 0.19)
    private let buttonGray = Color(red: 0.89, green: 0.89, blue: 0.89)
    private let textGray = Color(red: 0.4, green: 0.4, blue: 0.4)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            dateRow
            storeRow
            actionButtons
        }
        .padding(16)
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerRow: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(config.referenceNo)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(primaryGreen)
            
            if let status = config.statusText, !status.isEmpty {
                Text(status)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(config.statusColor == .orange ? .orange : .white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(config.statusColor.opacity(config.statusColor == .orange ? 0.15 : 1.0))
                    .clipShape(.rect(cornerRadius: 6))
            }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 4) {
                Text(config.totalAmount)
                    .font(.headline)
                    .foregroundStyle(primaryOrange)
                
                Image("OrangeVector")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
        }
    }
    
    @ViewBuilder
    private var dateRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .foregroundStyle(primaryGreen)
            
            // 🛠️ FIX: Safely separated string and variable to maintain localization formatting
            Text("Requested Date: ".newlocalized)
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundStyle(textGray)
            + Text(config.dateString)
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundStyle(textGray)
        }
    }
   
    @ViewBuilder
    private var storeRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "storefront")
                .foregroundStyle(primaryGreen)
            
            // 🛠️ FIX: Added .newlocalized
            Text("Stores:".newlocalized)
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundStyle(primaryGreen)
                .underline()
            
            KFImage(config.storeImageUrl)
                .placeholder {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                }
                .resizable()
                .scaledToFill()
                .frame(width: 20, height: 20)
                .clipShape(.circle)
        }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: onViewOrder) {
                // 🛠️ FIX: Added .newlocalized
                Text("View Order".newlocalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(buttonGray)
                    .foregroundStyle(primaryGreen)
                    .clipShape(.rect(cornerRadius: 8))
            }
            
            if config.canScanCashier {
                Button(action: onCashierScan) {
                    HStack(spacing: 6) {
                        Image(systemName: "qrcode.viewfinder")
                        // 🛠️ FIX: Added .newlocalized
                        Text("Cashier Scan".newlocalized)
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(primaryGreen)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 8))
                }
            } else if config.canReturn {
                Button(action: onReturn) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.caption)
                        // 🛠️ FIX: Added .newlocalized
                        Text("Re-Turn".newlocalized)
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .foregroundStyle(primaryGreen)
                    .clipShape(.rect(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(primaryGreen, lineWidth: 1)
                    )
                }
            }
        }
        .padding(.top, 4)
    }
}
