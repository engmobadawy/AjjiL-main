//import SwiftUI
//
//// MARK: - POD Configuration
///// A Plain Old Data struct for fast view diffing.
///// You can map your decoded JSON model to this struct in your ViewModel.
////struct OrderCellConfig: Equatable {
////    let referenceNo: String
////    let dateString: String
////    let storeName: String
////    let storeImageUrl: URL?
////    let totalAmount: String
////    let statusText: String?
////    let statusColor: Color
////    let isReturnable: Bool
////}
//
//// MARK: - Reusable Cell View
//struct OrderHistoryCell: View {
//    let config: OrderCellConfig
//    let onViewOrder: () -> Void
//    let onReturn: () -> Void
//    
//    // Custom colors matching the design
//    private let primaryGreen = Color(red: 0.16, green: 0.53, blue: 0.38)
//    private let primaryOrange = Color(red: 0.91, green: 0.49, blue: 0.19)
//    private let buttonGray = Color(red: 0.89, green: 0.89, blue: 0.89)
//    private let textGray = Color(red: 0.4, green: 0.4, blue: 0.4)
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            headerRow
//            dateRow
//            storeRow
//            actionButtons
//        }
//        .padding(16)
//        .background(Color.white)
//        .clipShape(.rect(cornerRadius: 12))
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//        )
//    }
//    
//    // MARK: - Subviews
//    
//    @ViewBuilder
//    private var headerRow: some View {
//        HStack(alignment: .center, spacing: 8) {
//            Text(config.referenceNo)
//                .font(.title3)
//                .fontWeight(.bold)
//                .foregroundStyle(primaryGreen)
//            
//            if let status = config.statusText, !status.isEmpty {
//                Text(status)
//                    .font(.caption)
//                    .fontWeight(.medium)
//                    .foregroundStyle(config.statusColor)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(config.statusColor.opacity(0.15))
//                    .clipShape(.rect(cornerRadius: 6))
//            }
//            
//            Spacer()
//            
//            Text(config.totalAmount)
//                .font(.headline)
//                .foregroundStyle(primaryOrange)
//        }
//    }
//    
//    @ViewBuilder
//    private var dateRow: some View {
//        HStack(spacing: 6) {
//            Image(systemName: "clock")
//                .foregroundStyle(primaryGreen)
//            
//            Text("Requested Date: \(config.dateString)")
//                .font(.subheadline)
//                .foregroundStyle(textGray)
//        }
//    }
//    
//    @ViewBuilder
//    private var storeRow: some View {
//        HStack(spacing: 6) {
//            Image(systemName: "storefront")
//                .foregroundStyle(primaryGreen)
//            
//            Text("Stores:")
//                .font(.subheadline)
//                .foregroundStyle(primaryGreen)
//                .underline()
//            
//            // Replaced with actual AsyncImage when tying to real data.
//            // Downsampling is recommended if the logo image files are large.
//            AsyncImage(url: config.storeImageUrl) { phase in
//                if let image = phase.image {
//                    image
//                        .resizable()
//                        .scaledToFill()
//                } else {
//                    Circle()
//                        .fill(Color.gray.opacity(0.2))
//                }
//            }
//            .frame(width: 20, height: 20)
//            .clipShape(.circle)
//        }
//    }
//    
//    @ViewBuilder
//    private var actionButtons: some View {
//        HStack(spacing: 12) {
//            Button(action: onViewOrder) {
//                Text("View Order")
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//                    .background(buttonGray)
//                    .foregroundStyle(primaryGreen)
//                    .clipShape(.rect(cornerRadius: 8))
//            }
//            
//            if config.isReturnable {
//                Button(action: onReturn) {
//                    HStack {
//                        Image(systemName: "arrow.uturn.backward")
//                            .font(.caption)
//                        Text("Re-Turn")
//                    }
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//                    .background(Color.white)
//                    .foregroundStyle(primaryGreen)
//                    .clipShape(.rect(cornerRadius: 8))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(primaryGreen, lineWidth: 1)
//                    )
//                }
//            }
//        }
//        .padding(.top, 4)
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    ScrollView {
//        VStack(spacing: 16) {
//            // 1. With Return Button and no status
//            OrderHistoryCell(
//                config: OrderCellConfig(
//                    referenceNo: "AJ-CH43AS",
//                    dateString: "23\\5\\2025 - 03:45PM",
//                    storeName: "Super Marco",
//                    storeImageUrl: nil,
//                    totalAmount: "102.9 ر.س",
//                    statusText: nil,
//                    statusColor: .clear,
//                    isReturnable: true
//                ),
//                onViewOrder: {},
//                onReturn: {}
//            )
//            
//            // 2. With Status Badge, no return button
//            OrderHistoryCell(
//                config: OrderCellConfig(
//                    referenceNo: "AJ-CH43AS",
//                    dateString: "23\\5\\2025 - 03:45PM",
//                    storeName: "Super Marco",
//                    storeImageUrl: nil,
//                    totalAmount: "102.9 ر.س",
//                    statusText: "Return process",
//                    statusColor: .orange,
//                    isReturnable: false
//                ),
//                onViewOrder: {},
//                onReturn: {}
//            )
//            
//            // 3. Rejected Status
//            OrderHistoryCell(
//                config: OrderCellConfig(
//                    referenceNo: "AJ-CH43AS",
//                    dateString: "23\\5\\2025 - 03:45PM",
//                    storeName: "Super Marco",
//                    storeImageUrl: nil,
//                    totalAmount: "102.9 ر.س",
//                    statusText: "Return Rejected",
//                    statusColor: .red,
//                    isReturnable: false
//                ),
//                onViewOrder: {},
//                onReturn: {}
//            )
//        }
//        .padding()
//        .background(Color(white: 0.97))
//    }
//}
