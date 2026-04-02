import Foundation
import SwiftUI

@Observable
@MainActor
class StoreViewModel {
    var storeSliders: [StoreSlider] = []
    var storeProducts: [HomeFeaturedProductDataEntity] = []
    var storeCategories: [StoreCategory] = [] // NEW: State for categories
    
    private let getStoreSlidersUC: GetStoreSlidersUC
    private let getFeaturedProductsUCForStore: GetFeaturedProductsUCForStore
    private let getHomeCategoriesUC: GetHomeCategoriesUC // NEW: Dependency
    
    init(
        getStoreSlidersUC: GetStoreSlidersUC,
        getFeaturedProductsUCForStore: GetFeaturedProductsUCForStore,
        getHomeCategoriesUC: GetHomeCategoriesUC // NEW: Inject Dependency
    ) {
        self.getStoreSlidersUC = getStoreSlidersUC
        self.getFeaturedProductsUCForStore = getFeaturedProductsUCForStore
        self.getHomeCategoriesUC = getHomeCategoriesUC
    }
    
    func fetchStoreSliders(storeId: Int) async {
        do {
            let response = try await getStoreSlidersUC.execute(storeId: storeId)
            self.storeSliders = response.data
        } catch {
            print("Failed to fetch store sliders: \(error.localizedDescription)")
        }
    }
    
    func fetchStoreProducts(storeId: Int, branchId: Int) async {
        do {
            let response = try await getFeaturedProductsUCForStore.execute(storeId: storeId, branchId: branchId, skip: 0, take: 20)
            self.storeProducts = response.data?.products?.map { $0.asFeaturedProductEntity() } ?? []
            print("✅ Successfully fetched \(self.storeProducts.count) products.")
        } catch {
            print("❌ Failed to fetch store products: \(error)")
        }
    }
    
    // NEW: Fetch Categories
    func fetchStoreCategories(storeId: Int) async {
        do {
            let response = try await getHomeCategoriesUC.execute(storeId: storeId)
            self.storeCategories = response.data
            print("✅ Successfully fetched \(self.storeCategories.count) categories.")
        } catch {
            print("❌ Failed to fetch store categories: \(error)")
        }
    }
}
