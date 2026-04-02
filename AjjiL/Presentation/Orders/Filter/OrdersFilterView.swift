//
//  OrdersFilterSheet.swift
//  AjjiLMB
//

import SwiftUI

struct OrdersFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var filterViewModel: OrderFilterViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Filter by:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    FilterInputView(
                        title: "Store Name",
                        placeholder: "EL-MAGED",
                        text: $filterViewModel.draftStoreName,
                        iconName: "magnifyingglass"
                    )
                    
                    FilterDatePickerView(
                        title: "Order Date",
                        date: $filterViewModel.draftOrderDate,
                        iconName: "calendar"
                    )
                    
                    Spacer(minLength: 30)
                    
                    actionButtons
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .presentationBackground(.white)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text("Orders Filter")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(8)
                    .overlay {
                        Circle()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 20) {
            Button {
                filterViewModel.applyFilter()
                dismiss()
            } label: {
                Text("Filter")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.brandGreen)
                    .clipShape(.rect(cornerRadius: 12))
            }
            
            Button {
                filterViewModel.clearFilter()
                dismiss()
            } label: {
                Text("Clear")
                    .font(.headline)
                    .underline()
                    .foregroundStyle(Color.orange)
            }
        }
    }
}

// MARK: - Reusable Components

struct FilterInputView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack {
                TextField(placeholder, text: $text)
                    .foregroundStyle(.primary)
                    .tint(.brandGreen)
                
                Image(systemName: iconName)
                    .foregroundStyle(Color.secondary.opacity(0.7))
                    .font(.system(size: 20))
            }
            .padding()
            .background(.goodGray)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}

struct FilterDatePickerView: View {
    let title: String
    @Binding var date: Date
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack {
                DatePicker(
                    "Select \(title)",
                    selection: $date,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(.brandGreen)
                
                Spacer()
                
                Image(systemName: iconName)
                    .foregroundStyle(Color.secondary.opacity(0.7))
                    .font(.system(size: 20))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.goodGray)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}
