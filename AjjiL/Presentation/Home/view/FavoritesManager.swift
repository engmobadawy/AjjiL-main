//
//  FavoritesManager.swift
//  AjjiL
//

import SwiftUI
import Observation

@MainActor
@Observable
final class FavoritesManager {
    // Singleton instance for global access
    static let shared = FavoritesManager()
    
    // The Single Source of Truth
    var favoriteIDs: Set<Int> = []
    
    private init() {}
    
    /// Checks if an ID is favorited. Views reading this will auto-update when the Set changes.
    func isFavorite(_ id: Int) -> Bool {
        favoriteIDs.contains(id)
    }
    
    /// Syncs backend data into our local truth
    func setFavorite(_ id: Int, isFavorite: Bool) {
        if isFavorite {
            favoriteIDs.insert(id)
        } else {
            favoriteIDs.remove(id)
        }
    }
    
    /// Optimistically toggles the state locally and returns the new state
    func toggleLocal(_ id: Int) -> Bool {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
            return false
        } else {
            favoriteIDs.insert(id)
            return true
        }
    }
}