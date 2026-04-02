import Foundation
import SwiftUI

@Observable
@MainActor
class StoreViewModel {
    // Keep this private as per your state management rules, expose a read-only or just use it directly in the view
    var storeSliders: [StoreSlider] = []
    
    private let getStoreSlidersUC: GetStoreSlidersUC
    
    init(getStoreSlidersUC: GetStoreSlidersUC) {
        self.getStoreSlidersUC = getStoreSlidersUC
    }
    
    func fetchStoreSliders(storeId: Int) async {
        do {
            let response = try await getStoreSlidersUC.execute(storeId: storeId)
            self.storeSliders = response.data
        } catch {
            // In a production app, handle this error (e.g., show a toast or error state)
            print("Failed to fetch store sliders: \(error.localizedDescription)")
        }
    }
}