import SwiftUI

// MARK: - Filter Carousel Container
struct FilterCarouselView: View {
    /// The list of category strings to display
    let categories: [String]
    /// The currently selected category
    @Binding var selectedCategory: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                // Using \.self provides a stable identity for dynamic content
                ForEach(categories, id: \.self) { category in
                    FilterChipView(
                        title: category,
                        isSelected: selectedCategory == category,
                        // Apply fixed width of 81 ONLY to the first item
                        fixedWidth: category == categories.first ? 81 : nil
                    ) {
                        // Action to update the binding with animation
                        withAnimation(.snappy) {
                            selectedCategory = category
                        }
                    }
                }
            }
            // Adds leading/trailing padding to the scrollable area
            .padding(.horizontal, 18) 
        }
        // Prevents the view from growing vertically
        .frame(height: 44) 
    }
}

// MARK: - Reusable Filter Chip View
struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    var fixedWidth: CGFloat? = nil
    let action: () -> Void
    
    // Extracted colors matching your screenshot aesthetic
    private let activeBg = Color(red: 0.95, green: 0.51, blue: 0.20) // Orange
    private let inactiveBg = Color(red: 0.93, green: 0.95, blue: 0.96) // Light Gray
    private let activeText = Color.white
    private let inactiveText = Color.gray
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? activeText : inactiveText)
                
                // 1. Conditionally apply the fixed width if provided (for the "All" button)
                .frame(width: fixedWidth)
                
                // 2. Conditionally apply the 19px horizontal padding for the rest
                .padding(.horizontal, fixedWidth == nil ? 19 : 0)
                
                // 3. Enforce the strict 44px height for all chips
                .frame(height: 44)
                
                .background(isSelected ? activeBg : inactiveBg)
                // Using modern iOS 17+ clipShape API instead of deprecated cornerRadius
                .clipShape(.rect(cornerRadius: 12))
        }
        // Prevents SwiftUI from adding default blue button tint overlays
        .buttonStyle(.plain)
    }
}