//
//  MyPointsView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//


import SwiftUI

struct MyPointsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PointsViewModel
    
    // State to trigger navigation to Promo Codes
    @State private var navigateToPromoCodes = false
    
    // Using a generic green/teal to match your design
    private let primaryGreen = Color(red: 0.25, green: 0.61, blue: 0.54)
    // Updated to precise rgba(255, 119, 1, 1)
    private let primaryOrange = Color(red: 255/255, green: 119/255, blue: 1/255)
    
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
                    
                    // Passing the exact orange color down to the summary view
                    PointsSummaryView(
                        pointsData: viewModel.pointsData,
                        greenColor: primaryGreen,
                        orangeColor: primaryOrange
                    )
                    
                    VStack(spacing: 16) {
                        Text("Redeem Your Points Now")
                            .font(.system(size: 28, weight: .semibold)) // Updated size and weight
                        
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
                            // Trigger navigation state
                            navigateToPromoCodes = true
                        }
                        .font(.subheadline)
                        .foregroundStyle(primaryOrange) // Updated to precise color
                        .underline()
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.fetchPoints()
        }
        .sheet(isPresented: $viewModel.showRedeemSheet, onDismiss: { viewModel.resetForm() }) {
            RedeemPointsSheet(viewModel: viewModel, greenColor: primaryGreen)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
        }
        .sheet(isPresented: $viewModel.showSuccessSheet) {
            PromoCodeSuccessSheet(viewModel: viewModel, greenColor: primaryGreen)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
        }
        // Safely navigate to the Promo Codes Screen
        .navigationDestination(isPresented: $navigateToPromoCodes) {
            // 1. Initialize Network & Repository
            let networkService = NetworkService()
            let repository = ProfileRepositoryImp(networkService: networkService)
            
            // 2. Initialize Use Case
            let getPromoCodesUC = GetPromoCodesUC(repo: repository)
            
            // 3. Initialize ViewModel
            let codesViewModel = PromoCodesViewModel(getPromoCodesUC: getPromoCodesUC)
            
            // 4. Inject into the View
            PromoCodesView(viewModel: codesViewModel)
        }
    }
}

// MARK: - Subviews

private struct PointsIllustrationView: View {
    var body: some View {
        Image("points")
            .resizable()
            .scaledToFit()
            .frame(width: 215, height: 215)
    }
}

private struct PointsSummaryView: View {
    let pointsData: PointsData?
    let greenColor: Color
    let orangeColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            if let data = pointsData {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(data.points ?? 0)")
                        .font(.system(size: 38, weight: .bold)) // Maintained 38px Bold
                        .foregroundStyle(greenColor)
                    
                    Text("Points")
                        .font(.system(size: 14, weight: .semibold)) // Updated to 14px SemiBold
                        .foregroundStyle(greenColor)
                }
                
                if let minPoints = data.minPoints {
                    // Text concatenation targets just the number for distinct styling
                    Text("Minimum Points To Redeem: ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    + Text("\(minPoints)")
                        .font(.system(size: 16, weight: .semibold)) // Updated to 16px SemiBold
                        .foregroundStyle(orangeColor)               // Updated to specific orange
                    + Text(" Points")
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

import Foundation
import SwiftUI

@Observable
@MainActor
final class PointsViewModel {
    
    // MARK: - Use Cases
    private let getPointsUC: GetPointsUC
    private let redeemPointsUC: RedeemPointsUC
    private let calcPointsUC: CalcPointsUC
    
    // MARK: - State
    var pointsData: PointsData?
    var isLoading = false
    var errorMessage: String?
    
    // Sheet Navigation State
    var showRedeemSheet = false
    var showSuccessSheet = false
    
    // Redeem Form State
    var pointsToRedeemInput: String = ""
    var calculatedDiscount: String = ""
    var isCalculating = false
    private var calcTask: Task<Void, Never>?
    
    // Success State
    var successData: RedeemPointsData?
    
    // MARK: - Initialization
    init(getPointsUC: GetPointsUC, redeemPointsUC: RedeemPointsUC, calcPointsUC: CalcPointsUC) {
        self.getPointsUC = getPointsUC
        self.redeemPointsUC = redeemPointsUC
        self.calcPointsUC = calcPointsUC
    }
    
    // MARK: - Computed Properties
    var canOpenRedeemSheet: Bool {
        guard let data = pointsData, let currentPoints = data.points, let minPoints = data.minPoints else {
            return false
        }
        return currentPoints >= minPoints && data.canRedeem == true
    }
    
    var isRedeemSubmitValid: Bool {
        guard let input = Int(pointsToRedeemInput),
              let data = pointsData,
              let maxPoints = data.maxPoints else { return false }
        
        return input > 0 && input <= maxPoints && !calculatedDiscount.isEmpty && !isCalculating
    }
    
    // MARK: - Methods
    func fetchPoints() async {
        isLoading = true
        errorMessage = nil
        
        do {
            pointsData = try await getPointsUC.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func debounceCalculateDiscount() {
        calcTask?.cancel()
        
        guard let amount = Int(pointsToRedeemInput), amount > 0 else {
            calculatedDiscount = ""
            return
        }
        
        calcTask = Task {
            do {
                // Debounce delay
                try await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { return }
                
                isCalculating = true
                let response = try await calcPointsUC.execute(amount: amount)
                
                guard !Task.isCancelled else { return }
                if let discount = response.discountValue {
                    calculatedDiscount = "\(discount)"
                }
            } catch {
                if !Task.isCancelled {
                    calculatedDiscount = ""
                }
            }
            
            if !Task.isCancelled {
                isCalculating = false
            }
        }
    }
    
    func submitRedeem() async {
        guard let amount = Int(pointsToRedeemInput) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await redeemPointsUC.execute(amount: amount)
            successData = response
            
            // Navigate to success state
            showRedeemSheet = false
            // Slight delay to allow previous sheet to dismiss smoothly
            try await Task.sleep(for: .milliseconds(300))
            showSuccessSheet = true
            
            // Refresh points total
            await fetchPoints()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func resetForm() {
        pointsToRedeemInput = ""
        calculatedDiscount = ""
        successData = nil
    }
}






import SwiftUI

struct RedeemPointsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: PointsViewModel
    let greenColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            headerRow
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Convert Points Into Discount")
                    .font(.headline)
                
                Text("Creates a code to gain a discount amount on your order")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
            }
            
            conversionInputs
            
            if let maxPoints = viewModel.pointsData?.maxPoints {
                Text("Maximum limit is \(maxPoints) points")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            Button {
                Task { await viewModel.submitRedeem() }
            } label: {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    Text("Create Promo Code")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.isRedeemSubmitValid ? greenColor : greenColor.opacity(0.5))
            )
            .disabled(!viewModel.isRedeemSubmitValid || viewModel.isLoading)
            
            CenterLinkButton(title: "View all promo code")
            
            Spacer()
        }
        .padding(24)
    }
    
    private var headerRow: some View {
        HStack {
            Text("Redeem Your Points Now")
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.black)
                    .font(.title2)
            }
        }
    }
    
    private var conversionInputs: some View {
        HStack(spacing: 16) {
            TextField("000", text: $viewModel.pointsToRedeemInput)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(greenColor, lineWidth: 1)
                )
                .onChange(of: viewModel.pointsToRedeemInput) { _, _ in
                    viewModel.debounceCalculateDiscount()
                }
            
            Image(systemName: "arrow.left.arrow.right")
                .foregroundStyle(.secondary)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                if viewModel.isCalculating {
                    ProgressView()
                        .padding(.leading)
                } else {
                    Text(viewModel.calculatedDiscount.isEmpty ? "000" : viewModel.calculatedDiscount)
                        .padding()
                        .foregroundStyle(viewModel.calculatedDiscount.isEmpty ? .secondary : .primary)
                }
            }
            .frame(height: 54)
        }
    }
}

// Reusable Subview
private struct CenterLinkButton: View {
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            Button(title) {
                // TODO: Navigation action
            }
            .font(.subheadline)
            .foregroundStyle(.orange)
            .underline()
            Spacer()
        }
        .padding(.top, 8)
    }
}







import SwiftUI

struct PromoCodeSuccessSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: PointsViewModel
    let greenColor: Color
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Redeem Your Points Now")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // Placeholder for Success Illustration
            Image("redeemPoints")
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(greenColor)
                .padding(.vertical, 40)
            
            VStack(spacing: 8) {
                Text("Your Promo Code")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(greenColor)
                
                Text("This code can be used only once")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if let code = viewModel.successData?.couponCode {
                HStack {
                    Text(code)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        UIPasteboard.general.string = code
                        // Optional: Show a toast/feedback
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(greenColor)
                    }
                }
                .padding()
                .background(Color.white)
                .clipShape(.rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 24)
            }
            
            if let expiration = viewModel.successData?.expiredAt {
                Text("Expires on: \(expiration)")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}
