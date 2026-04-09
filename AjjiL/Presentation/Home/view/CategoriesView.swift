//
//  CategoriesView.swift
//  AjjiLMB
//

import SwiftUI
import Kingfisher

struct CategoriesView: View {
    @Environment(\.dismiss) private var dismiss
    let storeId: Int
    @State private var viewModel: CategoriesViewModel
    
    init(storeId: Int, viewModel: CategoriesViewModel) {
        self.storeId = storeId
        // Initialize the owned @Observable view model
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack{
            
        
        TopRowNotForHome(title: "Categories", showBackButton: true, kindOfTopRow: .withCartAndNotification ,onBack: {dismiss()})
        
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    if !viewModel.mainCategories.isEmpty {
                        HorizontalCategorySection(categories: viewModel.mainCategories)
                    }
                    
                    if !viewModel.childCategories.isEmpty {
                        SubCategorySection(subCategories: viewModel.childCategories)
                    }
                }
                .padding(.vertical, 16)
            }
            
            // Loading Overlay
            if viewModel.isLoading && viewModel.mainCategories.isEmpty {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemBackground))
            }
        }
        }
        
        .navigationBarBackButtonHidden(true)
        // Automatically manages task lifecycle, bound to the storeId value
        .task(id: storeId) {
            await viewModel.loadCategories(for: storeId)
        }
        // Optional: Error handling
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in /* Handle dismissal via VM if needed */ }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Sub Category Section
struct SubCategorySection: View {
    let subCategories: [StoreCategory]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sub Categories")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 18)
            
            LazyVStack(spacing: 12) {
                ForEach(subCategories) { category in
                    NavigationLink(value: category.id) {
                        SubCategoryCardView(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
    }
}

// MARK: - Sub Category Card
struct SubCategoryCardView: View {
    let category: StoreCategory
    
    var body: some View {
        HStack(spacing: 0) {
            KFImage(URL(string: category.image))
                .placeholder {
                    ZStack {
                        Color.gray.opacity(0.1)
                        ProgressView()
                    }
                }
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            
            Divider()
            
            Text(category.name)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
        }
        .frame(height: 96)
        .background(Color(uiColor: .systemBackground))
        .clipShape(.rect(cornerRadius: 12))
        .contentShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
    }
}




struct HorizontalCategorySection: View {
    let categories: [StoreCategory]
    
    var body: some View {
        // Horizontal scrolling container, hiding the scrollbar for a cleaner look
        ScrollView(.horizontal, showsIndicators: false) {
            // LazyHStack is the performance-optimized choice for horizontal lists
            LazyHStack(spacing: 16) {
                // Relies on the stable identity of StoreCategory
                ForEach(categories) { category in
                    NavigationLink(value: category.id) {
                        CategoryCardView(category: category)
                            // Constrain the width since it's no longer dictated by a Grid column.
                            // 198 matches your previously specified card dimensions.
                            .frame(width: 198)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
        // If you meant hiding the Navigation Bar title for this entire screen,
        // this modifier ensures the title area collapses.
        .toolbar(.hidden, for: .navigationBar)
    }
}





// MARK: - Mock Data & Preview
extension StoreCategory {
    // Dummy data mimicking your screenshot
    static let mockMainCategories: [StoreCategory] = [
        StoreCategory(id: 1, name: "Grocery", secondaryName: "", children: true, products: 120, image: "https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&q=80"),
        StoreCategory(id: 2, name: "Vegetable And Fruits", secondaryName: "", children: true, products: 85, image: "https://images.unsplash.com/photo-1516594798947-e65505dbb29d?w=400&q=80")
    ]
    
    static let mockChildCategories: [StoreCategory] = [
        StoreCategory(id: 3, name: "Cooking Supplies", secondaryName: "", children: false, products: 45, image: "https://images.unsplash.com/photo-1556910103-1c02745a872f?w=200&q=80"),
        StoreCategory(id: 4, name: "Sauces", secondaryName: "", children: false, products: 30, image: "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=200&q=80"),
        StoreCategory(id: 5, name: "Canned Foods", secondaryName: "", children: false, products: 50, image: "https://images.unsplash.com/photo-1611270402108-9df211eb49bb?w=200&q=80"),
        StoreCategory(id: 6, name: "Honey & Jam & Hala...", secondaryName: "", children: false, products: 15, image: "https://images.unsplash.com/photo-1587049352847-4d4b12631522?w=200&q=80")
    ]
}

