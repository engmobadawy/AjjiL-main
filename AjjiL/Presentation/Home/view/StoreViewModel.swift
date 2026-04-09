import Foundation
import SwiftUI

@Observable
@MainActor
class StoreViewModel {
    var storeSliders: [StoreSlider] = []
    var storeProducts: [HomeFeaturedProductDataEntity] = []
    var storeCategories: [StoreCategory] = []
    var storeSubcategories: [StoreCategory] = []
    
    private let getStoreSlidersUC: GetStoreSlidersUC
    private let getFeaturedProductsUCForStore: GetFeaturedProductsUCForStore
    private let getHomeCategoriesUC: GetHomeCategoriesUC
    private let getStoreSubcategoriesUC: GetStoreSubcategoriesUC
    private let getProductsByCategoryUC: GetProductsByCategoryUC // NEW: Filter dependency
    
    init(
        getStoreSlidersUC: GetStoreSlidersUC,
        getFeaturedProductsUCForStore: GetFeaturedProductsUCForStore,
        getHomeCategoriesUC: GetHomeCategoriesUC,
        getStoreSubcategoriesUC: GetStoreSubcategoriesUC,
        getProductsByCategoryUC: GetProductsByCategoryUC // NEW: Inject Dependency
    ) {
        self.getStoreSlidersUC = getStoreSlidersUC
        self.getFeaturedProductsUCForStore = getFeaturedProductsUCForStore
        self.getHomeCategoriesUC = getHomeCategoriesUC
        self.getStoreSubcategoriesUC = getStoreSubcategoriesUC
        self.getProductsByCategoryUC = getProductsByCategoryUC
    }
    
    // Unified product fetching method
    func fetchProducts(storeId: Int, branchId: Int, categoryId: Int?) async {
            do {
                if let categoryId = categoryId {
                    // Fetch filtered by category
                    let response = try await getProductsByCategoryUC.execute(storeId: storeId, branchId: branchId, categoryId: categoryId)
                    
                    // CHANGED: response.data is now the array itself, so we drop `.products?`
                    self.storeProducts = response.data?.map { $0.asFeaturedProductEntity() } ?? []
                    
                    print("✅ Successfully fetched \(self.storeProducts.count) filtered products.")
                } else {
                    // Fetch all products
                    let response = try await getFeaturedProductsUCForStore.execute(storeId: storeId, branchId: branchId, skip: 0, take: 20)
                    self.storeProducts = response.data?.products?.map { $0.asFeaturedProductEntity() } ?? []
                    print("✅ Successfully fetched \(self.storeProducts.count) products.")
                }
            } catch {
                print("❌ Failed to fetch products: \(error)")
                self.storeProducts = []
            }
        }
    
    func fetchStoreSliders(storeId: Int) async {
        do {
            let response = try await getStoreSlidersUC.execute(storeId: storeId)
            self.storeSliders = response.data
        } catch {
            print("Failed to fetch store sliders: \(error.localizedDescription)")
        }
    }
    
    func fetchStoreCategories(storeId: Int) async {
        do {
            let response = try await getHomeCategoriesUC.execute(storeId: storeId)
            self.storeCategories = response.data
        } catch {
            print("❌ Failed to fetch store categories: \(error)")
        }
    }
    
    func fetchStoreSubcategories(storeId: Int) async {
        do {
            let response = try await getStoreSubcategoriesUC.execute(storeId: storeId)
            self.storeSubcategories = response.data
        } catch {
            print("❌ Failed to fetch subcategories: \(error)")
        }
    }
}
