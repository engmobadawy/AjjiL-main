//
//  CategoriesViewModel.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 09/04/2026.
//


import Foundation
import SwiftUI

@MainActor
@Observable
final class CategoriesViewModel {
    // MARK: - State
    private(set) var mainCategories: [StoreCategory] = []
    private(set) var childCategories: [StoreCategory] = []
    
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil
    
    // MARK: - Dependencies
    private let getHomeCategoriesUC: GetHomeCategoriesUC
    private let getStoreSubcategoriesUC: GetStoreSubcategoriesUC
    
    init(
        getHomeCategoriesUC: GetHomeCategoriesUC,
        getStoreSubcategoriesUC: GetStoreSubcategoriesUC
    ) {
        self.getHomeCategoriesUC = getHomeCategoriesUC
        self.getStoreSubcategoriesUC = getStoreSubcategoriesUC
    }
    
    // MARK: - Actions
    func loadCategories(for storeId: Int) async {
        // Prevent redundant fetching if already loading
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Execute both network calls concurrently to minimize wait time
            async let homeCategoriesTask = getHomeCategoriesUC.execute(storeId: storeId)
            async let subCategoriesTask = getStoreSubcategoriesUC.execute(storeId: storeId)
            
            let (homeResponse, subResponse) = try await (homeCategoriesTask, subCategoriesTask)
            
            // Note: Replace '.data' with the actual array property names from your StoreCategoryResponse / StoreSubcategoryResponse models
            self.mainCategories = homeResponse.data ?? []
            self.childCategories = subResponse.data ?? []
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
