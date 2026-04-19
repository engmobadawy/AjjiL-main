//
//  BranchSelectionView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/03/2026.
//

import SwiftUI
import Shimmer // 1. Import Shimmer

struct BranchSelectionView: View {
    // 1. Accept the dynamically fetched branches from the parent view
    let branches: [BranchDataEntity]
    
    // 2. Accept the store name
    let storeName: String
    
    // Internal view state
    @State private var selectedBranchID: Int? = nil
    
    // Actions
    var onDisplayProducts: (BranchDataEntity) -> Void
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 24) {
                headerSection
                branchesList
                actionButtons
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
            .clipShape(.rect(cornerRadius: 24))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 8) {
            // UPDATED: Dynamically inject the store name
            Text("\(storeName) Branches")
                .font(.custom("Poppins-SemiBold", size: 28))
                .foregroundStyle(.brandGreen)
            
            Text("Select the branch nearest to you to\nget the most accurate results.")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private var branchesList: some View {
        ScrollView {
            VStack(spacing: 12) {
                if branches.isEmpty {
                    // 2. Replace ProgressView with Skeleton + Shimmer
                    BranchListSkeleton()
                        .shimmering()
                        .padding(.top, 4)
                } else {
                    ForEach(branches) { branch in
                        BranchRowView(
                            branch: branch,
                            isSelected: selectedBranchID == branch.id
                        ) {
                            selectedBranchID = branch.id
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 300)
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 16) {
            GreenButton(title: "Display Products") {
                if let selectedId = selectedBranchID,
                   let selectedBranch = branches.first(where: { $0.id == selectedId }) {
                    onDisplayProducts(selectedBranch)
                }
            }
            .disabled(selectedBranchID == nil)
            .padding(.horizontal, 29)
            
            Button(action: onDismiss) {
                Text("Back To Home")
                    .font(.headline)
                    .foregroundStyle(.orange)
                    .underline()
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Skeleton View

/// 3. Dedicated Skeleton mimicking the BranchRowView
struct BranchListSkeleton: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 8) {
                    // Title placeholder
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 120, height: 14)
                        .clipShape(.rect(cornerRadius: 4))
                    
                    HStack(alignment: .top, spacing: 8) {
                        // Map Icon placeholder
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            // Address placeholder
                            Rectangle()
                                .fill(.gray.opacity(0.3))
                                .frame(width: 180, height: 14)
                                .clipShape(.rect(cornerRadius: 4))
                            
                            // "View on map" placeholder
                            Rectangle()
                                .fill(.gray.opacity(0.3))
                                .frame(width: 80, height: 12)
                                .clipShape(.rect(cornerRadius: 4))
                        }
                    }
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(uiColor: .systemBackground))
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            }
        }
    }
}

// MARK: - Extracted Row Subview
struct BranchRowView: View {
    let branch: BranchDataEntity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(branch.name)
                    .font(.caption.bold())
                    .foregroundStyle(.brandGreen)
                
                HStack(alignment: .top, spacing: 8) {
                    Image("map")
                        .foregroundStyle(.gray)
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(branch.address)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        Text("View On Map")
                            .font(.caption)
                            .foregroundStyle(.brandGreen)
                            .underline()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .environment(\.layoutDirection, .leftToRight)
            .padding(16)
            .background(Color(uiColor: .systemBackground))
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .brandGreen : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }
}
