import Foundation

protocol StoreRepository {
    func getFeaturedProducts(storeId: Int, branchId: Int, skip: Int, take: Int) async throws -> [StoreFeaturedProductDataEntity]
}