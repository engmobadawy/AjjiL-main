//
//  OrderFilterStore.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 24/03/2026.
//

import SwiftUI

@Observable
@MainActor
final class OrderFilterViewModel {
    // Temporary state for the active sheet inputs
    var draftStoreName: String = ""
    var draftOrderDate: Date = Date() // Changed to Date (defaults to today)
    
    // Persisted state once the user hits "Filter"
    private(set) var appliedStoreName: String = ""
    private(set) var appliedOrderDate: Date? = nil // Optional so we can track a "cleared" state
    
    func applyFilter() {
        appliedStoreName = draftStoreName
        appliedOrderDate = draftOrderDate
        
        // Using modern Swift formatting for the print statement
        let dateString = draftOrderDate.formatted(date: .abbreviated, time: .omitted)
        print("Filters Saved! Store: \(appliedStoreName), Date: \(dateString)")
    }
    
    func clearFilter() {
        draftStoreName = ""
        draftOrderDate = Date() // Reset the picker UI back to today
        appliedStoreName = ""
        appliedOrderDate = nil  // Nil explicitly means "do not filter by date"
        
        print("Filters Cleared")
    }
    
    func loadDrafts() {
        // Populates the sheet with the currently applied filters when opened
        draftStoreName = appliedStoreName
        // If a date was previously applied, use it. Otherwise, default to today.
        draftOrderDate = appliedOrderDate ?? Date()
    }
}
