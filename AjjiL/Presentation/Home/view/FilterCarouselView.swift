//
//  FilterCarouselView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 09/04/2026.
//


import SwiftUI

//// MARK: - Updated Filter Carousel View
//struct FilterCarouselView: View {
//    /// The real subcategories fetched from the API
//    let categories: [StoreCategory]
//    /// Binding to the selected ID (nil represents "All")
//    @Binding var selectedCategoryID: Int?
//    
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            LazyHStack(spacing: 12) {
//                // 1. The Fixed "All" Button (ID is nil)
//                FilterChipView(
//                    title: "All",
//                    isSelected: selectedCategoryID == nil,
//                    fixedWidth: 81
//                ) {
//                    withAnimation(.snappy) {
//                        selectedCategoryID = nil
//                    }
//                }
//                
//                // 2. The Dynamic Categories from your Use Case
//                ForEach(categories) { category in
//                    FilterChipView(
//                        title: category.name,
//                        isSelected: selectedCategoryID == category.id,
//                        fixedWidth: nil
//                    ) {
//                        withAnimation(.snappy) {
//                            selectedCategoryID = category.id
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal, 18)
//        }
//        .frame(height: 44)
//    }
//}
//
//// (Keep the same FilterChipView from the previous response here)
//
//// MARK: - Reusable Filter Chip View
//struct FilterChipView: View {
//    let title: String
//    let isSelected: Bool
//    var fixedWidth: CGFloat? = nil
//    let action: () -> Void
//    
//    // Extracted colors matching your screenshot aesthetic
//    private let activeBg = Color(red: 0.95, green: 0.51, blue: 0.20) // Orange
//    private let inactiveBg = Color(red: 0.93, green: 0.95, blue: 0.96) // Light Gray
//    private let activeText = Color.white
//    private let inactiveText = Color.gray
//    
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
//                .foregroundStyle(isSelected ? activeText : inactiveText)
//                
//                // 1. Conditionally apply the fixed width if provided (for the "All" button)
//                .frame(width: fixedWidth)
//                
//                // 2. Conditionally apply the 19px horizontal padding for the rest
//                .padding(.horizontal, fixedWidth == nil ? 19 : 0)
//                
//                // 3. Enforce the strict 44px height for all chips
//                .frame(height: 44)
//                
//                .background(isSelected ? activeBg : inactiveBg)
//                // Using modern iOS 17+ clipShape API instead of deprecated cornerRadius
//                .clipShape(.rect(cornerRadius: 12))
//        }
//        // Prevents SwiftUI from adding default blue button tint overlays
//        .buttonStyle(.plain)
//    }
//}


