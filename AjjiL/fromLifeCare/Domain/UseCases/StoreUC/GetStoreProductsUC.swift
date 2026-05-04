import Foundation

class GetStoreProductsUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    // 🛠️ CHANGED: Return type is now CategoryProductsResponse
    func execute(storeId: Int, branchId: Int, search: String) async throws -> CategoryProductsResponse {
        return try await repo.getStoreProducts(storeId: storeId, branchId: branchId, search: search)
    }
}
