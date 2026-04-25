import SwiftUI

struct MyPointsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PointsViewModel
    
    // Using a generic green/teal to match your design
    private let primaryGreen = Color(red: 0.25, green: 0.61, blue: 0.54)
    private let primaryOrange = Color.orange
    
    init(viewModel: PointsViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "My Points",
                showBackButton: true,
                kindOfTopRow: .none,
                onBack: {
                    dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    PointsIllustrationView()
                        .padding(.top, 40)
                    
                    PointsSummaryView(pointsData: viewModel.pointsData, greenColor: primaryGreen)
                    
                    VStack(spacing: 16) {
                        Text("Redeem Your Points Now")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Button {
                            viewModel.showRedeemSheet = true
                        } label: {
                            Text("Redeem")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.canOpenRedeemSheet ? primaryGreen : primaryGreen.opacity(0.5))
                                )
                        }
                        .disabled(!viewModel.canOpenRedeemSheet)
                        .padding(.horizontal, 40)
                        
                        Button("View all promo code") {
                            // TODO: Navigate to promo codes screen
                        }
                        .font(.subheadline)
                        .foregroundStyle(primaryOrange)
                        .underline()
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .task {
            await viewModel.fetchPoints()
        }
        .sheet(isPresented: $viewModel.showRedeemSheet, onDismiss: { viewModel.resetForm() }) {
            RedeemPointsSheet(viewModel: viewModel, greenColor: primaryGreen)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showSuccessSheet) {
            PromoCodeSuccessSheet(viewModel: viewModel, greenColor: primaryGreen)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Subviews

private struct PointsIllustrationView: View {
    var body: some View {
        // Placeholder for the coins illustration
        ZStack {
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 150, height: 150)
            
            Image(systemName: "bitcoinsign.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.orange)
        }
    }
}

private struct PointsSummaryView: View {
    let pointsData: PointsData?
    let greenColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            if let data = pointsData {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(data.points ?? 0)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(greenColor)
                    
                    Text("Points")
                        .font(.headline)
                        .foregroundStyle(greenColor)
                }
                
                if let minPoints = data.minPoints {
                    Text("Minimum Points To Redeem: \(minPoints) Points")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                ProgressView()
                    .frame(height: 60)
            }
        }
    }
}